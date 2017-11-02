package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.ghost.generator.internal.ProxyObject
import it.cnr.istc.timeline.lang.EnumLiteral
import it.cnr.istc.timeline.lang.EnumType

class EnumLiteralProxy extends ProxyObject implements EnumLiteral {
	it.cnr.istc.ghost.ghost.EnumLiteral real = null;

	new(it.cnr.istc.ghost.ghost.EnumLiteral real, Register register) {
		super(register);
		this.real = real;
	}

	override getName() {
		return real.name;
	}

	override getEnum() {
		getProxy(real?.eContainer) as EnumType;
	}
}
