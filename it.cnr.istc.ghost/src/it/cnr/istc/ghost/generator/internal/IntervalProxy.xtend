package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.timeline.lang.Interval

class IntervalProxy extends ProxyObject implements Interval {
	it.cnr.istc.ghost.ghost.Interval real = null;

	new(it.cnr.istc.ghost.ghost.Interval real, Register register) {
		super(register);
		this.real = real;
	}

	private def getBest(Long o1, Long o2) {
		if (o1 !== null && o2 === null)
			return o1;
		if (o1 === null && o2 !== null)
			return o2;
		if (o1 == 0 && o2 != 0)
			return o2;
		return o1;
	}

	override getLb() {
		return getBest(real?.lbub?.value, real?.lb?.value);
	}

	override getUb() {
		return getBest(real?.lbub?.value, real?.ub?.value);
	}
}
