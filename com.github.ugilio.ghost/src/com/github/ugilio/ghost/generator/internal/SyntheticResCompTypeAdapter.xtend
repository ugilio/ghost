/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import static extension com.github.ugilio.ghost.generator.internal.Utils.*;
import com.github.ugilio.ghost.ghost.CompResBody
import com.github.ugilio.ghost.ghost.CompDecl
import com.github.ugilio.ghost.ghost.NamedCompDecl
import com.github.ugilio.ghost.ghost.AnonResDecl

class SyntheticResCompTypeAdapter extends SyntheticCompTypeAdapter implements ResCompTypeAdapter {

	new(CompDecl real) {
		super(real)
	}

	private def CompResBody getBody() {
		return switch (real) {
			NamedCompDecl: real.body as CompResBody
			AnonResDecl: real.body
			default: throw new IllegalArgumentException("Wrong CompDecl type: " + real)
		}
	}

	override getDeclaredSynchronizations() {
		return body?.synchronizations.map[values].flatten.toRegularList;
	}

	override getDeclaredVariables() {
		return null;
	}

	override getVal1() {
		return body?.val1?.computed;
	}

	override getVal2() {
		return body?.val2?.computed;
	}
}
