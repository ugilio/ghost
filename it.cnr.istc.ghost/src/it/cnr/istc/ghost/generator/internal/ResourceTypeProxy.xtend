package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.timeline.lang.ResourceType

abstract class ResourceTypeProxy extends AbstractCompTypeProxy implements ResourceType {

	protected ResCompTypeAdapter real;

	new(Object real, Register register) {
		super(real,register);
		this.real = super.real as ResCompTypeAdapter;
	}

	override ResourceType getParent() {
		return (getProxy(real?.parent) as ResourceType);
	}

	override isConsumable() {
		return false;
	}

	override isRenewable() {
		return false;
	}

	protected def getAValue(Object theValue) {
		if (theValue === null)
			throw new IllegalArgumentException("Invalid argument: null value");
		return theValue as Long;
	}
}
