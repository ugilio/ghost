/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.ui.contentassist

import org.eclipse.xtext.ui.editor.hover.IEObjectHover
import org.eclipse.emf.ecore.EObject
import org.eclipse.jface.text.ITextViewer
import org.eclipse.jface.text.IRegion

class NullHover implements IEObjectHover {
	
	override getHoverInfo(EObject eObject, ITextViewer textViewer, IRegion hoverRegion) {
		return null;
	}
	
}