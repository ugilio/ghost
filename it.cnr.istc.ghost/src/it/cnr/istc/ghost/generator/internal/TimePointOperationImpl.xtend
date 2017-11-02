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
