/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package it.cnr.istc.ghost.ui.contentassist

import com.google.common.base.Function
import it.cnr.istc.ghost.ghost.ConstLiteral
import it.cnr.istc.ghost.ghost.Expression
import it.cnr.istc.ghost.ghost.FormalPar
import it.cnr.istc.ghost.ghost.LocVarDecl
import it.cnr.istc.ghost.ghost.NamedPar
import it.cnr.istc.ghost.ghost.TransConstraint
import it.cnr.istc.ghost.ghost.ValueDecl
import org.eclipse.emf.ecore.EObject
import org.eclipse.jface.text.contentassist.ICompletionProposal
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import it.cnr.istc.ghost.ghost.ObjVarDecl
import it.cnr.istc.ghost.ghost.AnonResDecl
import it.cnr.istc.ghost.ghost.AnonSVDecl
import it.cnr.istc.ghost.ghost.NamedCompDecl

class GhostProposalCreator implements Function<IEObjectDescription, ICompletionProposal> {

	private static int REF_PRI = 500;
	protected static int topPriority = REF_PRI+100;
	protected static int highPriority = REF_PRI+70;
	protected static int medPriority = REF_PRI+50;
	protected static int lowPriority = REF_PRI+30;
	protected static int bottomPriority = REF_PRI+10;

	EObject model;
	Function<IEObjectDescription, ICompletionProposal> delegate;

	new (ContentAssistContext contentAssistContext, String ruleName,
		IQualifiedNameConverter qualifiedNameConverter,
		Function<IEObjectDescription, ICompletionProposal> delegate) {
			this.delegate = delegate;
			this.model = contentAssistContext.currentModel;
	}
	
	private def void adjustPriority(ConfigurableCompletionProposal p, EObject obj) {
		switch (obj) {
			ValueDecl: if (EcoreUtil2.getContainerOfType(model,TransConstraint) !== null)
				p.priority = topPriority
			FormalPar, NamedPar, LocVarDecl: p.priority = highPriority
			ConstLiteral: if (EcoreUtil2.getContainerOfType(model,Expression) !== null)
				p.priority = medPriority
		}
	}
		
	private def void adjustDescription(ConfigurableCompletionProposal p, EObject obj) {
		if (obj.eIsProxy)
			return;
		val argStr = 
		switch (obj) {
			ValueDecl: if (obj.parlist?.values !== null) obj.parlist.values.join("(",", ",")",[v|v.type.name]) else null
			default: null 
		}
		val String extraStr = 
		switch (obj) {
			ObjVarDecl: obj.type.name
			AnonResDecl: "resource" 
			AnonSVDecl: "sv" 
			NamedCompDecl: obj.type.name
			default : null 
		}
		if (argStr !== null)
			p.displayString = p.replacementString+argStr;
		if (extraStr !== null)
			p.displayString = p.replacementString+": "+extraStr; 
	}
	
	override apply(IEObjectDescription t) {
		val result = delegate.apply(t);
		if (result instanceof ConfigurableCompletionProposal) {
			adjustPriority(result,t.getEObjectOrProxy());
			adjustDescription(result,t.getEObjectOrProxy());
		}
		return result;
	}
	
}