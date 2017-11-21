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
		
	override apply(IEObjectDescription t) {
		val result = delegate.apply(t);
		if (result instanceof ConfigurableCompletionProposal)
			adjustPriority(result,t.getEObjectOrProxy());
		return result;
	}
	
}