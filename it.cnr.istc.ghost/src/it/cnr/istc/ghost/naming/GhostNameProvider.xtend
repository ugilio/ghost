package it.cnr.istc.ghost.naming

import org.eclipse.emf.ecore.EObject
import it.cnr.istc.ghost.ghost.ImportDecl
import org.eclipse.xtext.nodemodel.util.NodeModelUtils

//FIXME: test this class
class GhostNameProvider {
	
	protected def static dispatch doGetObjName(ImportDecl obj) {
		val value = obj.importedNamespace;
		if (!value.eIsProxy)
			return value.name;
		//FIXME: this is hackish. Get value of the feature from the text node...
		val leaves = NodeModelUtils.getNode(obj).leafNodes.filter[!isHidden].toList;
		if (leaves.size>=2)
			return leaves.get(1).text;
		return null;
	}
	
	protected def static dispatch doGetObjName(EObject obj) {
		val feature = obj.eClass().getEStructuralFeature("name");
		if (feature !== null && String.equals(feature.getEType().getInstanceClass()))
			return obj.eGet(feature) as String;
		return null;
	}
	
	def static getObjName(EObject obj) {
		return doGetObjName(obj);
	}	
}