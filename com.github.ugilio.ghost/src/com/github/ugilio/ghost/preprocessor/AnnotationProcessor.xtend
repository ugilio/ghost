/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.preprocessor

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.diagnostics.IDiagnosticProducer
import com.github.ugilio.ghost.services.GhostGrammarAccess
import com.google.inject.Inject
import com.google.common.collect.Sets
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.nodemodel.INode
import com.github.ugilio.ghost.ghost.QualifInstVal
import com.github.ugilio.ghost.ghost.LocVarDecl
import com.github.ugilio.ghost.ghost.CompDecl
import com.github.ugilio.ghost.ghost.TransConstraint
import com.github.ugilio.ghost.ghost.TriggerType
import com.github.ugilio.ghost.ghost.ComponentType
import org.eclipse.xtext.diagnostics.DiagnosticMessage
import org.eclipse.xtext.diagnostics.Severity
import com.github.ugilio.ghost.preprocessor.AnnotationProvider.AnnotationProviderException
import org.eclipse.xtext.util.Strings

class AnnotationProcessor {
	public static val ANNOTATION_ERROR = 'annotationError';
	public static val ANNOTATION_UNKNOWN_TARGET = "annotationUnknownTarget";
	
	@Inject
	GhostGrammarAccess grammarAccess;
	@Inject
	AnnotationProvider annProvider;
	
	public def processAnnotations(EObject model, IDiagnosticProducer p) {
		val ga = (grammarAccess as GhostGrammarAccess);
		val annRules = Sets.newHashSet(ga.SL_ANNOTATIONRule,ga.BR_ANNOTATIONRule);
		val root = NodeModelUtils.getNode(model);
		root.asTreeIterable.
			filter[annRules.contains(grammarElement)].
			forEach(n | processAnnotation(n,p));
	}
	
	private def void checkAnnotationTarget(Object obj, INode node, IDiagnosticProducer p) {
		val known = switch(obj) {
			QualifInstVal: true
			LocVarDecl: true
			ComponentType: true
			CompDecl: true
			TransConstraint: true
			TriggerType: true
			default: false
		}
		if (!known) {
			p.node = node;
			p.addDiagnostic(new DiagnosticMessage(
				"Not a valid annotation target: the annotation will be ignored",
				Severity.WARNING,ANNOTATION_UNKNOWN_TARGET));
			}
	}

	private def processAnnotation(INode node, IDiagnosticProducer p) {
		try {
			val target = annProvider.addAnnotation(node);
			checkAnnotationTarget(target,node,p);
		}
		catch (AnnotationProviderException e) {
			p.node = node;
			if (!Strings.isEmpty(e.message))
				p.addDiagnostic(new DiagnosticMessage(
					e.message,Severity.ERROR,ANNOTATION_ERROR));
		}
	}	
}