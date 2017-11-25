/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.timeline.lang.RenewableResourceType

class RenewableResourceTypeProxy extends ResourceTypeProxy implements RenewableResourceType {

	new(Object real, Register register) {
		super(real,register);
	}

	override RenewableResourceType getParent() {
		return (getProxy(real?.parent) as RenewableResourceType);
	}

	override getValue() {
		return getValue1();
	}

	override isRenewable() {
		return true;
	}
}
