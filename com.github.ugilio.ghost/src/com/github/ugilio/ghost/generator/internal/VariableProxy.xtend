/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import com.github.ugilio.ghost.ghost.LocVarDecl
import it.cnr.istc.timeline.lang.Variable

class VariableProxy extends ProxyObject implements Variable {
	LocVarDecl real = null;
	String name = null;
	Object value = null;

	new(LocVarDecl real, Register register) {
		super(register);
		this.real = real;
	}
	
	new(String name, Object value) {
		this(null as LocVarDecl,null as Register);
		this.name = name;
		this.value = value;
	}

	override getName() {
		if (name !== null)
			return name;
		return real?.name
	}

	override getValue() {
		if (value !== null)
			return value;
		return getProxy(real?.value);
	}

	def setName(String name) {
		this.name = name;
	}
	
	def setValue(Object value) {
		this.value = value;
	}

}
