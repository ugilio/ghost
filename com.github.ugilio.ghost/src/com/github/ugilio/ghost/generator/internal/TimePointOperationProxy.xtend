/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import com.github.ugilio.ghost.ghost.TimePointOp
import it.cnr.istc.timeline.lang.InstantiatedValue
import it.cnr.istc.timeline.lang.TimePointOperation
import it.cnr.istc.timeline.lang.TimePointSelector

class TimePointOperationProxy extends ProxyObject implements TimePointOperation {
	TimePointOp real = null;

	new(TimePointOp real, Register register) {
		super(register);
		this.real = real;
	}

	override getInstValue() {
		return getProxy(real.value) as InstantiatedValue;
	}

	override getSelector() {
		return getProxy(real.selector) as TimePointSelector;
	}
}
