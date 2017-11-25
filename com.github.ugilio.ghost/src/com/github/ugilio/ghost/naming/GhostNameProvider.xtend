/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.naming

import org.eclipse.emf.ecore.EObject
import com.github.ugilio.ghost.ghost.ImportDecl
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import com.github.ugilio.ghost.ghost.SimpleInstVal
import com.github.ugilio.ghost.ghost.ResSimpleInstVal
import com.github.ugilio.ghost.ghost.InheritedKwd

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