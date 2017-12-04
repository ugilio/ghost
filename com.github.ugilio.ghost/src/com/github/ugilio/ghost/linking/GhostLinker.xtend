/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.linking

import org.eclipse.xtext.linking.lazy.LazyLinker
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.diagnostics.IDiagnosticConsumer
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import com.github.ugilio.ghost.services.GhostGrammarAccess
import com.google.inject.Inject
import com.github.ugilio.ghost.preprocessor.Preprocessor
import com.github.ugilio.ghost.ghost.ConstExpr
import org.eclipse.xtext.EcoreUtil2
import com.github.ugilio.ghost.conversion.ConstCalculator
import com.github.ugilio.ghost.conversion.ConstCalculator.ConstCalculatorException
import com.github.ugilio.ghost.ghost.NumAndUnit
import org.eclipse.xtext.linking.impl.LinkingDiagnosticProducer
import org.eclipse.xtext.diagnostics.IDiagnosticProducer
import org.eclipse.xtext.nodemodel.INode
import com.github.ugilio.ghost.preprocessor.Preprocessor.PreprocessorException
import org.eclipse.xtext.diagnostics.DiagnosticMessage
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.conversion.ValueConverterException
import org.eclipse.xtext.util.Strings
import com.github.ugilio.ghost.conversion.NumAndUnitHelper
import org.eclipse.xtext.util.concurrent.IUnitOfWork
import org.eclipse.emf.ecore.resource.Resource
import com.github.ugilio.ghost.ghost.NameOnlyParList
import com.github.ugilio.ghost.ghost.SimpleInstVal
import com.github.ugilio.ghost.ghost.NamedCompDecl
import com.github.ugilio.ghost.ghost.CompSVBody
import com.github.ugilio.ghost.ghost.GhostFactory
import com.github.ugilio.ghost.ghost.GhostPackage
import java.util.ArrayList
import org.eclipse.emf.common.notify.Adapter
import com.github.ugilio.ghost.ghost.CompResBody
import org.eclipse.emf.ecore.EReference
import com.github.ugilio.ghost.ghost.ValueDecl
import com.github.ugilio.ghost.ghost.ResourceDecl
import com.github.ugilio.ghost.ghost.Controllability
import com.github.ugilio.ghost.ghost.TransConstraint
import com.github.ugilio.ghost.preprocessor.AnnotationProcessor

class GhostLinker extends LazyLinker {
	
	@Inject
	Preprocessor preprocessor;
	
	@Inject
	ConstCalculator constCalc;
	
	@Inject
	NumAndUnitHelper numHelper;
	
	@Inject
	AnnotationProcessor annProcessor;

	public static val PREPROCESSOR_ERROR = 'preprocError';
	public static val NUMERIC_CONV_ERROR = 'numConvError';
	public static val CONST_EVAL_ERROR = 'constEvalError';
	public static val RES_TOO_MANY_ARGS = 'resTooManyArgs';
	
	override protected afterModelLinked(EObject model, IDiagnosticConsumer diagnosticsConsumer) {
		super.afterModelLinked(model, diagnosticsConsumer);
		val p = new LinkingDiagnosticProducer(diagnosticsConsumer);
		cache.execWithoutCacheClear(model.eResource,new IUnitOfWork.Void<Resource>(){
			override process(Resource state) throws Exception {
				fixNamedDeclBodies(model,p);
				runPreprocessor(model,p);
				resolveAllNumbers(model,p);
				resolveAllConstants(model,p);
				linkNamedPars(model,p);
				annProcessor.processAnnotations(model,p);
		}});
	}
	
	private def boolean checkSVValueIsCompatible(TransConstraint tc) {
		if ((tc.body !== null) || (tc.interval !== null)
			|| (tc.controllability !== Controllability.UNSPECIFIED))
			return false;
		if (tc.head === null)
			return false;
		if (tc.head.parlist === null)
			return true;
		return false;		
	}
	
	private def boolean checkSVValuesAreCompatible(CompSVBody oldBody) {
		val l = new ArrayList(oldBody.transitions?.map[t|t.values]?.flatten?.toList);
		for (tc : l)
			if (!checkSVValueIsCompatible(tc))
				return false;
		return true;
	}
	
	private def sv2resCompBody(NamedCompDecl decl, IDiagnosticProducer p) {
		val oldBody = decl.body as CompSVBody;
		if (!checkSVValuesAreCompatible(oldBody))
			return;
		val newBody = GhostFactory.eINSTANCE.createCompResBody();
		newBody.eSet(GhostPackage.Literals.COMP_BODY__BINDINGS,oldBody.bindings);
		newBody.eSet(GhostPackage.Literals.COMP_BODY__SYNCHRONIZATIONS,oldBody.synchronizations);
		val values = new ArrayList(oldBody.transitions?.map[t|t.values]?.flatten?.map[tc|tc.head].toList);
		val node = NodeModelUtils.getNode(oldBody);
		newBody.eAdapters.add(node as Adapter);
		decl.eSet(GhostPackage.Literals.NAMED_COMP_DECL__BODY,newBody);
		if (values !== null && values.size()>0) {
			setResValue(newBody, GhostPackage.Literals.COMP_RES_BODY__VAL1, values.get(0));
			if (values.size()>1)
				setResValue(newBody, GhostPackage.Literals.COMP_RES_BODY__VAL2, values.get(1));
			if (values.size()>2) {
				p.setNode(NodeModelUtils.getNode(values.get(2)));
				p.addDiagnostic(new DiagnosticMessage(
					"Too many arguments in resource declaration",Severity.ERROR,RES_TOO_MANY_ARGS));
			}
		}
	}
	
	private def void setResValue(CompResBody body, EReference reference, ValueDecl v) {
		val node = NodeModelUtils.getNode(v);
		
		val litUsage = GhostFactory.eINSTANCE.createConstLiteralUsage();
		val term = GhostFactory.eINSTANCE.createConstTerm();
		term.eSet(GhostPackage.Literals.CONST_TERM__LEFT,litUsage);
		val sum = GhostFactory.eINSTANCE.createConstSumExp();
		sum.eSet(GhostPackage.Literals.CONST_SUM_EXP__LEFT,term);
		
		body.eSet(reference,sum);
		
		litUsage.eAdapters.add(node as Adapter);
		createAndSetProxy(litUsage,node,GhostPackage.Literals.CONST_LITERAL_USAGE__VALUE);
	}
	
	private def fixNamedDeclBody(NamedCompDecl decl, IDiagnosticProducer p) {
		val type = decl?.type;
		val needChange = !type.eIsProxy() && (type instanceof ResourceDecl)
			&& (decl.body instanceof CompSVBody); 
		if (needChange) {
			sv2resCompBody(decl,p);
		}
	}
	
	private def fixNamedDeclBodies(EObject model, IDiagnosticProducer p) {
		EcoreUtil2.getAllContentsOfType(model,NamedCompDecl).
			forEach(d|fixNamedDeclBody(d,p));
	}
	
	private def runPreprocessor(EObject model, IDiagnosticProducer p) {
		val dirRule = (grammarAccess as GhostGrammarAccess).DIRECTIVERule;
		val root = NodeModelUtils.getNode(model);
		root.asTreeIterable.
			filter[grammarElement === dirRule].
			forEach(n | preprocessorParse(n,p));
	}
	
	private def preprocessorParse(INode node, IDiagnosticProducer p) {
		try {
			preprocessor.parse(node,node.text)
		}
		catch (PreprocessorException e) {
			p.node = node;
			if (!Strings.isEmpty(e.message))
				p.addDiagnostic(new DiagnosticMessage(
					e.message,Severity.ERROR,PREPROCESSOR_ERROR));
		}
	}
	
	private def resolveAllNumbers(EObject model, IDiagnosticProducer p) {
		EcoreUtil2.getAllContentsOfType(model,NumAndUnit).
			forEach[ n | resolveNumber(n,p)];
	}
	
	private def resolveNumber(NumAndUnit n, IDiagnosticProducer p) {
		try {
			numHelper.get(n)
		}
		catch (ValueConverterException e) {
			p.node = NodeModelUtils.getNode(n);
			if (!Strings.isEmpty(e.message))
				p.addDiagnostic(new DiagnosticMessage(
					e.message,Severity.ERROR,NUMERIC_CONV_ERROR));
		}
	}
	
	private def resolveAllConstants(EObject model, IDiagnosticProducer p) throws ConstCalculatorException {
		EcoreUtil2.getAllContentsOfType(model,ConstExpr).
			forEach[ c | resolveConstant(c,p)];
	}
	
	private def resolveConstant(ConstExpr c, IDiagnosticProducer p) {
		try {
			constCalc.compute(c)
		}
		catch (ConstCalculatorException e) {
			p.node = NodeModelUtils.getNode(c);
			if (!Strings.isEmpty(e.message))
				p.addDiagnostic(new DiagnosticMessage(
					e.message,Severity.ERROR,CONST_EVAL_ERROR));
		}
	}
	
	private def linkNamedPars(EObject model, IDiagnosticProducer p) {
		for (list : EcoreUtil2.getAllContentsOfType(model,NameOnlyParList))
			if (list.eContainer instanceof SimpleInstVal) {
				val formalValues = (list.eContainer as SimpleInstVal)?.value?.parlist?.values;
				val values = (list.values);
				val count = Math.min(
					if (values === null) 0 else values.size,
					if (formalValues === null) 0 else formalValues.size);
				for (var i = 0; i < count; i++)
					values.get(i).type = formalValues.get(i).type;
			}
	}
	
}