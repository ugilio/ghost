/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.ghost.ghost.IntDecl
import it.cnr.istc.timeline.lang.IntType
import it.cnr.istc.timeline.lang.Interval

class IntTypeProxy extends ProxyObject implements IntType, InternalSimpleType {
	IntDecl real = null;
	String name = null;

	new(IntDecl real, Register register) {
		super(register);
		this.real = real;
	}

	override getName() {
		if (name !== null)
			return name
		return real.name;
	}

	override getInterval() {
		return getProxy(real.value) as Interval;
	}
	
	override setName(String name) {
		this.name = name;
	}
}
