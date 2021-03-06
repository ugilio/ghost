/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import static extension com.github.ugilio.ghost.generator.internal.Utils.*;
import com.github.ugilio.ghost.ghost.CompDecl
import com.github.ugilio.ghost.ghost.CompSVBody
import com.github.ugilio.ghost.ghost.NamedCompDecl
import com.github.ugilio.ghost.ghost.AnonSVDecl

class SyntheticSVCompTypeAdapter extends SyntheticCompTypeAdapter implements SVCompTypeAdapter {

	new(CompDecl real) {
		super(real)
	}

	private def CompSVBody getBody() {
		return switch (real) {
			NamedCompDecl: real.body as CompSVBody
			AnonSVDecl: real.body
			default: throw new IllegalArgumentException("Wrong CompDecl type: " + real)
		}
	}

	override getDeclaredSynchronizations() {
		return body?.synchronizations?.map[values]?.flatten.toRegularList;
	}

	override getDeclaredVariables() {
		return null;
	}

	override getDeclaredValues() {
		return body?.transitions?.map[values]?.flatten?.map[head].toRegularList;
	}

	override getDeclaredTransitionConstraints() {
		return body?.transitions?.map[values]?.flatten.toRegularList;
	}
}
