package it.cnr.istc.ghost.naming

import org.eclipse.emf.ecore.EObject
import it.cnr.istc.ghost.ghost.ImportDecl
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import it.cnr.istc.ghost.ghost.SimpleInstVal
import it.cnr.istc.ghost.ghost.ResSimpleInstVal
import it.cnr.istc.ghost.ghost.InheritedKwd

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
	
	protected def static dispatch doGetObjName(SimpleInstVal obj) {
		return obj?.value?.name;
	}
	
	protected def static dispatch doGetObjName(ResSimpleInstVal obj) {
		return if (obj?.type !== null) obj.type.toString else null;
	}
	
	protected def static dispatch doGetObjName(InheritedKwd obj) {
		return 'inherited';
	}
	
	def static getObjName(EObject obj) {
		return doGetObjName(obj);
	}	
}