/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.ghost.generator.internal.ProxyObject
import it.cnr.istc.timeline.lang.EnumLiteral
import it.cnr.istc.timeline.lang.EnumType

class EnumLiteralProxy extends ProxyObject implements EnumLiteral {
	it.cnr.istc.ghost.ghost.EnumLiteral real = null;
	String name = null;

	new(it.cnr.istc.ghost.ghost.EnumLiteral real, Register register) {
		super(register);
		this.real = real;
	}

	override getName() {
		if (name !== null)
			return name;
		return real.name;
	}

	override getEnum() {
		getProxy(real?.eContainer) as EnumType;
	}
	
	def setName(String name) {
		this.name = name;
	}
}
