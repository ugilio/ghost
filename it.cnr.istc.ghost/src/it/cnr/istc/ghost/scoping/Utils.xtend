package it.cnr.istc.ghost.scoping

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2
import it.cnr.istc.ghost.ghost.Synchronization
import it.cnr.istc.ghost.ghost.NamedPar
import java.util.Collections
import it.cnr.istc.ghost.ghost.LocVarDecl
import com.google.common.collect.Iterables
import it.cnr.istc.ghost.ghost.SyncBody
import it.cnr.istc.ghost.ghost.TransConstrBody
import it.cnr.istc.ghost.ghost.TransConstraint
import it.cnr.istc.ghost.ghost.FormalPar

class Utils {
	
	public static def getSymbolsForBlock(EObject context) {
		//Inside a synchronization body
		val syncbody = EcoreUtil2.getContainerOfType(context,SyncBody);
		if (syncbody !== null) {
			val trigger = (syncbody.eContainer as Synchronization).trigger;
			val args = if (trigger !== null) EcoreUtil2.eAllOfType(trigger,NamedPar)
						else Collections.emptyList;
			val locVars = EcoreUtil2.eAllOfType(syncbody,LocVarDecl);
			return Iterables.concat(args,locVars);
		}
		//Inside a transition constraint body
		val tcbody = EcoreUtil2.getContainerOfType(context,TransConstrBody);
		if (tcbody !== null) {
			val head = (tcbody.eContainer as TransConstraint).head;
			val args = if (head !== null) EcoreUtil2.eAllOfType(head,FormalPar)
						else Collections.emptyList;
			val locVars = EcoreUtil2.eAllOfType(tcbody,LocVarDecl);
			return Iterables.concat(args,locVars);
		}
		return null;
	}
	
}