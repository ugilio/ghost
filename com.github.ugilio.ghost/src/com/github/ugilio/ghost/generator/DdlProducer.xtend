/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator

import static extension com.github.ugilio.ghost.generator.internal.Utils.*;
import com.google.inject.Inject
import com.github.ugilio.ghost.generator.internal.BlockImpl
import com.github.ugilio.ghost.generator.internal.MultiBlockAdapterImpl
import com.github.ugilio.ghost.generator.internal.Register
import com.github.ugilio.ghost.generator.internal.TemporalExpressionImpl
import com.github.ugilio.ghost.ghost.CompDecl
import com.github.ugilio.ghost.ghost.ComponentType
import com.github.ugilio.ghost.ghost.Ghost
import com.github.ugilio.ghost.ghost.InitSection
import com.github.ugilio.ghost.ghost.TypeDecl
import com.github.ugilio.ghost.preprocessor.DefaultsProvider
import it.cnr.istc.timeline.lang.CompType
import it.cnr.istc.timeline.lang.Component
import it.cnr.istc.timeline.lang.ConsumableResourceType
import it.cnr.istc.timeline.lang.EnumType
import it.cnr.istc.timeline.lang.InstantiatedValue
import it.cnr.istc.timeline.lang.IntType
import it.cnr.istc.timeline.lang.Interval
import it.cnr.istc.timeline.lang.RenewableResourceType
import it.cnr.istc.timeline.lang.ResSyncTrigger
import it.cnr.istc.timeline.lang.ResourceAction
import it.cnr.istc.timeline.lang.SVSyncTrigger
import it.cnr.istc.timeline.lang.SVType
import it.cnr.istc.timeline.lang.SyncTrigger
import it.cnr.istc.timeline.lang.TemporalExpression
import it.cnr.istc.timeline.lang.TemporalOperator
import it.cnr.istc.timeline.lang.TimePointOperation
import it.cnr.istc.timeline.lang.Type
import it.cnr.istc.timeline.lang.Value
import it.cnr.istc.timeline.lang.Variable
import java.util.List
import com.github.ugilio.ghost.generator.internal.Utils
import it.cnr.istc.timeline.lang.SimpleType
import java.util.Set
import com.google.common.collect.Sets
import com.github.ugilio.ghost.generator.internal.LexicalScope
import com.github.ugilio.ghost.generator.internal.ComponentProxy
import java.util.HashSet
import java.util.LinkedList
import com.github.ugilio.ghost.generator.internal.AbstractCompTypeProxy
import com.github.ugilio.ghost.generator.internal.InternalSimpleType
import java.util.function.Function
import org.eclipse.xtext.xbase.lib.Procedures.Procedure2
import java.util.ArrayList
import it.cnr.istc.timeline.lang.StatementBlock
import com.github.ugilio.ghost.generator.internal.VariableProxy
import com.google.common.collect.Iterables
import it.cnr.istc.timeline.lang.EnumLiteral
import com.github.ugilio.ghost.generator.internal.EnumLiteralProxy
import com.github.ugilio.ghost.ghost.EnumDecl
import com.github.ugilio.ghost.preprocessor.AnnotationProvider
import it.cnr.istc.timeline.lang.AnnotatedObject
import com.google.common.collect.Lists
import it.cnr.istc.timeline.lang.TransitionConstraint
import com.github.ugilio.ghost.services.GhostGrammarAccess
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import com.github.ugilio.ghost.preprocessor.AnnotationProvider.AnnotationProviderException

class DdlProducer {
	@Inject
	private Register register;
	
	@Inject
	DefaultsProvider defProvider;
	@Inject
	DdlExpressionFormatter expFormatter;
	@Inject
	DdlEnumScanner enumScanner;
	@Inject
	AnnotationProvider annProvider;
	@Inject
	GhostGrammarAccess grammarAccess;
	
	List<Component> components;
	List<InitSection> inits;
	BlockImpl initBlock;
	
	InitData initData;
	
	private static class InitData {
		Long start = null;
		Long horizon = null;
		Long resolution = null;
	}
	
	private def String formatExpression(Object obj, Component comp) {
		return expFormatter.formatExpression(obj, comp);
	}
	
	private def formatParListWithTypes(Value value) {
		return value.name+"("+
			value.formalParameters.map[type.name].join(", ")+
			")";
	}
	
	private def formatParListWithNames(Value value) {
		return value.name+"("+
			value.formalParameters.map["?"+name].join(", ")+
			")";
	}
	
	private def formatResourceAction(ResourceAction action) {
		return expFormatter.formatResourceAction(action);
	}
	
	private def formatParListWithNames(SyncTrigger trigger) {
		val ann = getFormattedAnnotationsFor(trigger);
		val extra = if (ann.isNullOrEmpty) "" else "<"+ann+"> ";
		return extra+
		switch (trigger) {
			SVSyncTrigger: trigger.value.name+"("+
						trigger.arguments.map["?"+name].join(", ")+
						")"
			ResSyncTrigger: formatResourceAction(trigger.action)+"(?"+
						trigger.argument.name+")"
			default: throw new IllegalArgumentException("Unknown trigger type: "+trigger)
		}
	}
	
	private def formatInterval(Interval intv) {
		return expFormatter.formatInterval(intv);
	}
	
	private def boolean isTimeOp(Object obj) {
		return
		switch(obj) {
			TimePointOperation : true
			Variable: isTimeOp(obj.value)
			default : false
		}
	}
	
	private def String formatTempExpGeneric(String left, String op, Interval i1, Interval i2, int intvCount, String right) {
		val intvString = 
		if (intvCount > 0) {
			var s = " "+formatInterval(i1);
			if (intvCount > 1)
				s += " "+formatInterval(i2);
			s;
		}
		else ""; 
		return String.format("%s %s%s %s",left,op,intvString,right).trim();			
	}
	
	private def void unsetVariable(Variable v) {
		if (v instanceof VariableProxy)
			v.value = null;
	}
	
	private def String formatTempExpPointPoint(TemporalExpression e) {
		//Right might be this, because we cannot do selector(this) > point
		//In this case it becomes point < selector(this) and right this is not unset
		//because we need that variable
		val left = if (e.left === null || isThis(e.left)) "" else (e.left as Variable).name;
		val right = (e.right as Variable).name;
		var l = (e?.left as Variable)?.value as TimePointOperation;
		var r = (e?.right as Variable)?.value as TimePointOperation;
		if (e.operator == TemporalOperator.AFTER)
			return formatTempExpReverse(e);
		val op = l.selector.toString()+"-"+r.selector.toString();
		val intv = 
		switch (e.operator) {
			case TemporalOperator.EQUALS : ZeroInterval
			default: e.intv1
		}
		
		if (isThis(e.left))
			unsetVariable(e.left as Variable);

		return formatTempExpGeneric(left,op,intv,null,1,right);
	}
	
	private def String formatTempExpIntvPoint(TemporalExpression e) {
		val left = if (e.left === null || isThis(e.left)) "" else (e.left as Variable).name;
		val right = (e.right as Variable).name;
		var r = (e?.right as Variable)?.value as TimePointOperation;
		var i1 = e.intv1;
		var i2 = e.intv2;
		val rSel = r.selector.toString();
		
		if (isThis(e.left) && e.operator != TemporalOperator.AFTER)
			unsetVariable(e.left as Variable);

		return
		switch (e.operator) {
			case TemporalOperator.BEFORE : formatTempExpGeneric(left,'END-'+rSel,i1,null,1,right)
			case TemporalOperator.AFTER : formatTempExpGeneric(right,rSel+'-START',i1,null,1,(e.left as Variable).name)
			case TemporalOperator.STARTS : formatTempExpGeneric(left,'START-'+rSel,ZeroInterval,null,1,right)
			case TemporalOperator.FINISHES : formatTempExpGeneric(left,'END-'+rSel,ZeroInterval,null,1,right)
			case TemporalOperator.CONTAINS : formatTempExpGeneric(left,'CONTAINS-'+rSel,i1,i2,2,right)
			default: throw new IllegalArgumentException("Invalid operator for (interval,point): "+e.operator)
		}
	}
	
	private def String formatTempExpPointIntv(TemporalExpression e) {
		val left = if (e.left === null || isThis(e.left)) "" else (e.left as Variable).name;
		val right = (e.right as Variable).name;
		var l = (e?.left as Variable)?.value as TimePointOperation;
		var i1 = e.intv1;
		var i2 = e.intv2;
		val lSel = l.selector.toString();
		
		if (isThis(e.left) && e.operator != TemporalOperator.AFTER)
			unsetVariable(e.left as Variable);

		return
		switch (e.operator) {
			case TemporalOperator.BEFORE : formatTempExpGeneric(left,lSel+'-START',i1,null,1,right)
			case TemporalOperator.AFTER : formatTempExpGeneric(right,'END-'+lSel,i1,null,1,(e.left as Variable).name)
			case TemporalOperator.STARTS : formatTempExpGeneric(left,lSel+'-START',ZeroInterval,null,1,right)
			case TemporalOperator.FINISHES : formatTempExpGeneric(left,lSel+'-END',ZeroInterval,null,1,right)
			case TemporalOperator.DURING : formatTempExpGeneric(left,lSel+'S-DURING',i1,i2,2,right)
			default: throw new IllegalArgumentException("Invalid operator for (point,interval): "+e.operator)
		}
	}
	
	private def String formatTempExpIntvIntv(TemporalExpression e) {
		val left = if (e.left === null || isThis(e.left)) "" else (e.left as Variable).name;
		val right = (e.right as Variable).name;
		var i1 = e.intv1;
		var i2 = e.intv2;
		
		if (isThis(e.left))
			unsetVariable(e.left as Variable);
		
		return
		switch (e.operator) {
			case TemporalOperator.EQUALS : formatTempExpGeneric(left,'EQUALS',null,null,0,right)
			case TemporalOperator.MEETS : formatTempExpGeneric(left,'MEETS',null,null,0,right)
			case TemporalOperator.STARTS : formatTempExpGeneric(left,'START-START',ZeroInterval,null,1,right)
			case TemporalOperator.FINISHES : formatTempExpGeneric(left,'END-END',ZeroInterval,null,1,right)
			case TemporalOperator.BEFORE : formatTempExpGeneric(left,'BEFORE',i1,null,1,right)
			case TemporalOperator.AFTER : formatTempExpGeneric(left,'AFTER',i1,null,1,right)
			case TemporalOperator.CONTAINS : formatTempExpGeneric(left,'CONTAINS',i1,i2,2,right)
			case TemporalOperator.DURING: formatTempExpGeneric(left,'DURING',i1,i2,2,right)
		}
	}
	
	private def String formatTempExpCanonical(TemporalExpression e) {
		if (isTimeOp(e.left) && isTimeOp(e.right))
			return formatTempExpPointPoint(e);
			
		if (isTimeOp(e.right))
			return formatTempExpIntvPoint(e);
			
		if (isTimeOp(e.left))
			return formatTempExpPointIntv(e);
			
		return formatTempExpIntvIntv(e);
	}
	
	private def String formatMetBy(TemporalExpression e) {
		val left = if (e.left === null || isThis(e.left)) "" else (e.left as Variable).name;
		val right = (e.right as Variable).name;
		if (isThis(e.left))
			unsetVariable(e.left as Variable);
		return formatTempExpGeneric(left,'MET-BY',null,null,0,right);
	}
	
	private def String formatTempExpReverse(TemporalExpression e) {
		var left = e.right;
		var right = e.left;
		var i1 = e.intv1;
		var i2 = e.intv1;
		val op = 
		switch (e.operator) {
			case TemporalOperator.BEFORE : TemporalOperator.AFTER
			case TemporalOperator.AFTER : TemporalOperator.BEFORE
			case TemporalOperator.CONTAINS : TemporalOperator.DURING
			case TemporalOperator.DURING: TemporalOperator.CONTAINS
			default: e.operator //no change
		}
		val reversed = new TemporalExpressionImpl(left,op,i1,i2,right,register);
		if (op == TemporalOperator.MEETS)
			return formatMetBy(reversed);
		return formatTempExpCanonical(reversed);
	}
	
	private def String formatTempExp(TemporalExpression e) {
		if (!isThis(e.left) && isThis(e.right))
			return formatTempExpReverse(e);
			
		return formatTempExpCanonical(e);
	}
	
	private def boolean isThis(Object obj) {
		switch(obj) {
			InstantiatedValue: return obj.isThisSync()
			TimePointOperation: return isThis(obj.instValue)
			Variable: return isThis(obj.value)
		}
		return false;
	}
	
	private def boolean isInstCompVariable(Variable v) {
		return expFormatter.isInstCompVariable(v);
	}
	
	private def String formatVariableDecl(Variable v, Component comp) {
		val fmtString = 
			if (isInstCompVariable(v)) {
				if (v.value instanceof Variable)
					"%s EQUALS %s" //icd1 EQUALS icd0
				else {
					val tmp = getFormattedAnnotationsFor(v);
					val extra = if (tmp.isNullOrEmpty) "" else "<"+tmp+"> ";
					"%s "+extra+"%s"  //icd1 comp.timeline.A()
				}
			}
			else
				"?%s = %s" //?x = ...
		return String.format(fmtString,v.name,formatExpression(v.value,comp))
	}
	
	private def String formatTransitionConstraintTags(TransitionConstraint tc) {
		val extra = 
		switch (tc.controllability) {
			case CONTROLLABLE: 'c'
			case UNCONTROLLABLE: 'u'
			default: null
		}
		val str = getFormattedAnnotationsFor(tc,extra);
		if (str != "")
			return "<"+str+"> ";
		return "";
	}
	
	private def boolean isEmpty(StatementBlock b) {
		return b.expressions.isEmpty() && b.variables.isEmpty()
			&& b.temporalExpressions.isEmpty();
	}
	
	private def List<String> getAnnotationsForVariable(Variable v) {
		var anns = annProvider.getAnnotations(v);
		if (anns === null)
			anns = annProvider.getAnnotations(v.value);
		if (anns === null)
			return #[];
		return anns;
	}
	
	private def String getFormattedAnnotationsFor(Object obj, String... extra) {
		val l = Lists.newArrayList(extra.filter[e|e!==null]);
		switch (obj) {
			AnnotatedObject: l.addAll(obj.annotations)
			Variable: l.addAll(getAnnotationsForVariable(obj))
		}
		return l.join(",");
	}

	private def dispatch String doTypeDecl(SVType type) {
		
		val name = type.name;
		val constraints = type.transitionConstraints.filter[!isEmpty(getBody())];  
		val states = type.values.map[v|formatParListWithTypes(v)].join(", ");
		return
		'''
			COMP_TYPE SingletonStateVariable «name» («states»)
			{
				«FOR c : constraints SEPARATOR '\n'»
				«val intv = c.interval»
				«val cont = formatTransitionConstraintTags(c)»
				«val b = c.body»
				VALUE «cont»«formatParListWithNames(c.head)» «formatInterval(intv)»
				MEETS
				{
					«FOR e : b.expressions»
						«formatExpression(e,null)»;
					«ENDFOR»
					«FOR v : b.variables.filter[v|v.value!==null]»
						«formatVariableDecl(v,null)»;
					«ENDFOR»
				}
				«ENDFOR»
			}
		'''
	}
	
	private def dispatch String doTypeDecl(RenewableResourceType type) {
		
		val name = type.name;
		val value = ""+type.value;
		return
		'''COMP_TYPE RenewableResource «name» («value»)'''
	}
	
	private def dispatch String doTypeDecl(ConsumableResourceType type) {
		
		val name = type.name;
		val min = ""+type.min;
		val max = ""+type.max;
		return
		'''COMP_TYPE ConsumableResource «name» («min», «max»)'''
	}
	
	//Intervals
	private def dispatch String doTypeDecl(IntType type) {
		val interval = formatInterval(type.interval);
		return '''PAR_TYPE NumericParameterType «type.name» = «interval»;'''
	}
	
	//Enumerations
	private def dispatch String doTypeDecl(EnumType type) {
		val values = type.values.map[v|v.name].join(", ");
		return '''PAR_TYPE EnumerationParameterType «type.name» = {«values»};'''
	}
	
	private def String doComponentDefinition(Component comp) {
		val CompType type = comp.type;
		val tmlTag = if (type.isExternal())
			getFormattedAnnotationsFor(type,"external")
			else getFormattedAnnotationsFor(type)
		return
		'''COMPONENT «comp.name» {FLEXIBLE timeline(«tmlTag»)} : «type.name»;'''
	}
	
	private def String doSynchronizationsFor(Component comp) {
		val type = comp.type;
		return
		'''
			SYNCHRONIZE «comp.name».timeline
			{
				«FOR s : type.synchronizations SEPARATOR '\n'»
				«FOR b : s.bodies»
				VALUE «formatParListWithNames(s.trigger)»
				{
					«FOR t : b.temporalExpressions»
						«formatTempExp(t)»;
					«ENDFOR»
					«FOR e : b.expressions»
						«formatExpression(e,comp)»;
					«ENDFOR»
					«FOR v : b.variables.filter[v|v.value!==null]»
						«formatVariableDecl(v,comp)»;
					«ENDFOR»
				}
				«ENDFOR»
				«ENDFOR»
			}
		'''
	}
	
	private def getDomainName(Ghost ghost, String suggestion) {
		val baseName = if (ghost?.domain?.name !== null) ghost.domain.name
			else if (ghost?.problem?.name !== null) ghost?.problem?.name
			else if ("" != suggestion && suggestion !== null) suggestion
			else "domain";
		val name = genName(baseName,register.getGlobalScope(),false);
		register.getGlobalScope().add(name,ghost);
		return name;
	}
	
	private def getProblemName(Ghost ghost, String suggestion) {
		val baseName = if ("" != suggestion && suggestion !== null) suggestion +"_prob"
		else "problem";
		val name = genName(baseName,register.getGlobalScope(),false);
		register.getGlobalScope().add(name,ghost);
		return name;
	}
	
	private def String formatTemporalModule(Ghost ghost) {
		val origin = if (initData.start !== null) initData.start 
			else defProvider.getStart(ghost.eResource,Integer.MAX_VALUE);
		val horizon = if (initData.horizon !== null) initData.horizon 
			else defProvider.getHorizon(ghost.eResource,Integer.MAX_VALUE);
		val timepoints = if (initData.resolution !== null) initData.resolution 
			else (horizon-origin);
		return '''TEMPORAL_MODULE module = [«origin», «horizon»], «timepoints»;''';
	}

	private def doInitSections(Ghost ghost) {
		val b = initBlock;
'''		
	«val vars = b.variables.filter[v|v.value!==null]»
	«FOR f : b.facts»
		«formatExpression(f,null)»;
	«ENDFOR»
	«FOR v : vars»
		«formatVariableDecl(v,null)»;
	«ENDFOR»
'''
	}
	
	private def void addToLexicalScope(LexicalScope scope, Component comp) {
		addToLexicalScope(scope,comp,
			[c|c.name], //getName
			[c,n|(c as ComponentProxy).name = n] //setName
		);
	}
	
	private def void addToLexicalScope(LexicalScope scope, CompType type) {
		addToLexicalScope(scope,type,
			[t|t.name], //getName
			[t,n|(t as AbstractCompTypeProxy).name = n] //setName
		);
	}
	
	private def void addToLexicalScope(LexicalScope scope, SimpleType type) {
		if (type instanceof EnumType)
			addLiteralsToLexicalScope(scope,type);
		addToLexicalScope(scope,type,
			[t|t.name], //getName
			[t,n|(t as InternalSimpleType).name = n] //setName
		);
	}
	
	private def void addLiteralsToLexicalScope(LexicalScope scope, EnumType type) {
		type.values.forEach[l|addToLexicalScope(scope,l)];
	}
	
	private def void addToLexicalScope(LexicalScope scope, EnumLiteral lit) {
		addToLexicalScope(scope,lit,
			[l|l.name], //getName
			[l,n|(l as EnumLiteralProxy).name = n] //setName
		);
	}
	
	private def <T> void addToLexicalScope(LexicalScope scope, T obj,
		Function<T,String> getName, Procedure2<T,String> setName) {
		var name = getName.apply(obj);
		val old = scope.get(name);
		if (old !== null && old !== obj) {
			name=genName(name,scope,false);
			setName.apply(obj,name);
		}
		scope.add(name,obj);
	}
	
	private def void processImport(Ghost ghost, Set<Ghost> processedImports) {
		val gScope = register.globalScope;
		val newComps = ghost.decls.filter(CompDecl).
			map[t|register.getProxy(t) as Component].toRegularList;
		newComps.forEach[c|addToLexicalScope(gScope,c)];
		components.addAll(newComps);
		
		inits.addAll(ghost.decls.filter(InitSection).toRegularList);
		
		scanImports(ghost,processedImports);
	}
	
	private def void scanImports(Ghost ghost, Set<Ghost> processedImports) {
		val newImports = 
		ghost.imports.map[imp|imp.importedNamespace.eContainer as Ghost].
			filter[g|!processedImports.contains(g)].toRegularList;
		processedImports.addAll(newImports);
		
		for (g : newImports)
			processImport(g,processedImports);
	}
	
	private def List<CompType> addUsedTypes(List<Component> components, List<CompType> existingTypes) {
		val addedTypes = new HashSet<Type>(existingTypes);
		var newTypes = new LinkedList<CompType>();
		val gScope = register.globalScope;
		
		for (c : components)
			if (addedTypes.add(c.type)) {
				addToLexicalScope(gScope,c.type);
				newTypes.add(c.type);
			}
		return newTypes;
	}
	
	private def List<SimpleType> addUsedSimpleTypes(List<CompType> compTypes, List<SimpleType> existingTypes) {
		val addedTypes = new HashSet<SimpleType>(existingTypes);
		var newTypes = new LinkedList<SimpleType>();
		val gScope = register.globalScope;

		val allTypes = 
		compTypes.filter(SVType).
			map[t|t.transitionConstraints].flatten.
			map[tc|tc.head.formalParameters].flatten.
			map[p|p.type];
			
		val allReferencedEnums =
			Iterables.concat(
				compTypes.map[t|enumScanner.scanSimpleTypeUsage(t)].flatten,
				enumScanner.scanSimpleTypeUsage(initBlock));
		
		for (t : Iterables.concat(allTypes,allReferencedEnums))
			if (addedTypes.add(t)) {
				addToLexicalScope(gScope,t);
				newTypes.add(t);
			}
		return newTypes;
	}
	
	private def Long getInitParam(Variable v) {
		if (!(v.value instanceof Long))
			throw new IllegalArgumentException(
			String.format("Non-numeric value for init variable '%s'",v.name));
		return v.value as Long;
	}
	
	private def void evalInitData() {
		for (v: initBlock.variables)
			switch (v.name) {
				case 'start': initData.start = getInitParam(v)
				case 'horizon': initData.horizon = getInitParam(v)
				case 'resolution': initData.resolution = getInitParam(v)
			}
	}
	
	def void initAnnotationProvider(Ghost ghost) {
		annProvider.clear();

		val annRules = Sets.newHashSet(grammarAccess.SL_ANNOTATIONRule,(grammarAccess.BR_ANNOTATIONRule));
		val root = NodeModelUtils.getNode(ghost);
		try {
			root.asTreeIterable.
				filter[annRules.contains(grammarElement)].
				forEach(n | annProvider.addAnnotation(n));
		}
		catch (AnnotationProviderException e) {} //If we are here, there were no errors

		register.annotationProvider =  annProvider;
	}

	def String doGenerate(Ghost ghost, String baseName) {
		initAnnotationProvider(ghost);
		val gScope = register.getGlobalScope();
		inits = new ArrayList();
		initData = new InitData();
		//Add local types to the global scope
		ghost.decls.filter(TypeDecl).forEach[d|gScope.add(d.name,d)];
		ghost.decls.filter(CompDecl).forEach[d|gScope.add(d.name,d)];
		//Add also local enum literals
		ghost.decls.filter(EnumDecl).
			map[d|d.values].flatten.forEach[l|gScope.add(l.name,l)];
		
		//Local simple types
		val simpleTypes = 
			ghost.decls.filter(com.github.ugilio.ghost.ghost.SimpleType).
			map[t|register.getProxy(t) as SimpleType].toRegularList;
		//Local complex types
		val types = 
			ghost.decls.filter(ComponentType).
			map[t|register.getProxy(t) as CompType].toRegularList;
			
		//Local components
		components = ghost.decls.filter(CompDecl).
			map[t|register.getProxy(t) as Component].toRegularList;
		//Add also local synthetic types (added to the global scope on their own)
		types.addAll(
		ghost.decls.filter(CompDecl).
			filter[cd|Utils.needsSyntheticType(cd,annProvider)].
			map[c|register.getProxy(c) as Component].map[c|c.type].toList);
			
		//Collect all components and init sections everywhere 
		scanImports(ghost,Sets.newHashSet(ghost));
		
		//Add also inits from this file, at the end
		inits.addAll(ghost.decls.filter(InitSection).toRegularList);
		initBlock = new BlockImpl(new MultiBlockAdapterImpl(inits),null,register);
		
		//walk through all components and add their types, if not already present
		val newTypes = addUsedTypes(components,types);
		types.addAll(newTypes);
		val newSimpleTypes = addUsedSimpleTypes(types,simpleTypes);

		simpleTypes.addAll(newSimpleTypes);
		
		evalInitData();
		
		var String output = produce(ghost,simpleTypes,types,baseName);
		
		return output;
	}
	
	protected def String produce(Ghost ghost, List<SimpleType> simpleTypes,
		List<CompType> types, String baseName) {
		val domainName = getDomainName(ghost,baseName);
		val problemName = getProblemName(ghost,domainName);
		val syncs = components.filter[t|t.type?.synchronizations.size>0];
		val hasInits = inits.size>0;
			
		
		return '''
DOMAIN «domainName»
{
	«formatTemporalModule(ghost)»
	«IF simpleTypes.size>0»
	
	«FOR t : simpleTypes»
		«doTypeDecl(t)»
	«ENDFOR»
	«ENDIF»
	«IF types.size>0»
	
	«FOR t : types SEPARATOR '\n'»
		«doTypeDecl(t)»
	«ENDFOR»
	«ENDIF»
	«IF components.size>0»
	
	«FOR c : components»
		«doComponentDefinition(c)»
	«ENDFOR»
	«ENDIF»
	«IF syncs.size>0»
	
	«FOR s : syncs SEPARATOR '\n'»
		«doSynchronizationsFor(s)»
	«ENDFOR»
	«ENDIF»
}
	«IF (hasInits)»
PROBLEM «problemName» (DOMAIN «domainName»)
{
	«doInitSections(ghost)»
}
	«ENDIF»
''';
	}
}