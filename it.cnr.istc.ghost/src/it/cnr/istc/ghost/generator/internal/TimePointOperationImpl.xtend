/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.timeline.lang.InstantiatedValue
import it.cnr.istc.timeline.lang.TimePointOperation
import it.cnr.istc.timeline.lang.TimePointSelector

class TimePointOperationImpl implements TimePointOperation {
	InstantiatedValue value;
	TimePointSelector selector;

	new(InstantiatedValue value, TimePointSelector selector) {
		this.value = value;
		this.selector = selector;
	}

	override getInstValue() {
		return value;
	}

	override getSelector() {
		return selector;
	}

}
