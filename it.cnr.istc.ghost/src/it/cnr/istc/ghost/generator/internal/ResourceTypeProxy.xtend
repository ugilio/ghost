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
	
	protected def long getValue1() {
		if (real?.val1 !== null)
			return getAValue(real?.val1);
		return (parent as ResourceTypeProxy).getValue1();
	}

	protected def long getValue2() {
		if (real?.val2 !== null)
			return getAValue(real?.val2);
		return (parent as ResourceTypeProxy).getValue2();
	}

	protected def getAValue(Object theValue) {
		if (theValue === null)
			throw new IllegalArgumentException("Invalid argument: null value");
		return theValue as Long;
	}
}
