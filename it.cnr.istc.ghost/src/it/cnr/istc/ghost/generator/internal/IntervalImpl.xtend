package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.timeline.lang.Interval

class IntervalImpl implements Interval {
	long lb;
	long ub;

	new(long lb, long ub) {
		this.lb = lb;
		this.ub = ub;
	}

	override getLb() {
		return lb;
	}

	override getUb() {
		return ub;
	}
}
