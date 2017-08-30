package it.cnr.istc.ghost.scoping

import org.eclipse.xtext.resource.impl.DefaultResourceDescriptionStrategy
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.util.IAcceptor
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.EcoreUtil2
import it.cnr.istc.ghost.ghost.Ghost

/**
 * Only export contents of domain files
 */
class GhostResourceDescriptionStrategy extends DefaultResourceDescriptionStrategy {
	
	private def isInDomain(EObject obj) {
		return EcoreUtil2.getContainerOfType(obj,Ghost)?.domain !== null;
	}
	
	override createEObjectDescriptions(EObject eObject, IAcceptor<IEObjectDescription> acceptor) {
		if (isInDomain(eObject))
			return super.createEObjectDescriptions(eObject,acceptor);
		return false;
	}
}