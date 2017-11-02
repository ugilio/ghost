package it.cnr.istc.ghost.generator

import static extension it.cnr.istc.ghost.generator.internal.Utils.*;
import com.google.inject.Inject
import it.cnr.istc.ghost.conversion.NumberValueConverter
import it.cnr.istc.ghost.generator.internal.BlockImpl
import it.cnr.istc.ghost.generator.internal.MultiBlockAdapterImpl
import it.cnr.istc.ghost.generator.internal.Register
import it.cnr.istc.ghost.generator.internal.TemporalExpressionImpl
import it.cnr.istc.ghost.ghost.AnonResDecl
import it.cnr.istc.ghost.ghost.AnonSVDecl
import it.cnr.istc.ghost.ghost.CompDecl
import it.cnr.istc.ghost.ghost.CompSVBody
import it.cnr.istc.ghost.ghost.ComponentType
import it.cnr.istc.ghost.ghost.Ghost
import it.cnr.istc.ghost.ghost.InitSection
import it.cnr.istc.ghost.ghost.NamedCompDecl
import it.cnr.istc.ghost.ghost.TypeDecl
import it.cnr.istc.ghost.preprocessor.DefaultsProvider
import it.cnr.istc.timeline.lang.CompType
import it.cnr.istc.timeline.lang.Component
import it.cnr.istc.timeline.lang.ComponentVariable
import it.cnr.istc.timeline.lang.ConsumableResourceType
import it.cnr.istc.timeline.lang.Controllability
import it.cnr.istc.timeline.lang.EnumLiteral
import it.cnr.istc.timeline.lang.EnumType
import it.cnr.istc.timeline.lang.Expression
import it.cnr.istc.timeline.lang.Fact
import it.cnr.istc.timeline.lang.InstantiatedValue
import it.cnr.istc.timeline.lang.IntType
import it.cnr.istc.timeline.lang.Interval
import it.cnr.istc.timeline.lang.Parameter
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
import it.cnr.istc.ghost.generator.internal.Utils
import it.cnr.istc.timeline.lang.SimpleType
import java.util.Set
import com.google.common.collect.Sets
import it.cnr.istc.ghost.generator.internal.LexicalScope
import it.cnr.istc.ghost.generator.internal.ComponentProxy
import java.util.HashSet
import java.util.LinkedList
import it.cnr.istc.ghost.generator.internal.AbstractCompTypeProxy
import it.cnr.istc.ghost.generator.internal.InternalSimpleType
import java.util.function.Function
import org.eclipse.xtext.xbase.lib.Procedures.Procedure2
import java.util.ArrayList
import it.cnr.istc.timeline.lang.StatementBlock
import it.cnr.istc.ghost.generator.internal.VariableProxy

class DdlProducer {
	@Inject
	private Register register;
	
	@Inject
	DefaultsProvider defProvider;
	@Inject
	NumberValueConverter numConv;
	
	List<Component> components;
	List<InitSection> inits;
	BlockImpl initBlock;
	
	InitData initData;
	
	private static class InitData {
		Long start = null;
		Long horizon = null;
		Long resolution = null;
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
		return
		switch (action) {
			case REQUIRE : "REQUIREMENT"
			case PRODUCE : "PRODUCTION"
			case CONSUME : "CONSUMPTION"
		}
	}
	
	private def formatParListWithNames(SyncTrigger trigger) {
		return
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
		val i = if (intv === null) Utils.ZeroInterval else intv;
		val lb = numConv.toString(i.lb);
		val ub = numConv.toString(i.ub);
		
		return '''[«lb», «ub»]''';
	}
	
	private def boolean isTimeOp(Object obj) {
		return
		switch(obj) {
			TimePointOperation : true
			Variable: (obj.value instanceof TimePointOperation)
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
		
		if (isThis(e.left))
			unsetVariable(e.left as Variable);

		return
		switch (e.operator) {
			case TemporalOperator.BEFORE : formatTempExpGeneric(left,'END-'+rSel,i1,null,1,right)
			case TemporalOperator.AFTER : formatTempExpGeneric(right,rSel+'-START',i1,null,1,left)
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
		
		if (isThis(e.left))
			unsetVariable(e.left as Variable);

		return
		switch (e.operator) {
			case TemporalOperator.BEFORE : formatTempExpGeneric(left,lSel+'-START',i1,null,1,right)
			case TemporalOperator.AFTER : formatTempExpGeneric(right,'END-'+lSel,i1,null,1,left)
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
	
	private def int getOpDegree(String op) {
		return
		switch (op) {
			case '*', case '/', case '%': 1
			case '+', case '-': 2
			case '<', case '<=', case '>', case '>=' : 3
			case '=', case '!=' : 4
			default: 0
		}
	}
	
	private def getExpDegree(Object exp) {
		switch (exp) {
			Expression: if (exp.operators.size()>0) return getOpDegree(exp.operators.get(0))
		}
		return 0;
	}
	
	private def dispatch String formatExpression(Expression e, Component comp) {
		var s = formatExpression(e.operands.get(0),comp)+" ";
		val len = if (e.operators === null) 0 else e.operators.size();
		for (var i = 0; i < len; i++) {
			val op = e.operators.get(i);
			val r = e.operands.get(i+1);
			val needParens = getOpDegree(op) <= getExpDegree(r);
			var sub = formatExpression(r,comp);
			if (needParens)
				sub = "("+sub+")";
			s += op+" "+sub+" ";
		}
		s = s.trim();
		return s
	}
	
	private def boolean isThis(Object obj) {
		switch(obj) {
			InstantiatedValue: return obj.isThisSync()
			TimePointOperation: return isThis(obj.instValue)
			Variable: return isThis(obj.value)
		}
		return false;
	}
	
	private def boolean needsSyntheticType(CompDecl decl) {
		return
		switch (decl) {
			AnonSVDecl: true
			AnonResDecl: true
			NamedCompDecl: {
				val body = decl?.body;
				if (body?.synchronizations !== null &&
					body.synchronizations.size()>0)
					return true;
				switch (body) {
					CompSVBody : return (body.transitions !== null && 
									body.transitions.size()>0)
					default: false 
				}
			}
			default: false
		}
	}
	
	private def dispatch String formatExpression(Long l, Component comp) {
		if (l == Long.MAX_VALUE) return "INF"
		else if (l == Long.MIN_VALUE) return "-INF"
		else return ""+l; 
	}
	
	private def boolean isInstCompVariable(Variable v) {
		return (v.getValue instanceof InstantiatedValue) || (v.getValue instanceof TimePointOperation);
	}
	
	private def dispatch String formatExpression(Variable v, Component comp) {
		return if (isInstCompVariable(v)) v.name else "?"+v.name;
	}
	
	private def dispatch String formatExpression(Parameter p, Component comp) {
		return "?"+p.name;
	}
	
	private def dispatch String formatExpression(EnumLiteral l, Component comp) {
		return l.name;
	}
	
	private def Component resolveComponent(Object obj, Component context) {
		return
		switch (obj) {
			Component: obj
			ComponentVariable: if (context !== null) context.getVariableMapping.get(obj) else null
			default: null
		}
	}
	
	private def dispatch String formatExpression(InstantiatedValue iv, Component comp) {
		val c = resolveComponent(iv?.component,comp);
		var s = if (c !== null) c.name+".timeline." else "";
		var value = 
		switch (iv.value) {
			Value: (iv.value as Value).name
			ResourceAction: formatResourceAction(iv.value as ResourceAction)
			default: ""+iv.value
		}
		s+=value+"(";
		if (iv.arguments !== null)
			s+=iv.arguments.map[a|formatExpression(a,comp)].join(", ")
		s+=")";
		return s;
	}
	
	private def dispatch String formatExpression(TimePointOperation op, Component comp) {
		return formatExpression(op.getInstValue(),comp);
	}
	
	private def dispatch String formatExpression(Fact fact, Component comp) {
		val type = if (fact.isGoal()) "<goal>" else "<fact>";
		val instval = formatExpression(fact.value,comp);
		val at = String.format("AT %s %s %s",
			formatInterval(fact.start),
			formatInterval(fact.duration),
			formatInterval(fact.end));
		return String.format("%s %s %s",type,instval,at);
	}
	
	private def dispatch String formatExpression(Object e, Component comp) { "<ERROR:>"+e}
	private def dispatch String formatExpression(Void e, Component comp) { ""}
	
	private def String formatVariableDecl(Variable v, Component comp) {
		val fmtString = 
			if (isInstCompVariable(v))
				"%s %s"
			else
				"?%s = %s"
		return String.format(fmtString,v.name,formatExpression(v.value,comp))
	}
	
	private def String formatControllability(Controllability contr) {
		return
		switch (contr) {
			case CONTROLLABLE: '<c> '
			case UNCONTROLLABLE: '<u> '
			default: ''
		}		
	}
	
	private def boolean isEmpty(StatementBlock b) {
		return b.expressions.isEmpty() && b.variables.isEmpty()
			&& b.temporalExpressions.isEmpty();
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
				«val cont = formatControllability(c.controllability)»
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
		val tmlTag = if (comp.type.isExternal()) "external" else "";
		val CompType type = comp.type;
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
	
	private def getDomainName(Ghost ghost) {
		val baseName = if (ghost?.domain?.name !== null) ghost.domain.name
			else if (ghost?.problem?.name !== null) ghost?.problem?.name
			else "domain";
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
	«FOR e : b.expressions»
		«formatExpression(e,null)»;
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
		addToLexicalScope(scope,type,
			[t|t.name], //getName
			[t,n|(t as InternalSimpleType).name = n] //setName
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
		
		for (t : allTypes)
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
	
	def String doGenerate(Ghost ghost) {
		val gScope = register.getGlobalScope();
		inits = new ArrayList();
		initData = new InitData();
		//Add local types to the global scope
		ghost.decls.filter(TypeDecl).forEach[d|gScope.add(d.name,d)];
		ghost.decls.filter(CompDecl).forEach[d|gScope.add(d.name,d)];
		
		//Local simple types
		val simpleTypes = 
			ghost.decls.filter(it.cnr.istc.ghost.ghost.SimpleType).
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
			filter[needsSyntheticType].
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
		
		var String output = produce(ghost,simpleTypes,types);
		
		return output;
	}
	
	protected def String produce(Ghost ghost, List<SimpleType> simpleTypes,
		List<CompType> types) {
		val domainName = getDomainName(ghost);
		val problemName = "problem";
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