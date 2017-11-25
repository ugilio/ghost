/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import it.cnr.istc.timeline.lang.ConsumableResourceType

class ConsumableResourceTypeProxy extends ResourceTypeProxy implements ConsumableResourceType {

	new(Object real, Register register) {
		super(real,register);
	}

	override ConsumableResourceType getParent() {
		return (getProxy(real?.parent) as ConsumableResourceType);
	}

	override getMin() {
		return getValue1();
	}

	override getMax() {
		return getValue2();
	}

	override isConsumable() {
		return true;
	}
}
