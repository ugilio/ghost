/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * generated by Xtext 2.12.0
 */
package com.github.ugilio.ghost.ui.labeling

import com.google.inject.Inject
import org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider
import org.eclipse.xtext.ui.label.DefaultEObjectLabelProvider
import com.github.ugilio.ghost.naming.GhostNameProvider
import org.eclipse.emf.ecore.EObject
import com.github.ugilio.ghost.ghost.InitSection
import com.github.ugilio.ghost.ghost.SimpleInstVal
import com.github.ugilio.ghost.ghost.ValueDecl
import com.github.ugilio.ghost.ghost.ObjVarDecl
import com.github.ugilio.ghost.ghost.ResSimpleInstVal
import org.eclipse.xtext.linking.lazy.LazyLinkingResource
import org.eclipse.emf.ecore.util.EcoreUtil
import com.github.ugilio.ghost.ghost.TransConstraint
import com.github.ugilio.ghost.ghost.Synchronization

/**
 * Provides labels for EObjects.
 * 
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#label-provider
 */
class GhostLabelProvider extends DefaultEObjectLabelProvider {
	
	@Inject
	private GhostImageProvider imageProvider;

	@Inject
	new(AdapterFactoryLabelProvider delegate) {
		super(delegate);
	}

	// Labels and icons can be computed like this:
	
	def text(EObject obj) {
		return GhostNameProvider.getObjName(obj);
	}
	
	private def String getReferenceName(EObject context, EObject obj) {
		if (obj === null) return "";
		if (!obj.eIsProxy)
			return GhostNameProvider.getObjName(obj);
		val res = context.eResource;
		if (res instanceof LazyLinkingResource) {
			val enc = res.encoder;
			val triple = enc?.decode(res,EcoreUtil.getURI(obj).fragment);
			val node = triple?.third;
			if (node !== null)
				return node.getText.trim();
		}
		return "";
	}
	
	def text(InitSection init) {
		return "init";
	}
	
	def text(TransConstraint c) {
		return doGetText(c.head);
	}
	
	def text(ValueDecl decl) {
		val args = if (decl.parlist === null) "()"
			else "("+decl.parlist.values.map[p|getReferenceName(p,p.type)].join(", ")+")";
		return decl.name+args;
	}
	
	def text(Synchronization s) {
		return doGetText(s.trigger);
	}
	
	def text(SimpleInstVal v) {
		val args = if (v.arglist === null) "()"
			else "("+v.arglist.values.map[a|a.name].join(", ")+")";
		return v.value?.name+args;
	}
	
	def text(ResSimpleInstVal v) {
		return v.type.toString+"("+v.arg.name+")";
	}
	
	def text(ObjVarDecl d) {
		return d.name+": "+getReferenceName(d,d.type);
	}
	

	def image(EObject obj) {
		imageProvider.image(obj);
	}
	
	override getImage(Object element) {
		val image = convertToImage(doGetImage(element));
		if (image !== null)
			return image;
		//suppress delegation
		return convertToImage(getDefaultImage());
	}
	
}
