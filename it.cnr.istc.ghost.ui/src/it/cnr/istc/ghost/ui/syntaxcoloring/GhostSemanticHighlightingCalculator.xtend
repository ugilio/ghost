package it.cnr.istc.ghost.ui.syntaxcoloring

import org.eclipse.xtext.ide.editor.syntaxcoloring.DefaultSemanticHighlightingCalculator
import org.eclipse.xtext.ide.editor.syntaxcoloring.IHighlightedPositionAcceptor
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.util.CancelIndicator
import it.cnr.istc.ghost.ghost.EnumLiteral
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import it.cnr.istc.ghost.ghost.ObjVarDecl
import it.cnr.istc.ghost.ghost.GhostPackage
import it.cnr.istc.ghost.ghost.ConstDecl
import org.eclipse.emf.ecore.EcorePackage
import it.cnr.istc.ghost.ghost.QualifInstVal
import it.cnr.istc.ghost.ghost.ResConstr
import it.cnr.istc.ghost.ghost.LocVarDecl
import org.eclipse.xtext.EcoreUtil2
import it.cnr.istc.ghost.ghost.InitSection

class GhostSemanticHighlightingCalculator extends DefaultSemanticHighlightingCalculator {

	override highlightElement(EObject object, IHighlightedPositionAcceptor acceptor,
			CancelIndicator cancelIndicator) {
		return doHighlight(object,acceptor);
	}

	protected dispatch def doHighlight(EnumLiteral object, IHighlightedPositionAcceptor acceptor) {
		val node = NodeModelUtils.findActualNodeFor(object);
		highlightNode(acceptor,node,GhostHighlightingConfiguration.ENUM_LITERAL_ID);
		return true;
	}
	
	protected dispatch def doHighlight(ConstDecl object, IHighlightedPositionAcceptor acceptor) {
		highlightFeature(acceptor,object,EcorePackage.Literals.ENAMED_ELEMENT__NAME,GhostHighlightingConfiguration.CONST_LITERAL_ID);
		return false;
	}
	
	protected dispatch def doHighlight(ObjVarDecl object, IHighlightedPositionAcceptor acceptor) {
		highlightFeature(acceptor,object,EcorePackage.Literals.ENAMED_ELEMENT__NAME,GhostHighlightingConfiguration.COMPVAR_ID);
		return true;
	}
	
	protected dispatch def doHighlight(QualifInstVal object, IHighlightedPositionAcceptor acceptor) {
		if (object.comp instanceof ObjVarDecl)
			highlightFeature(acceptor,object,GhostPackage.Literals.QUALIF_INST_VAL__COMP,GhostHighlightingConfiguration.COMPVAR_ID);
		if (object.value instanceof EnumLiteral)
			highlightFeature(acceptor,object,GhostPackage.Literals.QUALIF_INST_VAL__VALUE,GhostHighlightingConfiguration.ENUM_LITERAL_ID);
		if (object.value instanceof ConstDecl)
			highlightFeature(acceptor,object,GhostPackage.Literals.QUALIF_INST_VAL__VALUE,GhostHighlightingConfiguration.CONST_LITERAL_ID);
		return false;
	}
	
	protected dispatch def doHighlight(ResConstr object, IHighlightedPositionAcceptor acceptor) {
		if (object.res instanceof ObjVarDecl)
			highlightFeature(acceptor,object,GhostPackage.Literals.RES_CONSTR__RES,GhostHighlightingConfiguration.COMPVAR_ID);
		return false;
	}

	protected dispatch def doHighlight(LocVarDecl object, IHighlightedPositionAcceptor acceptor) {
		if (EcoreUtil2.getContainerOfType(object,InitSection) !== null) {
			switch (object.name) {
				case "end": 
					highlightFeature(acceptor,object,EcorePackage.Literals.ENAMED_ELEMENT__NAME,GhostHighlightingConfiguration.DEFAULT_ID)
				case "start", case "horizon", case "resolution": 
					highlightFeature(acceptor,object,EcorePackage.Literals.ENAMED_ELEMENT__NAME,GhostHighlightingConfiguration.INITVAR_ID)
			}
		}
		return false;
	}

	protected dispatch def doHighlight(EObject object, IHighlightedPositionAcceptor acceptor) {
		return false;
	}

	protected dispatch def doHighlight(Void object, IHighlightedPositionAcceptor acceptor) {
		return false;
	}
	
}