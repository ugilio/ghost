/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.scoping

import org.eclipse.xtext.resource.impl.DefaultResourceDescriptionStrategy
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.util.IAcceptor
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.EcoreUtil2
import com.github.ugilio.ghost.ghost.Ghost

/**
 * Only export contents of domain files
 */
class GhostResourceDescriptionStrategy extends DefaultResourceDescriptionStrategy {
	
	private def isInDomain(EObject obj) {
		return EcoreUtil2.getContainerOfType(obj,Ghost)?.domain !== null;
	}
	
	override createEObjectDescriptions(EObject eObject, IAcceptor<IEObjectDescription> acceptor) {
		if (isInDomain(eObject))
			return super.createEObjectDescriptions(eObject,acceptor);
		return false;
	}
}