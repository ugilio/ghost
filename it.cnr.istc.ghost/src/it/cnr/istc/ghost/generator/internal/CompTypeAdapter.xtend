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
