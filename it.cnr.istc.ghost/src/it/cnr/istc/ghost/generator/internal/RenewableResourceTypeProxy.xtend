package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.timeline.lang.RenewableResourceType

class RenewableResourceTypeProxy extends ResourceTypeProxy implements RenewableResourceType {

	new(Object real, Register register) {
		super(real,register);
	}

	override RenewableResourceType getParent() {
		return (getProxy(real?.parent) as RenewableResourceType);
	}

	override getValue() {
		return getValue1();
	}

	override isRenewable() {
		return true;
	}
}
