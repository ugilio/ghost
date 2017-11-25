/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * generated by Xtext 2.12.0
 */
package com.github.ugilio.ghost.validation

import static com.github.ugilio.ghost.ghost.GhostPackage.Literals.*;

import org.eclipse.xtext.validation.Check
import com.github.ugilio.ghost.ghost.SvDecl
import java.util.HashSet
import com.github.ugilio.ghost.ghost.ResourceDecl
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import com.github.ugilio.ghost.ghost.EnumDecl
import java.util.List
import org.eclipse.emf.ecore.EStructuralFeature
import com.github.ugilio.ghost.ghost.Ghost
import com.github.ugilio.ghost.naming.GhostNameProvider
import com.github.ugilio.ghost.ghost.ResSimpleInstVal
import org.eclipse.xtext.EcoreUtil2
import com.github.ugilio.ghost.ghost.ResourceBody
import com.github.ugilio.ghost.ghost.CompResBody
import com.github.ugilio.ghost.ghost.QualifInstVal
import com.github.ugilio.ghost.ghost.ValueDecl
import com.github.ugilio.ghost.ghost.SimpleInstVal
import com.github.ugilio.ghost.ghost.Synchronization
import com.github.ugilio.ghost.ghost.NamedCompDecl
import com.github.ugilio.ghost.ghost.InheritedKwd
import com.github.ugilio.ghost.ghost.TransConstraint
import com.github.ugilio.ghost.ghost.TransConstrBody
import com.github.ugilio.ghost.ghost.SyncBody
import com.github.ugilio.ghost.ghost.SvBody
import com.github.ugilio.ghost.ghost.CompSVBody
import com.github.ugilio.ghost.ghost.TriggerType
import com.github.ugilio.ghost.ghost.CompBody
import com.github.ugilio.ghost.ghost.ObjVarDecl
import com.github.ugilio.ghost.ghost.FormalParList
import com.github.ugilio.ghost.ghost.NameOnlyParList
import static extension com.github.ugilio.ghost.utils.Utils.*
import com.github.ugilio.ghost.ghost.LocVarDecl
import com.github.ugilio.ghost.ghost.ResConstr
import com.github.ugilio.ghost.ghost.AnonResDecl
import com.github.ugilio.ghost.ghost.AnonSVDecl
import com.github.ugilio.ghost.ghost.ConstExpr
import com.github.ugilio.ghost.ghost.ResourceAction
import com.github.ugilio.ghost.ghost.BindList
import com.github.ugilio.ghost.ghost.ComponentType
import com.github.ugilio.ghost.ghost.InitSection
import com.github.ugilio.ghost.ghost.ThisKwd
import com.github.ugilio.ghost.ghost.CompDecl
import com.github.ugilio.ghost.ghost.ImportDecl
import com.github.ugilio.ghost.ghost.TimePointOp

/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class GhostValidator extends AbstractGhostValidator {
	
	public static val CYCLIC_HIERARCHY = 'cyclicHierarchy';
	public static val EMPTY_ENUM = 'emptyEnum';
	public static val DUPLICATE_IDENTIFIER = 'duplicateIdentifier';
	public static val DUPLICATE_IMPORT = 'duplicateImport';
	public static val RESACTION_NONRES = 'resactionNonRes';
	public static val RESACTION_WRONGRES = 'resactionWrongRes';
	public static val SYNCH_INVALID_PARNUM = "synchInvalidParNum";
	public static val QUALIFINSTVAL_INCOMPATIBLE_ARGS = "qualifInstValIncompatibleArgs";
	public static val RESCONSTR_INCOMPATIBLE_COMP = "resConstrIncompatibleComp";
	public static val INHERITANCE_INCOMPATIBLE_PARAMS = "inheritanceIncompatibleParams";
	public static val INHERITED_KWD_NO_ANCESTOR = "inheritedKwdNoAncestor";
	public static val INHERITANCE_MULTIBRANCH = "inheritanceMultibranch";
	public static val THIS_INVALID_USAGE = "thisInvalidUsage";
	public static val RESCONSTR_IN_TC = "resconstrInTC";
	public static val COMPREF_IN_TC = "comprefInTC";
	public static val TIMEPOINTOP_IN_TC = "timepointopInTC";
	public static val TEMPEXP_IN_TC = "tempexpInTC";
	public static val RENEWABLE_CONSUMABLE_MIX = "renewableConsumableMix";
	public static val AMBIGUOUS_RESOURCE_DECL = "ambiguousResourceDecl";
	public static val RES_UNSPECIFIED_VALUE = "resUnspecifiedValue";
	public static val RES_WRONG_BODY = "resWrongBody";
	public static val BINDLIST_MULTIPLEVAR = "bindlistMultiplevar";
	public static val BINDLIST_SOME_UNBOUND = "bindlistSomeUnbound"; 
	public static val BINDLIST_TOO_LARGE = "bindlistTooLarge";
	public static val BINDLIST_INCOMP_TYPES = "bindlistIncompTypes"; 
	public static val RECURSIVE_VARDECL = "recursiveVarDecl";
	public static val EXPECTED_TYPE = "expectedType";
	public static val INIT_VAR_NOT_NUMBER = "initVarNotNumber"
	public static val INIT_VAR_NOT_CONSTANT = "initVarNotConstant"
	public static val TEMPOP_INCOMPATIBLE = "tempopIncompatible";
	public static val LOCVAR_TEMPORAL_EXP = "locvarTemporalExp";
	
	public static val BOOLEAN_TO_NUMERIC = "booleanToNumeric";
	public static val COMPARISON_DIFFERENT_TYPES = "comparisonDifferentTypes";
	public static val UNUSED_VAR = "unusedVar";
	public static val USELESS_EXPRESSION = "uselessExpression";
	public static val SELF_IMPORT = "selfImport";

	// Checks for type hierarchy

	private def ComponentType getType(CompDecl decl) {
		return
		switch (decl) {
			NamedCompDecl: decl.type
			default : null			
		}
	}
	
	private def getIndex(EObject cont, EStructuralFeature feat, EObject obj) {
		if (!feat.isMany) return -1;
		val list = cont.eGet(feat) as List<? extends EObject>;
		return list.indexOf(obj);
	}
	
	protected def checkHierarcyCycles(EObject decl, EReference feature) {
		val visited = new HashSet<EObject>();
		var tmp = decl;
		visited.add(tmp);
		while (getParent(tmp)!==null) {
			tmp = getParent(tmp);
			if (visited.contains(tmp)) {
				error('Cyclic dependency in type hierarchy', 
						feature,
						com.github.ugilio.ghost.validation.GhostValidator.CYCLIC_HIERARCHY)
				return;
			}
			visited.add(tmp);
		}
	}
		
	@Check
	def checkSVHierarcyCycles(SvDecl decl) {
		checkHierarcyCycles(decl,SV_DECL__PARENT);
	}
	
	@Check
	def checkResHierarcyCycles(ResourceDecl decl) {
		checkHierarcyCycles(decl,RESOURCE_DECL__PARENT);
	}
	
	//Checks for missing values / empty references
	
	@Check
	def checkEnumIsNotEmpty(EnumDecl e) {
		if (e.values.isEmpty())
			error("Enumeration cannot be empty",ENUM_DECL__VALUES,EMPTY_ENUM);
	}
	
	//Checks for duplicate identifiers
	private def getObjName(EObject obj) {
		val name = GhostNameProvider.getObjName(obj);
		if ("_" == name)
			return null;
		return name;
	}

	private def getByName(Object name, Iterable<? extends EObject> list) {
		if (name!==null)
			for (o : list)
				if (name.equals(getObjName(o)))
					return o;
		return null;
	} 
	
	private def checkDuplicateIdentifiers(EObject cont, EStructuralFeature feat,
		String msg, String id) {
		val list = cont.eGet(feat) as List<EObject>;
		for (o : list) {
			val name = getObjName(o)
			if (name!==null && getByName(name,list) != o)
				error(String.format(msg,name),feat,list.indexOf(o),id);
		}
	}
	
	private def checkDuplicateIdentifiers(Iterable<? extends EObject> list,
		EStructuralFeature feat, String msg, String id) {
			checkDuplicateIdentifiers(list,list,feat,msg,id);
	}
	
	private def checkDuplicateIdentifiers(Iterable<? extends EObject> haystack,
		Iterable<? extends EObject> needle,
		EStructuralFeature feat, String msg, String id) {
		for (o : needle) {
			val name = getObjName(o)
			if (name!==null && getByName(name,haystack) != o)
				error(String.format(msg,name),o.eContainer,feat,id);
		}
	}
	
	@Check
	def checkUniqueTopLevelDeclarations(Ghost ghost) {
		checkDuplicateIdentifiers(ghost,GHOST__DECLS,"Duplicate identifier '%s'",DUPLICATE_IDENTIFIER);
	}
	
	//Unique SV Values
	
	private def doCheckUniqueSVValues(EObject body) {
		checkDuplicateIdentifiers(EcoreUtil2.eAllOfType(body,ValueDecl),
			TRANS_CONSTRAINT__HEAD,"Duplicate identifier '%s'",DUPLICATE_IDENTIFIER
		);
	}
	
	@Check
	def checkUniqueSVValues(SvBody body) {
		doCheckUniqueSVValues(body);
	}
	
	@Check
	def checkUniqueSVValues(CompSVBody body) {
		doCheckUniqueSVValues(body);
	}
	
	//Unique Synchronizations
	private def doCheckUniqueSynchronizations(EObject body) {
		checkDuplicateIdentifiers(EcoreUtil2.eAllOfType(body,TriggerType),
			SYNCHRONIZATION__TRIGGER,"Duplicate identifier '%s'",DUPLICATE_IDENTIFIER);
	}
	
	@Check
	def checkUniqueSynchronizations(SvBody body) {
		doCheckUniqueSynchronizations(body);
	}
	
	@Check
	def checkUniqueSynchronizations(ResourceBody body) {
		doCheckUniqueSynchronizations(body);
	}
	
	@Check
	def checkUniqueSynchronizations(CompBody body) {
		doCheckUniqueSynchronizations(body);
	}
	
	//Unique Object variables declarations
	private def doCheckUniqueObjVarDecls(EObject body) {
		checkDuplicateIdentifiers(EcoreUtil2.eAllOfType(body,ObjVarDecl),
			VARIABLE_SECTION__VALUES,"Duplicate identifier '%s'",DUPLICATE_IDENTIFIER);
	}
	
	@Check
	def checkUniqueObjVarDecls(SvBody body) {
		doCheckUniqueObjVarDecls(body);
	}
	
	@Check
	def checkUniqueObjVarDecls(ResourceBody body) {
		doCheckUniqueObjVarDecls(body);
	}
	
	//Unique arguments
	@Check
	def checkUniqueNamesInParList(NameOnlyParList parList) {
		checkDuplicateIdentifiers(parList,NAME_ONLY_PAR_LIST__VALUES,"Duplicate identifier '%s'",DUPLICATE_IDENTIFIER);
	}
	
	@Check
	def checkUniqueFormalParams(FormalParList parList) {
		checkDuplicateIdentifiers(parList,FORMAL_PAR_LIST__VALUES,"Duplicate identifier '%s'",DUPLICATE_IDENTIFIER);
	}
	
	//Unique local variables
	@Check
	def checkUniqueLocVars(TransConstrBody body) {
		val syms = getSymbolsForBlock(body);
		val vars = syms.filter[o|o instanceof LocVarDecl];
		checkDuplicateIdentifiers(syms,vars,
			TRANS_CONSTR_BODY__VALUES,
			"Duplicate identifier '%s'",DUPLICATE_IDENTIFIER);
	}
	
	@Check
	def checkUniqueLocVars(SyncBody body) {
		val syms = getSymbolsForBlock(body);
		val vars = syms.filter[o|o instanceof LocVarDecl];
		checkDuplicateIdentifiers(syms,vars,
			SYNC_BODY__VALUES,
			"Duplicate identifier '%s'",DUPLICATE_IDENTIFIER);
	}
	
	//Unique "inherited" keyword usages
	
	@Check
	def checkUniqueInherited(TransConstrBody tcb) {
		checkDuplicateIdentifiers(EcoreUtil2.eAllOfType(tcb,InheritedKwd),
			TRANS_CONSTR_BODY__VALUES,"Duplicate usage of '%s' keyword",DUPLICATE_IDENTIFIER);
	}
	
	@Check
	def checkUniqueInherited(Synchronization s) {
		checkDuplicateIdentifiers(EcoreUtil2.eAllOfType(s,InheritedKwd),
			SYNC_BODY__VALUES,"Duplicate usage of '%s' keyword",DUPLICATE_IDENTIFIER);
	}
	
	//Unique imports
	
	@Check
	def checkUniqueImports(Ghost ghost) {
		checkDuplicateIdentifiers(ghost,GHOST__IMPORTS,"Duplicate import '%s'",DUPLICATE_IMPORT);
	}
	
	//Check QualifInstVal has compatible fields
	
	@Check
	def checkQualifInstValCompat(QualifInstVal v) {
		if (! (v.value instanceof ValueDecl) && (v?.value?.name !== null)) {
			if (v.arglist !== null)
				error(String.format("'%s' cannot have arguments since it is not a value",v.value.name),
					 QUALIF_INST_VAL__ARGLIST,QUALIFINSTVAL_INCOMPATIBLE_ARGS);
		}
	}
	
	//Check ResConstr's component is a resource
	
	@Check
	def checkResConstrCompat(ResConstr rc) {
		val res = rc.res
		if (res instanceof AnonResDecl)
			return;
		val type = 
			switch (res) {
				NamedCompDecl: res.type
				ObjVarDecl: res.type
				default : null
			}
		if (type instanceof ResourceDecl)
			return;
		val errType = if ((type instanceof SvDecl) || (res instanceof AnonSVDecl)) "state variable component"
			else "unknown type";
		error(String.format("Resource component expected, but %s found",errType),
			RES_CONSTR__RES,RESCONSTR_INCOMPATIBLE_COMP);
	}

	private def checkResActionComp(ResourceAction action, EObject resource,
		EStructuralFeature feature) {
		if (action === null || !isResource(resource))
			return; 
		if (isConsumable(resource) && action==ResourceAction.REQUIRE)
			error(String.format("Cannot use '%s' on a consumable resource",action.literal),
				feature,RESACTION_WRONGRES)
		else if (!isConsumable(resource) &&
			(action==ResourceAction.PRODUCE || action==ResourceAction.CONSUME))
			error(String.format("Cannot use '%s' on a renewable resource",action.literal),
				feature,RESACTION_WRONGRES);
	}

	// Check resconstr action is compatible with the resource type
	@Check
	def checkResConstrActionTypeCompat(ResConstr rc) {
		checkResActionComp(rc.type,rc.res,RES_CONSTR__RES);
	}
	
	@Check
	def checkResConstrActionTypeCompat(ResSimpleInstVal v) {
		checkResActionComp(v.type,v.eContainer?.eContainer?.eContainer?.eContainer,RES_SIMPLE_INST_VAL__TYPE);
	}
	
	
	//Recursive local variables definition;
	@Check
	def checkRecursiveLocVar(LocVarDecl x) {
		if (x.value !== null) {
			val ref = EcoreUtil2.eAllOfType(x.value,QualifInstVal).filter[q|q.value===x].head;
			if (ref !== null)
				error("Recursive variable definition",ref.eContainer,ref.eContainingFeature,RECURSIVE_VARDECL);
		}
	}
	
	//Synchronizations check
	@Check
	def checkResactionTrigger(ResSimpleInstVal v) {
		if (EcoreUtil2.getContainerOfType(v,ResourceBody) !== null)
			return;
		if (EcoreUtil2.getContainerOfType(v,CompResBody) !== null)
			return;
		error("Resource actions can be used as triggers in resources only",RES_SIMPLE_INST_VAL__TYPE,RESACTION_NONRES);
	}
	
	@Check
	def checkSynchArgs(SimpleInstVal v) {
		if (!(v.eContainer instanceof Synchronization))
			return;
		val s = v.eContainer as Synchronization;
		if (s.trigger === v) {
			val formalLen = if (v.value?.parlist?.values !== null) v.value.parlist.values.size
				else 0;
			val actLen = if (v.arglist?.values !== null) v.arglist.values.size
				else 0;
			if (actLen>formalLen)
				error(String.format(
					"Incompatible parameter list: maximum %d parameters expected, got %d",
					formalLen,actLen),SIMPLE_INST_VAL__ARGLIST,SYNCH_INVALID_PARNUM);
		}
	}
	
	//Inheritance checks
	
	@Check
	def checkInheritedValuesCompatibility(ValueDecl v) {
		val parentVal = getParentValue(v);
		if (parentVal !== null) {
			val parCount = if (parentVal.parlist?.values !== null) parentVal.parlist.values.size
				else 0;
			val thisCount = if (v.parlist?.values !== null) v.parlist.values.size
				else 0;
			if (parCount != thisCount) {
				error(String.format(
					"Incompatible parameter list: parent value has %d parameters, got %d",
					parCount,thisCount),VALUE_DECL__PARLIST,INHERITANCE_INCOMPATIBLE_PARAMS);
				return;
			}
			for (var i = 0; i < parCount; i++) {
				val p = parentVal.parlist.values.get(i);
				val t = v.parlist.values.get(i);
				if (p.type != t.type) {
					val pn = p.type.name; 
					val tn = t.type.name;
					if (pn !== null && tn !== null) 
					error(String.format("Incompatible parameter: expected '%s' but got '%s'",
						pn,tn),VALUE_DECL__PARLIST,INHERITANCE_INCOMPATIBLE_PARAMS);
				}
			}
		}
	}
	
	@Check
	def checkInheritedOutOfContext(TransConstrBody tcb) {
		val tc = tcb.eContainer as TransConstraint;
		for (var i = 0; i < tcb.values.size; i++)
			if (tcb.values.get(i) instanceof InheritedKwd)
				if (getParentValue(tc.head)===null) {
					error("There is no ancestor value to inherit from",
						TRANS_CONSTR_BODY__VALUES,i,
						INHERITED_KWD_NO_ANCESTOR);
					return;
				}
	}

	@Check
	def checkInheritedOutOfContext(SyncBody sb) {
		val s = sb.eContainer as Synchronization;
		for (var i = 0; i < sb.values.size; i++)
			if (sb.values.get(i) instanceof InheritedKwd)
				if (getParentSync(s.trigger)===null) {
					error("There is no ancestor synchronization to inherit from",
						SYNC_BODY__VALUES,i,
						INHERITED_KWD_NO_ANCESTOR);
					return;
				}
	}
	
	@Check
	def checkInheritedFromMultipleBranches(SyncBody sb) {
		val s = sb.eContainer as Synchronization;
		for (var i = 0; i < sb.values.size; i++)
			if (sb.values.get(i) instanceof InheritedKwd) {
				val parentTrigger = getParentSync(s.trigger);
				if (parentTrigger !== null)
					if ((parentTrigger.eContainer as Synchronization).bodies.size>1) {
						error("Cannot inherit from a synchronization having multiple branches",
						SYNC_BODY__VALUES,i,INHERITANCE_MULTIBRANCH);
					return;
					}
			}
	}
	
	@Check
	def checkThisInInitSec(ThisKwd kwd) {
		if (EcoreUtil2.getContainerOfType(kwd,InitSection) !== null)
			error("Cannot use 'this' keyword in an initialization section",
				kwd.eContainer,kwd.eContainingFeature,
				getIndex(kwd.eContainer,kwd.eContainingFeature,kwd),
				THIS_INVALID_USAGE);
	}
	
	@Check
	def checkThisInTransitionConstraint(ThisKwd kwd) {
		if (EcoreUtil2.getContainerOfType(kwd,TransConstraint) !== null)
			error("Cannot use 'this' keyword in a transition constraint",
				kwd.eContainer,kwd.eContainingFeature,
				getIndex(kwd.eContainer,kwd.eContainingFeature,kwd),
				THIS_INVALID_USAGE);
	}
	
	@Check
	def checkResConstrInTransitionConstraint(ResConstr constr) {
		if (EcoreUtil2.getContainerOfType(constr,TransConstraint) !== null)
			error("Invalid usage of resource constraints in this context",
				constr.eContainer,constr.eContainingFeature,
				getIndex(constr.eContainer,constr.eContainingFeature,constr),
				RESCONSTR_IN_TC);
	}

	@Check
	def checkCompInTransitionConstraint(QualifInstVal qiv) {
		if (qiv.comp!==null && EcoreUtil2.getContainerOfType(qiv,TransConstraint) !== null)
			error("Invalid usage of component references in this context",
				qiv.eContainer,qiv.eContainingFeature,
				getIndex(qiv.eContainer,qiv.eContainingFeature,qiv),
				COMPREF_IN_TC);
	}

	@Check
	def checkTimePointInTransitionConstraint(TimePointOp op) {
		if (EcoreUtil2.getContainerOfType(op,TransConstraint) !== null)
			error("Invalid usage of time point operators in this context",
				op.eContainer,op.eContainingFeature,
				getIndex(op.eContainer,op.eContainingFeature,op),
				TIMEPOINTOP_IN_TC);
	}

	@Check
	def checkAmbiguousResourceType(ResourceDecl decl) {
		if ((decl.body?.val1===null) && (decl.parent === null))
			error("Ambiguous resource declaration: use the placeholder character '_' to qualify it either as a renewable or consumable resource",
			RESOURCE_DECL__BODY,-1,AMBIGUOUS_RESOURCE_DECL);
	}
	
	@Check
	def checkUnspecifiedResourceValues(AnonResDecl decl) {
		if (isUnspecified(decl.body?.val1))
			error("Instantiation of resource component with unspecified value(s)",
			ANON_RES_DECL__BODY,-1,RES_UNSPECIFIED_VALUE);
	}
	
	@Check
	def checkUnspecifiedResourceValues(NamedCompDecl decl) {
		if (decl.type instanceof ResourceDecl) {
			val val1 = getVal1(decl);
			val val2 = getVal2(decl);
			if (isUnspecified(val1) || (isUnspecified(val2) && isConsumable(decl)))
				error("Instantiation of resource component with unspecified value(s)",
				NAMED_COMP_DECL__BODY,-1,RES_UNSPECIFIED_VALUE);
		}
	}
	
	@Check
	def checkRenewableConsumableHierarchy(ResourceDecl decl) {
		doCheckRenewableConsumableHierarchy(decl,
			decl.body?.val1,decl.body?.val2,decl.name,RESOURCE_DECL__PARENT);
	}
	
	@Check
	def checkWrongNamedDeclBody(NamedCompDecl decl) {
		val String err = 
		switch (decl.type) {
			SvDecl: if (decl.body instanceof CompResBody)
				"Got resource component body, but component is a state variable"
				else null
			ResourceDecl: if (decl.body instanceof CompSVBody)
				"Got state variable component body, but component is a resource"
				else null
			default: null
		}
		if (err !== null)
			error(err,NAMED_COMP_DECL__BODY,-1,RES_WRONG_BODY);
	}
	
	@Check
	def checkRenewableConsumableHierarchy(NamedCompDecl decl) {
		if (decl.type instanceof ResourceDecl) {
			val body = decl.body;
			var ConstExpr val1 = null; var ConstExpr val2 = null;
			switch (body) {
				CompResBody: {val1 = body.val1; val2 = body.val2}
			}
			
			doCheckRenewableConsumableHierarchy(decl,val1,val2,decl.name,
				NAMED_COMP_DECL__TYPE);
		}
	}
	
	@Check
	def void checkBindListCollisions(BindList bl) {
		val cd = EcoreUtil2.getContainerOfType(bl,NamedCompDecl);
		if (cd !== null) {
			var vars = getVariables(cd?.type);
			val bound = new HashSet<ObjVarDecl>();
			for (var i = 0; i < bl.values.size(); i++) {
				val b = bl.values.get(i);

				val v = 
				if (b.name !== null) b.name
				else if (i<vars.size()) vars.get(i)
				else null;
				
				if (v !== null) {
 					if (bound.contains(v))					
						error(String.format("Variable '%s' bound multiple times",
							v.name),BIND_LIST__VALUES,i,BINDLIST_MULTIPLEVAR);
					bound.add(v);
				}
			}
		}
	}
	
	@Check
	def void checkBindListSize(CompBody body) {
		val bl = body.bindings;
		val cd = EcoreUtil2.getContainerOfType(body,NamedCompDecl);
		val varSize = if (cd !== null)
			getVariables(cd?.type).size()
			else 0;
		val blSize = if (bl?.values !== null) bl.values.size() else 0;
		var EObject errObj = bl;
		var errFeat = BIND_LIST__VALUES;
		if (bl === null) {
			errObj = body;
			errFeat = COMP_BODY__BINDINGS; 
		}
		if (varSize > blSize)
			error("Some component variables are left unbound",errObj,
				errFeat,BINDLIST_SOME_UNBOUND)
		else if (varSize < blSize)
			error("Too many elements in bind list",errObj,
				errFeat,BINDLIST_TOO_LARGE)
	}
	
	@Check
	def void checkBindListType(BindList bl) {
		val cd = EcoreUtil2.getContainerOfType(bl,NamedCompDecl);
		if (cd !== null) {
			var vars = getVariables(cd?.type);
			for (var i = 0; i < bl.values.size(); i++) {
				val b = bl.values.get(i);

				val v = 
				if (b.name !== null) b.name
				else if (i<vars.size()) vars.get(i)
				else null;
				
				if (v !== null && !areTypesCompatible(v.type,b.value.type))
					error(String.format("Component '%s' is not of type '%s'",
						b.value.name,v.type.name),BIND_LIST__VALUES,i,BINDLIST_INCOMP_TYPES);
			}
		}
	}	
	
	@Check
	def void checkSelfImport(ImportDecl decl) {
		val dom = EcoreUtil2.getContainerOfType(decl,Ghost)?.domain;
		if (dom !== null && dom == decl.importedNamespace)
			warning(String.format("Domain '%s' is importing itself",dom.name),
				IMPORT_DECL__IMPORTED_NAMESPACE,-1,SELF_IMPORT);
	}
	
	
	private def doCheckRenewableConsumableHierarchy(EObject decl, ConstExpr v1,
		ConstExpr v2, String name, EReference ref) {
		if (v1 === null && v2 === null)
			return;
		val parent = getParentType(decl);
		if (parent !== null && parent instanceof ResourceDecl) {
			val pv2 = (parent as ResourceDecl).body?.val2;
			if ((v2 === null || pv2 === null) && v2 !== pv2) {
				val msg = if (pv2 === null) "Consumable resource '%s' has a renewable resource as parent"
				else "Renewable resource '%s' has a consumable resource as parent";
				warning(String.format(msg,name),ref,RENEWABLE_CONSUMABLE_MIX);
			}
		}
	}
	
	
	// Expressions checks
	private def doCheckExpressions(EObject block) {
		new ExpressionValidator([message,source,feature,index,code,issueData|
			error(message,source,feature,index,code,issueData);
		],[message,source,feature,index,code,issueData|
			warning(message,source,feature,index,code,issueData);
		]).checkExpressions(block);
	}
	
	@Check
	def checkExpressions(SyncBody sb) {
		doCheckExpressions(sb);
	}
	
	@Check
	def checkExpressions(TransConstrBody tcb) {
		doCheckExpressions(tcb);
	}
	
	@Check
	def checkExpressions(InitSection sec) {
		doCheckExpressions(sec);
	}
}