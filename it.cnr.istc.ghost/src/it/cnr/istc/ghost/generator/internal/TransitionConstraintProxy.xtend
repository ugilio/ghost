/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.ghost.ghost.TransConstraint
import it.cnr.istc.timeline.lang.Controllability
import it.cnr.istc.timeline.lang.Interval
import it.cnr.istc.timeline.lang.StatementBlock
import it.cnr.istc.timeline.lang.TransitionConstraint
import it.cnr.istc.timeline.lang.Value

class TransitionConstraintProxy extends ProxyObject implements TransitionConstraint {
	TransConstraint real = null;
	Interval interval = null;
	Controllability controllability = null;
	StatementBlock body = null;

	new(TransConstraint real, Register register) {
		super(register);
		this.real = real;
	}

	override getInterval() {
		if (interval === null) {
			interval = if (real.interval === null)
				getDefaultInterval(real)
			else
				getProxy(real.interval) as Interval;
		}
		return interval;
	}

	override getHead() {
		return getProxy(real.head) as Value;
	}

	override getControllability() {
		if (controllability === null) {
			controllability = if (real.controllability === it.cnr.istc.ghost.ghost.Controllability.UNSPECIFIED)
				getDefaultControllability(real)
			else
				getProxy(real.controllability) as Controllability;
		}
		return controllability;
	}

	override getBody() {
		if (body === null) {
			val scope = (getHead() as ValueProxy).getScope();
			body = new BlockImpl(new BlockAdapterImpl(real.body), scope, register);
		}
		return body;
	}

}
