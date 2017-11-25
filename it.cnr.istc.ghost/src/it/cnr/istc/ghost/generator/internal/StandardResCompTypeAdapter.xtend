/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package it.cnr.istc.ghost.generator.internal

import static extension it.cnr.istc.ghost.generator.internal.Utils.*;
import it.cnr.istc.ghost.ghost.ResourceDecl

class StandardResCompTypeAdapter extends StandardCompTypeAdapter implements ResCompTypeAdapter {
	ResourceDecl real;

	new(ResourceDecl real) {
		super(real);
		this.real = real;
	}

	override getParent() {
		return real?.parent;
	}

	override getDeclaredSynchronizations() {
		return real?.body?.synchronizations?.map[values]?.flatten.toRegularList;
	}

	override getDeclaredVariables() {
		return real?.body?.variables?.map[values]?.flatten.toRegularList;
	}

	override getVal1() {
		return real?.body?.val1?.computed;
	}

	override getVal2() {
		return real?.body?.val2?.computed;
	}

}
