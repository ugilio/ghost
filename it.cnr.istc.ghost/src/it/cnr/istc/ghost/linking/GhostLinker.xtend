package it.cnr.istc.ghost.linking

import org.eclipse.xtext.linking.lazy.LazyLinker
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.diagnostics.IDiagnosticConsumer
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import it.cnr.istc.ghost.services.GhostGrammarAccess
import com.google.inject.Inject
import it.cnr.istc.ghost.preprocessor.Preprocessor
import it.cnr.istc.ghost.ghost.ConstExpr
import org.eclipse.xtext.EcoreUtil2
import it.cnr.istc.ghost.conversion.ConstCalculator
import it.cnr.istc.ghost.conversion.ConstCalculator.ConstCalculatorException
import it.cnr.istc.ghost.ghost.NumAndUnit
import org.eclipse.xtext.linking.impl.LinkingDiagnosticProducer
import org.eclipse.xtext.diagnostics.IDiagnosticProducer
import org.eclipse.xtext.nodemodel.INode
import it.cnr.istc.ghost.preprocessor.Preprocessor.PreprocessorException
import org.eclipse.xtext.diagnostics.DiagnosticMessage
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.conversion.ValueConverterException
import org.eclipse.xtext.util.Strings
import it.cnr.istc.ghost.conversion.NumAndUnitHelper
import org.eclipse.xtext.util.concurrent.IUnitOfWork
import org.eclipse.emf.ecore.resource.Resource
import it.cnr.istc.ghost.ghost.NameOnlyParList
import it.cnr.istc.ghost.ghost.SimpleInstVal

class GhostLinker extends LazyLinker {
	
	@Inject
	Preprocessor preprocessor;
	
	@Inject
	ConstCalculator constCalc;
	
	@Inject
	NumAndUnitHelper numHelper;
	
	public static val PREPROCESSOR_ERROR = 'preprocError';
	public static val NUMERIC_CONV_ERROR = 'numConvError';
	public static val CONST_EVAL_ERROR = 'constEvalError';
	
	override protected afterModelLinked(EObject model, IDiagnosticConsumer diagnosticsConsumer) {
		super.afterModelLinked(model, diagnosticsConsumer);
		val p = new LinkingDiagnosticProducer(diagnosticsConsumer);
		cache.execWithoutCacheClear(model.eResource,new IUnitOfWork.Void<Resource>(){
			override process(Resource state) throws Exception {
				runPreprocessor(model,p);
				resolveAllNumbers(model,p);
				resolveAllConstants(model,p);
				linkNamedPars(model,p);
		}});
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