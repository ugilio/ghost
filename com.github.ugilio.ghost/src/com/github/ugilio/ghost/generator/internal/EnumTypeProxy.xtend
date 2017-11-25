/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import static extension com.github.ugilio.ghost.generator.internal.Utils.*;
import com.github.ugilio.ghost.ghost.EnumDecl
import it.cnr.istc.timeline.lang.EnumLiteral
import it.cnr.istc.timeline.lang.EnumType
import java.util.List

class EnumTypeProxy extends ProxyObject implements EnumType, InternalSimpleType {
	EnumDecl real = null;
	String name = null;
	List<EnumLiteral> values = null;

	new(EnumDecl real, Register register) {
		super(register);
		this.real = real;
	}

	override getName() {
		if (name !== null)
			return name;
		return real.name;
	}

	override getValues() {
		if (values === null) {
			values = real.values.map[v|getProxy(v) as EnumLiteral].toRegularList;
		}
		return values;
	}
	
	override setName(String name) {
		this.name = name;
	}
}
	
