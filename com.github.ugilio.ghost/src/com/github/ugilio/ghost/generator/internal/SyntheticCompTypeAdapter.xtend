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
import com.github.ugilio.ghost.ghost.NamedCompDecl

abstract class SyntheticCompTypeAdapter implements CompTypeAdapter {
	protected CompDecl real;
	String name = null;

	new(CompDecl real) {
		this.real = real;
	}

	override getParent() {
		switch (real) {
			NamedCompDecl: real.type
			default: null
		}
	}

	override getReal() {
		return real;
	}

	override getExternality() {
		return real?.externality;
	}

	override getName(Register register) {
		if (name === null) {
			name = genName(real?.name + "Type", register.getGlobalScope(), false);
			register.getGlobalScope().add(name, real);
		}
		return name;
	}
}
