/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.ghost.ghost.ObjVarDecl
import it.cnr.istc.timeline.lang.CompType
import it.cnr.istc.timeline.lang.ComponentVariable

class ComponentVariableProxy extends ProxyObject implements ComponentVariable {
	ObjVarDecl real = null;

	new(ObjVarDecl real, Register register) {
		super(register);
		this.real = real;
	}

	override getName() {
		return real.name;
	}

	override getType() {
		return getProxy(real.type) as CompType;
	}
}
