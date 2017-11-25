/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import com.github.ugilio.ghost.generator.internal.ProxyObject
import it.cnr.istc.timeline.lang.EnumLiteral
import it.cnr.istc.timeline.lang.EnumType

class EnumLiteralProxy extends ProxyObject implements EnumLiteral {
	com.github.ugilio.ghost.ghost.EnumLiteral real = null;
	String name = null;

	new(com.github.ugilio.ghost.ghost.EnumLiteral real, Register register) {
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
