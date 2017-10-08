/*
 * generated by Xtext 2.12.0
 */
package it.cnr.istc.ghost.validation

import static it.cnr.istc.ghost.ghost.GhostPackage.Literals.*;

import org.eclipse.xtext.validation.Check
import it.cnr.istc.ghost.ghost.SvDecl
import java.util.HashSet
import it.cnr.istc.ghost.ghost.ResourceDecl
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import it.cnr.istc.ghost.ghost.EnumDecl
import java.util.List
import org.eclipse.emf.ecore.EStructuralFeature
import it.cnr.istc.ghost.ghost.Ghost
import it.cnr.istc.ghost.naming.GhostNameProvider
import it.cnr.istc.ghost.ghost.ResSimpleInstVal
import org.eclipse.xtext.EcoreUtil2
import it.cnr.istc.ghost.ghost.ResourceBody
import it.cnr.istc.ghost.ghost.CompResBody
import it.cnr.istc.ghost.ghost.QualifInstVal
import it.cnr.istc.ghost.ghost.ValueDecl
import it.cnr.istc.ghost.ghost.SimpleInstVal
import it.cnr.istc.ghost.ghost.Synchronization
import it.cnr.istc.ghost.ghost.NamedCompDecl
import it.cnr.istc.ghost.ghost.InheritedKwd
import it.cnr.istc.ghost.ghost.TransConstraint
import it.cnr.istc.ghost.ghost.TransConstrBody
import it.cnr.istc.ghost.ghost.SyncBody
import it.cnr.istc.ghost.ghost.SvBody
import it.cnr.istc.ghost.ghost.CompSVBody
import it.cnr.istc.ghost.ghost.TriggerType
import it.cnr.istc.ghost.ghost.CompBody
import it.cnr.istc.ghost.ghost.ObjVarDecl
import it.cnr.istc.ghost.ghost.FormalParList
import it.cnr.istc.ghost.ghost.NameOnlyParList
import it.cnr.istc.ghost.scoping.Utils
import it.cnr.istc.ghost.ghost.LocVarDecl
import it.cnr.istc.ghost.ghost.ResConstr
import it.cnr.istc.ghost.ghost.AnonResDecl
import it.cnr.istc.ghost.ghost.AnonSVDecl
import it.cnr.istc.ghost.ghost.ConstExpr

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
	public static val SYNCH_INVALID_PARNUM = "synchInvalidParNum";
	public static val QUALIFINSTVAL_INCOMPATIBLE_COMP = "qualifInstValIncompatibleComp";
	public static val QUALIFINSTVAL_INCOMPATIBLE_ARGS = "qualifInstValIncompatibleArgs";
	public static val RESCONSTR_INCOMPATIBLE_COMP = "resConstrIncompatibleComp";
	public static val INHERITANCE_INCOMPATIBLE_PARAMS = "inheritanceIncompatibleParams";
	public static val INHERITED_KWD_NO_ANCESTOR = "inheritedKwdNoAncestor";
	public static val RENEWABLE_CONSUMABLE_MIX = "renewableConsumableMix";
	public static val RECURSIVE_VARDECL = "recursiveVarDecl";
	public static val EXPECTED_TYPE = "expectedType";
	public static val BOOLEAN_TO_NUMERIC = "booleanToNumeric";
	public static val COMPARISON_DIFFERENT_TYPES = "comparisonDifferentTypes";

	// Checks for type hierarchy

	private def dispatch EObject getParent(SvDecl decl) {
		return decl.parent;
	}

	private def dispatch EObject getParent(ResourceDecl decl) {
		return decl.parent;
	}
	
	private def dispatch EObject getParent(Object o) {
		return null;
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
						it.cnr.istc.ghost.validation.GhostValidator.CYCLIC_HIERARCHY)
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
		val syms = Utils.getSymbolsForBlock(body);
		val vars = syms.filter[o|o instanceof LocVarDecl];
		checkDuplicateIdentifiers(syms,vars,
			TRANS_CONSTR_BODY__VALUES,
			"Duplicate identifier '%s'",DUPLICATE_IDENTIFIER);
	}
	
	@Check
	def checkUniqueLocVars(SyncBody body) {
		val syms = Utils.getSymbolsForBlock(body);
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
			if (v.comp !== null)
				error(String.format("Cannot find value '%s' in '%s'",v.value.name,v.comp.name),
					 QUALIF_INST_VAL__VALUE,QUALIFINSTVAL_INCOMPATIBLE_COMP);
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
				NamedCompDecl: (res as NamedCompDecl).type
				ObjVarDecl: (res as ObjVarDecl).type
				default : null
			}
		if (type instanceof ResourceDecl)
			return;
		val errType = if ((type instanceof SvDecl) || (res instanceof AnonSVDecl)) "state variable component"
			else "unknown type";
		error(String.format("Resource component expected, but %s found",errType),
			RES_CONSTR__RES,RESCONSTR_INCOMPATIBLE_COMP);
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
	
	private def getParentType(EObject o) {
		if (o === null)
			return null;
		//we are in a component with a type, find the type
		val comp = EcoreUtil2.getContainerOfType(o,NamedCompDecl);
		if (comp !== null && comp.type instanceof SvDecl)
			return comp.type
		else if (comp !== null && comp.type instanceof ResourceDecl)
			return comp.type
		else {
		//we are in a type, find the parent, if any
			val type = EcoreUtil2.getContainerOfType(o,SvDecl)?.parent;
			if (type !== null)
				return type;
			return EcoreUtil2.getContainerOfType(o,ResourceDecl)?.parent;
		}
	}	
	
	
	private def getParentValue(ValueDecl o) {
		val name = o?.name;
		if (name === null || o === null)
			return null;
		var type = getParentType(o) as SvDecl;

		while (type !== null) {
			val parentVal = EcoreUtil2.eAllOfType(type,ValueDecl).filter[v|v.name==name].head;
			if (parentVal !== null) {
				//found the value we are inheriting from.
				return parentVal;
			}
			type = type.parent;
		}
		return null;			
	}
	
	private def dispatch getParentSync(SimpleInstVal o) {
		val name = o?.value?.name;
		if (name === null || o === null)
			return null;
		var type = getParentType(o) as SvDecl;
			
		while (type !== null) {
			val parentSync = EcoreUtil2.eAllOfType(type,SimpleInstVal).filter[v|v?.value?.name==name].head;
			if (parentSync !== null) {
				//found the sync we are inheriting from.
				return parentSync;
			}
			type = type.parent;
		}
		return null;			
	}		
	
	private def dispatch getParentSync(ResSimpleInstVal o) {
		val action = o?.type;
		if (action === null || o === null)
			return null;
		var type = getParentType(o) as ResourceDecl;

		while (type !== null) {
			val parentSync = EcoreUtil2.eAllOfType(type,ResSimpleInstVal).filter[v|v?.type==action].head;
			if (parentSync !== null) {
				//found the sync we are inheriting from.
				return parentSync;
			}
			type = type.parent;
		}
		return null;			
	}	
		
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
					val pn = if (p.type?.name === null) "<error>" else p.type.name; 
					val tn = if (t.type?.name === null) "<error>" else t.type.name; 
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
	def checkRenewableConsumableHierarchy(ResourceDecl decl) {
		doCheckRenewableConsumableHierarchy(decl,decl.body?.val2,decl.name,RESOURCE_DECL__PARENT);
	}
	
	@Check
	def checkRenewableConsumableHierarchy(NamedCompDecl decl) {
		if (decl.type instanceof ResourceDecl)
			doCheckRenewableConsumableHierarchy(decl,
				(decl.body as CompResBody)?.val2,decl.name,NAMED_COMP_DECL__TYPE
			);
	}
	
	private def doCheckRenewableConsumableHierarchy(EObject decl, ConstExpr v2,
		String name, EReference ref) {
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
}
