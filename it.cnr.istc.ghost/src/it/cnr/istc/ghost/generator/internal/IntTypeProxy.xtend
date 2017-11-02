package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.ghost.ghost.IntDecl
import it.cnr.istc.timeline.lang.IntType
import it.cnr.istc.timeline.lang.Interval

class IntTypeProxy extends ProxyObject implements IntType, InternalSimpleType {
	IntDecl real = null;
	String name = null;

	new(IntDecl real, Register register) {
		super(register);
		this.real = real;
	}

	override getName() {
		if (name !== null)
			return name
		return real.name;
	}

	override getInterval() {
		return getProxy(real.value) as Interval;
	}
	
	override setName(String name) {
		this.name = name;
	}
}
