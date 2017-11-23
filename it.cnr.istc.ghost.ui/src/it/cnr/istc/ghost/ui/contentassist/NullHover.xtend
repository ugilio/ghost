package it.cnr.istc.ghost.ui.contentassist

import org.eclipse.xtext.ui.editor.hover.IEObjectHover
import org.eclipse.emf.ecore.EObject
import org.eclipse.jface.text.ITextViewer
import org.eclipse.jface.text.IRegion

class NullHover implements IEObjectHover {
	
	override getHoverInfo(EObject eObject, ITextViewer textViewer, IRegion hoverRegion) {
		return null;
	}
	
}