package it.cnr.istc.ghost.naming

import org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.EcoreUtil2
import it.cnr.istc.ghost.ghost.DomainDecl
import org.eclipse.emf.ecore.EObject
import it.cnr.istc.ghost.ghost.Ghost
import it.cnr.istc.ghost.ghost.TransConstrBody
import it.cnr.istc.ghost.ghost.SyncBody
import it.cnr.istc.ghost.ghost.InitSection
import it.cnr.istc.ghost.ghost.ArgList
import it.cnr.istc.ghost.ghost.FormalParList
import it.cnr.istc.ghost.ghost.BindList
import it.cnr.istc.ghost.ghost.ProblemDecl
import it.cnr.istc.ghost.ghost.EnumLiteral

class GhostQualifiedNameProvider extends DefaultDeclarativeQualifiedNameProvider {


	private def getNamespaceRoot(EObject obj) {
		val root = EcoreUtil2.getContainerOfType(obj,Ghost);
		if (root.domain !== null)
			return QualifiedName.create(root.domain.name);
		if (root.problem !== null)
			return QualifiedName.create(root.problem.name);
		return null;
	}
	
	private def isLocal(EObject obj) {
		return EcoreUtil2.getContainerOfType(obj,TransConstrBody) !== null
			|| EcoreUtil2.getContainerOfType(obj,SyncBody) !== null
			|| EcoreUtil2.getContainerOfType(obj,InitSection) !== null
	}
	
	private def isInArgList(EObject obj) {
		return EcoreUtil2.getContainerOfType(obj,ArgList) !== null
			|| EcoreUtil2.getContainerOfType(obj,FormalParList) !== null
			|| EcoreUtil2.getContainerOfType(obj,BindList) !== null
	}
	
	override QualifiedName getFullyQualifiedName(EObject obj) {
		if (isLocal(obj) || isInArgList(obj))
			return null;
		return super.getFullyQualifiedName(obj);
	}

	def protected QualifiedName qualifiedName(Ghost decl) {
		return getNamespaceRoot(decl);
	}

	def protected QualifiedName qualifiedName(DomainDecl decl) {
		return QualifiedName.create(decl.name);
	}

	def protected QualifiedName qualifiedName(ProblemDecl decl) {
		return QualifiedName.create(decl.name);
	}
	
	//Enum literals names are at the resource scope
	def protected QualifiedName qualifiedName(EnumLiteral literal) {
		val root = getNamespaceRoot(literal);
		return
			if (root!==null)
				root.append(literal.name)
			else
				QualifiedName.create(literal.name);
	}
	
	override QualifiedName qualifiedName(Object ele) {
		return null;
	}
}