package it.cnr.istc.ghost.generator.internal

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
