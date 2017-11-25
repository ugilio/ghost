/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.timeline.lang.Interval
import it.cnr.istc.timeline.lang.Fact
import it.cnr.istc.ghost.ghost.InitConstrType
import it.cnr.istc.timeline.lang.InstantiatedValue

class FactProxy extends ProxyObject implements Fact {
	it.cnr.istc.ghost.ghost.FactGoal real;
	Interval start;
	Interval duration;
	Interval end;

	new(it.cnr.istc.ghost.ghost.FactGoal real, Register register) {
		super(register);
		this.real = real;
	}

	override isGoal() {
		return real?.type == InitConstrType.GOAL;
	}

	override getValue() {
		return getProxy(real?.value) as InstantiatedValue;
	}

	private def getInterval(Object realIntv) {
		return if (realIntv === null)
			getDefaultInterval(real)
		else
			getProxy(realIntv) as Interval;
	}

	override getStart() {
		if (start === null)
			start = getInterval(real?.params?.start);
		return start;
	}

	override getDuration() {
		if (duration === null)
			duration = getInterval(real?.params?.duration);
		return duration;
	}

	override getEnd() {
		if (end === null)
			end = getInterval(real?.params?.end);
		return end;
	}
}
