package it.cnr.istc.ghost.naming

import org.eclipse.xtext.resource.DefaultLocationInFileProvider
import org.eclipse.emf.ecore.EObject
import it.cnr.istc.ghost.ghost.TransConstraint
import it.cnr.istc.ghost.ghost.Synchronization
import it.cnr.istc.ghost.ghost.ResSimpleInstVal
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import it.cnr.istc.ghost.ghost.GhostPackage

class GhostLocationInFileProvider extends DefaultLocationInFileProvider {

	override getSignificantTextRegion(EObject obj) {
		var target = 
		switch (obj) {
			TransConstraint: obj.head
			Synchronization: obj.trigger 
			default: obj
		}
		return super.getSignificantTextRegion(target);
	}
	
	override getLocationNodes(EObject obj) {
		if (obj instanceof ResSimpleInstVal) {
			val nodes = NodeModelUtils.findNodesForFeature(obj,
				GhostPackage.Literals.RES_SIMPLE_INST_VAL__TYPE);
			if (!nodes.isEmpty)
				return nodes;
		}
		return super.getLocationNodes(obj)
	}
	
	
}