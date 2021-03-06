/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import com.github.ugilio.ghost.ghost.BindPar
import it.cnr.istc.timeline.lang.Component
import it.cnr.istc.timeline.lang.ComponentReference
import it.cnr.istc.timeline.lang.ComponentVariable

class ComponentReferenceProxy extends ProxyObject implements ComponentReference {
	BindPar real = null;

	new(BindPar real, Register register) {
		super(register);
		this.real = real;
	}

	override getName() {
		return real?.name?.name;
	}

	override getComponent() {
		return getProxy(real?.value) as Component;
	}

	override getVariableRef() {
		return getProxy(real?.name) as ComponentVariable;
	}
}
