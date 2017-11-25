/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import org.eclipse.emf.ecore.EObject
import java.util.Collections
import org.eclipse.xtext.EcoreUtil2

class BlockAdapterImpl implements BlockAdapter {
	private EObject real;

	new(EObject real) {
		this.real = real;
	}

	override getContents() {
		return if(real !== null) real.eContents() else Collections.emptyList();
	}

	override getContainer() {
		return real?.eContainer;
	}

	override <T extends EObject> getContainerOfType(Class<T> clazz) {
		return EcoreUtil2.getContainerOfType(real, clazz);
	}
}
