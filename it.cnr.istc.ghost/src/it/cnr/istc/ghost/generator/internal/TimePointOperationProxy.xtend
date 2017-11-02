package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.ghost.ghost.TimePointOp
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
