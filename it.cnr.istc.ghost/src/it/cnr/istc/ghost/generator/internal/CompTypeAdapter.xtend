/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package it.cnr.istc.ghost.generator.internal

import org.eclipse.emf.ecore.EObject
import java.util.List
import it.cnr.istc.ghost.ghost.ObjVarDecl
import it.cnr.istc.ghost.ghost.Externality

interface CompTypeAdapter {
	def EObject getParent();
	def EObject getReal();
	def Externality getExternality();
	def String getName(Register register);
	def List<it.cnr.istc.ghost.ghost.Synchronization> getDeclaredSynchronizations();
	def List<ObjVarDecl> getDeclaredVariables();
}
