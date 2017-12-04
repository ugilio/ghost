/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.preprocessor

import com.google.inject.Inject
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.parsetree.reconstr.impl.NodeIterator
import org.eclipse.xtext.parsetree.reconstr.impl.TokenUtil
import org.eclipse.emf.ecore.EObject
import java.util.HashMap
import java.util.List
import java.util.ArrayList
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import com.github.ugilio.ghost.ghost.ValueDecl
import com.github.ugilio.ghost.ghost.TemporalRelation
import com.github.ugilio.ghost.ghost.Expression
import java.util.Set

class AnnotationProvider {
	@Inject
	protected TokenUtil tokenUtil;
	
	HashMap<Object,List<String>> annotations = new HashMap();
		
	private def Object getAnnotationTarget(Object obj) {
		switch (obj) {
			ValueDecl: return obj.eContainer
			//this is for @(!) before PointingMode.Comm that got into the manual...
			TemporalRelation: {
				val cont = obj.eContainer;
				if (cont instanceof Expression) {
					if (cont.left === null && cont.right !== null && cont.right.size>=1) return cont.right.get(0);
				}
			}
		}
		return obj;
	}
	
	private def Object addAnnotation(Object aObj, String text) {
		val obj = getAnnotationTarget(aObj);
		var list = annotations.get(obj);
		if (list === null) {
			list = new ArrayList<String>();
			annotations.put(obj,list);
		}
		list.add(text);
		return obj;
	}
	
	private def boolean isNl(char c) {
		return c == 0xa || c == 0xd;
	}
	
	private def String cleanText(String text) {
		if (text.startsWith("@(") && text.endsWith(")"))
			return text.substring(2,text.length-1);
		var i = text.length();
		while (i>0 && isNl(text.charAt(i-1)))
			i--;
		return text.substring(1,i); //skip initial '@'
	}
	
	def private boolean beginsAfter(EObject obj, INode node) {
		val objNode = NodeModelUtils.getNode(obj);
		return objNode !== null && objNode.getOffset() >= node.getOffset();
	}
	
	def setAnnotations(Object object, List<String> annotations) {
		this.annotations.put(object,annotations);
	}
	
	def addAnnotation(INode node) {
		val text = cleanText(node.text);
		val itr = new NodeIterator(node);
		while (itr.hasNext()) {
			val n = itr.next();
			if (tokenUtil.isToken(n)) {
				val obj = tokenUtil.getTokenOwner(n);
				if (beginsAfter(obj,node)) {
					return addAnnotation(obj,text);
				}
				//Else the container of the annotation is terminating
				throw new AnnotationProviderException("No element to annotate found");
			}
		}
		throw new AnnotationProviderException("No element to annotate found");
	}
	
	def void clear() {
		annotations.clear();
	}
	
	def List<String> getAnnotations(Object obj) {
		return annotations.get(obj);
	}
	
	def Set<Object> getAllAnnotatedObjects() {
		return annotations.keySet;
	}
		
	static class AnnotationProviderException extends Exception{
		new (String message) {
			super(message);
		}
		
	}
	
}