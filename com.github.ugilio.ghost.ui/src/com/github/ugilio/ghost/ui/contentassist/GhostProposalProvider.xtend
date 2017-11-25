/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * generated by Xtext 2.12.0
 */
package com.github.ugilio.ghost.ui.contentassist

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import com.github.ugilio.ghost.services.GhostGrammarAccess
import com.google.inject.Inject
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.EcoreUtil2
import com.github.ugilio.ghost.ghost.TransConstraint
import com.github.ugilio.ghost.ghost.Expression
import org.eclipse.xtext.CrossReference
import com.github.ugilio.ghost.ghost.CompRef
import com.github.ugilio.ghost.ghost.ValueDecl
import com.github.ugilio.ghost.ghost.LocVarDecl
import com.github.ugilio.ghost.ghost.TimePointOp
import com.github.ugilio.ghost.ghost.ConstDecl
import com.github.ugilio.ghost.ghost.FormalPar
import com.github.ugilio.ghost.ghost.NamedPar
import com.github.ugilio.ghost.ghost.EnumDecl
import org.eclipse.xtext.Keyword
import org.eclipse.emf.ecore.EReference
import com.google.common.base.Predicate
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.jface.text.contentassist.ICompletionProposal
import com.google.common.base.Function
import com.github.ugilio.ghost.utils.Utils
import com.github.ugilio.ghost.ghost.SyncBody
import com.github.ugilio.ghost.ghost.TransConstrBody
import com.github.ugilio.ghost.validation.ExpressionValidator
import org.eclipse.xtext.util.IResourceScopeCache
import org.eclipse.xtext.util.Tuples
import com.google.inject.Provider
import java.util.HashMap
import com.github.ugilio.ghost.validation.AbstractExpressionValidator.ResultType
import com.github.ugilio.ghost.ghost.Synchronization
import com.github.ugilio.ghost.ghost.NumAndUnit
import com.github.ugilio.ghost.ghost.QualifInstVal
import com.github.ugilio.ghost.ghost.FactGoal
import com.github.ugilio.ghost.ghost.ResConstr
import com.github.ugilio.ghost.ghost.NamedCompDecl
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import com.github.ugilio.ghost.ghost.BindPar
import com.github.ugilio.ghost.ghost.ObjVarDecl
import com.github.ugilio.ghost.ghost.BindList
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal

/**
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#content-assist
 * on how to customize the content assistant.
 */
class GhostProposalProvider extends AbstractGhostProposalProvider {
	
	@Inject
	protected GhostGrammarAccess grammar;
	
	@Inject
	protected GhostReferenceProposalCreator crossReferenceProposalCreator;
	
	@Inject
	protected IResourceScopeCache cache;

	override complete_TopLevelDeclaration(EObject model, RuleCall ruleCall, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		completeKeyword(grammar.externalityAccess.PLANNEDPlannedKeyword_1_0,context,acceptor);
		completeKeyword(grammar.externalityAccess.EXTERNALExternalKeyword_2_0,context,acceptor);
	}
	
	override complete_TransConstraint(EObject model, RuleCall ruleCall, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		completeKeyword(grammar.controllabilityAccess.CONTROLLABLEContrKeyword_2_0,context,acceptor);
		completeKeyword(grammar.controllabilityAccess.UNCONTROLLABLEUncontrKeyword_3_0,context,acceptor);
	}
	
	override completeKeyword(Keyword keyword, ContentAssistContext contentAssistContext,
			ICompletionProposalAcceptor acceptor) {
		val obj = contentAssistContext.currentModel;
		val prevObj = contentAssistContext.previousModel;
		val inSyncTrigger = 
		contentAssistContext.firstSetGrammarElements.filter(RuleCall).
			exists[r|r?.rule==grammar.triggerTypeRule];
		
		var ICompletionProposalAcceptor theAcceptor = acceptor;
		
		if (inSyncTrigger) {
			if (keyword == grammar.resourceActionAccess.PRODUCEProduceKeyword_1_0 || 
				keyword == grammar.resourceActionAccess.CONSUMEConsumeKeyword_2_0)
				if (!Utils.isInConsumable(obj))
					return;
			if (keyword == grammar.resourceActionAccess.REQUIRERequireKeyword_0_0)
				if (!Utils.isInResource(obj) || Utils.isInConsumable(obj))
					return;
			
			theAcceptor = new ICompletionProposalAcceptor.Delegate(acceptor){
				override accept(ICompletionProposal p) {
					super.accept(p);
					configureResSimpleInstVal_Proposal(p,contentAssistContext);
				}
			};
		}
		if (keyword == grammar.thisKwdAccess.thisKeyword_1) {
			if (EcoreUtil2.getContainerOfType(obj,Synchronization)===null)
				return;
		}
		val inTC = EcoreUtil2.getContainerOfType(obj,TransConstraint)!==null;
		if (inTC && isResAction(keyword))
			return;
		if (inTC && isTimeOpKeyword(keyword))
			return;
		if ((isArithExp(obj) || isArithExp(prevObj)) && !isArithOperator(keyword))
			return; //no keywords in arithmetic expressions
		
		super.completeKeyword(keyword, contentAssistContext, theAcceptor);
	}
	
	private def void configureResSimpleInstVal_Proposal(ICompletionProposal p,
		ContentAssistContext context) {
		if (p instanceof ConfigurableCompletionProposal) {
			p.textApplier = [doc,prop|
				val toAdd= "(amount) -> ";
				val selStart = prop.replacementOffset + prop.cursorPosition +1;
				val selLength = "amount".length; 
				prop.cursorPosition=prop.cursorPosition+toAdd.length;
				doc.replace(prop.getReplacementOffset(),
					prop.getReplacementLength(),
					prop.getReplacementString()+toAdd
				);
				prop.selectionStart = selStart;
				prop.selectionLength = selLength;
				if (context !== null)
					prop.setSimpleLinkedMode(context.viewer,"\n");
			];
		}
	}
		
	private def boolean isTimeOpKeyword(Keyword keyword) {
		switch (keyword) {
			case grammar.timePointSelectorAccess.STARTStartKeyword_0_0,
			case grammar.timePointSelectorAccess.ENDEndKeyword_1_0: true
			default : false
		}
	}
	
	private def boolean isArithOperator(Keyword keyword) {
		val s = keyword.value;
		return "+*-/%<>=".indexOf(s) != -1 || (s == '<=') || (s == '>=') || (s == '!=');
	}
	
	private def boolean isResAction(Keyword keyword) {
		switch (keyword) {
			case grammar.resourceActionAccess.PRODUCEProduceKeyword_1_0,
			case grammar.resourceActionAccess.CONSUMEConsumeKeyword_2_0,
			case grammar.resourceActionAccess.REQUIRERequireKeyword_0_0 : true
			default : false
		}
	}

	//no components in transition constraints	
	override completeQualifInstVal_Comp(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		if (EcoreUtil2.getContainerOfType(model,TransConstraint)===null && !(isArithExp(model)))
			super.completeQualifInstVal_Comp(model, assignment, context, acceptor);
	}
	
	private def getVarMap(LocVarDecl context) {
		var EObject body = EcoreUtil2.getContainerOfType(context,SyncBody);
		if (body === null)
			body = EcoreUtil2.getContainerOfType(context,TransConstrBody);
		val b = body;
		return cache.get(Tuples.create(body,"varTypes"),context.eResource,
			new Provider<HashMap<String,ResultType>>(){
			override get() {
				return new ExpressionValidator(null,null).determineLocVarTypes(b);
			}
		});
	}
	
	private def getVarType(LocVarDecl v) {
		return getVarMap(v).get(v.name);
	}
	
	private def isTemporalVar(LocVarDecl v) {
		return
		switch (getVarType(v)) {
			case INSTVAL, case TIMEPOINT, case UNKNOWN: true
			default: false
		}
	}
	
	private def isNumericalVar(LocVarDecl v) {
		return
		switch (getVarType(v)) {
			case NUMERIC, case BOOLEAN, case UNKNOWN: true
			default: false
		}
	}
	
	private def isTemporalExp(EObject obj) {
		val exp = EcoreUtil2.getContainerOfType(obj,Expression);
		return (exp?.op !== null || EcoreUtil2.getContainerOfType(obj,TimePointOp)!==null);
	}
	
	private def isFactGoal(EObject obj) {
		return EcoreUtil2.getContainerOfType(obj,FactGoal) !== null;
	}
	
	private def isArithExp(EObject obj) {
		var exp = EcoreUtil2.getContainerOfType(obj,Expression);
		if (exp?.ops === null || exp.ops.size()==0) {
			val l = switch (exp) {
				QualifInstVal: exp.value
				default: exp?.left
			}
			return
			switch (l) {
				NumAndUnit: true
				ConstDecl: true
				FormalPar: !(l.type instanceof EnumDecl)
				NamedPar: !(l.type instanceof EnumDecl)
				LocVarDecl: isNumericalVar(l)
				default: false
			}
		}
		return
		switch (exp.ops.get(0)) {
			case '=', case '!=' : false
			default : true
		}
	}
	
	override completeQualifInstVal_Value(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		//in temporal expression, reference only temporal entities
		if (isTemporalExp(model) || isFactGoal(model)) {
			lookupCrossReference(assignment.getTerminal() as CrossReference, context, acceptor,
				[od| val obj = od.EObjectOrProxy; switch (obj) {
					CompRef: true
					ValueDecl: true
					LocVarDecl: isTemporalVar(obj)
					default : false
				}]
			);
		}
		//in arithmetic expressions, reference only numerical entities
		else if (isArithExp(model)) {
			lookupCrossReference(assignment.getTerminal() as CrossReference, context, acceptor,
				[od| val obj = od.EObjectOrProxy; switch (obj) {
					ConstDecl: true
					FormalPar: !(obj.type instanceof EnumDecl)
					NamedPar: !(obj.type instanceof EnumDecl)
					LocVarDecl: isNumericalVar(obj)
					default : false
				}]
			);
		}
		else super.completeQualifInstVal_Value(model, assignment, context, acceptor);
	}
	
	override completeResConstr_Res(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		if (model instanceof ResConstr) {
			val action = model.type;
			val needsConsumable = 
			switch (action) {
				case REQUIRE: false
				default: true
			}
			lookupCrossReference(assignment.getTerminal() as CrossReference, context, acceptor,
				[od| val obj = od.EObjectOrProxy;
					Utils.isResource(obj) && needsConsumable == Utils.isConsumable(obj) 
				]
			);			
		}
		else super.completeResConstr_Res(model, assignment, context, acceptor);
	}
	
	private def boolean isErrNode(INode node) {
		return node.syntaxErrorMessage !== null;
	}
	
	private def EObject getNearestObject_NoErr(INode theNode) {
		var node = theNode;
		var parent = theNode.parent;
		while (node !== null || parent !== null) {
			while (node !== null) {
				val obj = NodeModelUtils.findActualSemanticObjectFor(node);
				if (obj !== null)
					return obj;
				node = node.previousSibling;
			}
			node = parent?.lastChild;
			parent = node?.parent;
		}
		return null;			
	}
	
	private def EObject getNearestObject_Err(ContentAssistContext context) {
		var parent = context.rootNode;
		var offset = context.offset;
		while (offset-- > 0) {
			val node = NodeModelUtils.findLeafNodeAtOffset(parent,offset);
			if (node !== null)
				offset = node.offset;
			if (node !== null && !isErrNode(node)) {
				val obj = NodeModelUtils.findActualSemanticObjectFor(node);
				if (obj !== null)
					return obj;
			}
		}
		return null;
	}

	private def <T extends EObject> T getNearestObject(EObject model, ContentAssistContext context, Class<T> type) {
		val t = EcoreUtil2.getContainerOfType(model,type);
		if (t === null) {
			var node = context.lastCompleteNode;
			
			var obj = 
			if (isErrNode(node))
				getNearestObject_Err(context)
			else getNearestObject_NoErr(node);
			if (obj !== null)
				return EcoreUtil2.getContainerOfType(obj,type);
		}
		return t;
	}
	
	override completeBindPar_Value(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		var ObjVarDecl theVar = null;
		if (model instanceof BindPar)
			theVar = model.name
		else {
				var bl = getNearestObject(model,context,BindList);
				var prev = getNearestObject(model,context,BindPar);
				var idx = 0;
				if (prev !== null) {
					idx = bl.values.size();
					while (idx>0 && bl.values.get(idx-1) != prev)
						idx--;
				}
				val cd = if (bl!==null) EcoreUtil2.getContainerOfType(bl,NamedCompDecl) else null;
				var vars = Utils.getVariables(cd?.type);
				if (vars!==null && vars.size()>idx)
					theVar = vars.get(idx);
		}
		val v = theVar;
		if (v !== null)
			lookupCrossReference(assignment.getTerminal() as CrossReference, context, acceptor,
				[od| val obj = od.EObjectOrProxy; switch (obj) {
					NamedCompDecl: Utils.areTypesCompatible(v.type,obj.type)
					default: false
				}]
			)
		else
			super.completeBindPar_Value(model, assignment, context, acceptor);
	}
	
	override getProposalFactory(String ruleName, ContentAssistContext contentAssistContext) {
		crossReferenceProposalCreator.setContext(contentAssistContext);
		val qnc = getQualifiedNameConverter();
		val delegate = new DefaultProposalCreator(contentAssistContext, ruleName, qnc);
		return new GhostProposalCreator(contentAssistContext, ruleName, qnc, delegate); 
	}
	
	override getCrossReferenceProposalCreator() {
		return crossReferenceProposalCreator;
	}
	
	override lookupCrossReference(EObject model, EReference reference, ICompletionProposalAcceptor acceptor,
			Predicate<IEObjectDescription> filter, Function<IEObjectDescription, ICompletionProposal> proposalFactory) {
		crossReferenceProposalCreator.lookupCrossReference(model, reference, acceptor, filter, proposalFactory);
	}

	override isValidProposal(String proposal, String prefix, ContentAssistContext context) {
		//suppress brackets and short symbols, that 99% cause confusion
		if (proposal.length()==1 && "[()]_".indexOf(proposal) != -1)
			return false;
		return super.isValidProposal(proposal,prefix,context);
	}
}