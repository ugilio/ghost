/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package it.cnr.istc.ghost.generator.internal

import static extension it.cnr.istc.ghost.generator.internal.Utils.*;
import it.cnr.istc.ghost.ghost.SvDecl

class StandardSVCompTypeAdapter extends StandardCompTypeAdapter implements SVCompTypeAdapter {
	SvDecl real;

	new(SvDecl real) {
		super(real);
		this.real = real;
	}

	override getParent() {
		return real?.parent;
	}

	override getDeclaredSynchronizations() {
		return real?.body?.synchronizations?.map[values]?.flatten?.toRegularList;
	}

	override getDeclaredVariables() {
		return real?.body?.variables?.map[values]?.flatten?.toRegularList;
	}

	override getDeclaredValues() {
		return real?.body?.transitions?.map[values]?.flatten?.map[head]?.toRegularList;
	}

	override getDeclaredTransitionConstraints() {
		return real?.body?.transitions?.map[values]?.flatten?.toRegularList;
	}
}
