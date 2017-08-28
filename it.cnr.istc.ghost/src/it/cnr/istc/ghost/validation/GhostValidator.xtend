/*
 * generated by Xtext 2.10.0
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
		while (getParent(tmp)!=null) {
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
		return GhostNameProvider.getObjName(obj);
	}

	private def getByName(Object name, List<EObject> list) {
		if (name!=null)
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
			if (getByName(name,list) != o)
				error(String.format(msg,name),feat,list.indexOf(o),id);
		}
	}
	
	@Check
	def checkUniqueTopLevelDeclarations(Ghost ghost) {
		checkDuplicateIdentifiers(ghost,GHOST__DECLS,"Duplicate identifier '%s'",DUPLICATE_IDENTIFIER);
	}
	
	@Check
	def checkUniqueImports(Ghost ghost) {
		checkDuplicateIdentifiers(ghost,GHOST__IMPORTS,"Duplicate import '%s'",DUPLICATE_IMPORT);
	}
	
}