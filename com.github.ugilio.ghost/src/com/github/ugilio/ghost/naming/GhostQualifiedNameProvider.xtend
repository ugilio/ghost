/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.naming

import org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.EcoreUtil2
import com.github.ugilio.ghost.ghost.DomainDecl
import org.eclipse.emf.ecore.EObject
import com.github.ugilio.ghost.ghost.Ghost
import com.github.ugilio.ghost.ghost.TransConstrBody
import com.github.ugilio.ghost.ghost.SyncBody
import com.github.ugilio.ghost.ghost.InitSection
import com.github.ugilio.ghost.ghost.ArgList
import com.github.ugilio.ghost.ghost.FormalParList
import com.github.ugilio.ghost.ghost.BindList
import com.github.ugilio.ghost.ghost.ProblemDecl
import com.github.ugilio.ghost.ghost.EnumLiteral
import com.github.ugilio.ghost.ghost.NameOnlyParList

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
			|| EcoreUtil2.getContainerOfType(obj,NameOnlyParList) !== null
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