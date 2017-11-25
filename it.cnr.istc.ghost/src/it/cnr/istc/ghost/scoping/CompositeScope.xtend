/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package it.cnr.istc.ghost.scoping

import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.emf.ecore.EObject
import java.util.List
import java.util.ArrayList

class CompositeScope implements IScope {
	private List<IScope> scopes; 
	
	new(IScope... elements) {
		scopes = new ArrayList(elements);
	}
	
	override getAllElements() {
		return scopes.map[s|s.allElements].flatten;
	}
	
	override getElements(QualifiedName name) {
		return scopes.map[s|s.getElements(name)].flatten;
	}
	
	override getElements(EObject object) {
		return scopes.map[s|s.getElements(object)].flatten;
	}
	
	override getSingleElement(QualifiedName name) {
		return scopes.map[s|s.getSingleElement(name)].filter[s|s!==null].head;
	}
	
	override getSingleElement(EObject object) {
		return scopes.map[s|s.getSingleElement(object)].filter[s|s!==null].head;
	}
	
}