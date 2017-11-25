/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.scoping

import org.eclipse.xtext.scoping.impl.ImportedNamespaceAwareLocalScopeProvider
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.scoping.IScope
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.scoping.impl.FilteringScope
import com.google.inject.Inject
import org.eclipse.xtext.util.IResourceScopeCache
import org.eclipse.xtext.util.Tuples
import com.google.inject.Provider
import java.util.HashSet
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.IEObjectDescription
import com.github.ugilio.ghost.ghost.Ghost
import com.github.ugilio.ghost.ghost.GhostPackage

class GhostImportScopeProvider extends ImportedNamespaceAwareLocalScopeProvider {
	//consider wildcards always on
	override ImportNormalizer doCreateImportNormalizer(QualifiedName importedNamespace, boolean wildcard, boolean ignoreCase) {
		super.doCreateImportNormalizer(importedNamespace,true,ignoreCase);
	}
	
	//Allow importedNamespace from non-string features
	override getImportedNamespace(EObject object){
		val feature = object.eClass().getEStructuralFeature("importedNamespace");
		if (feature !== null) {
			if (String.equals(feature.EType.instanceClass))
				return object.eGet(feature) as String;
			//FIXME: this is hackish. Get value of the feature from the text node...
			val leaves = NodeModelUtils.getNode(object).leafNodes.filter[!isHidden].toList;
			if (leaves.size>=2)
				return leaves.get(1).text;
		}
		return null;
	}
	
	override getLocalElementsScope(IScope parent, EObject context, EReference reference) {
		val scope = super.getLocalElementsScope(parent,context,reference);
		//local resource contents have higher precedence than imported stuff!
		if (context instanceof Ghost && reference != GhostPackage.Literals.IMPORT_DECL__IMPORTED_NAMESPACE)
			return getResourceScope(scope, context, reference);
		return scope;
	}

	//Filter out elements from global scope that don't belong to imported domains
	@Inject
	private IResourceScopeCache cache = IResourceScopeCache.NullImpl.INSTANCE;
	
	def protected HashSet<String> getImports(Resource res) {
		return cache.get(Tuples.create(res, "imports"), res, new Provider<HashSet<String>>() {
			override HashSet<String> get() {
				val root = res?.contents?.get(0);
				val names = getImportedNamespaceResolvers(root,false).
					map[n | n.importedNamespacePrefix.toString];
				return new HashSet<String>(names);
			}
		});
	}
	
	def isVisible(EObject context, IEObjectDescription desc) {
		val res = context.eResource;
		return context.eResource == desc.EObjectOrProxy.eResource || 
			getImports(res).contains(desc.qualifiedName.firstSegment);
	}
	
	def IScope filterNotImported(EObject context, EReference reference, IScope scope) {
		return new FilteringScope(scope,[o | isVisible(context,o)]);
	}
	
	override IScope getScope(EObject context, EReference reference) {
		val scope = super.getScope(context, reference);
		if (reference == GhostPackage.Literals.IMPORT_DECL__IMPORTED_NAMESPACE)
			return scope;
		return filterNotImported(context,reference,scope);
	}
	
}