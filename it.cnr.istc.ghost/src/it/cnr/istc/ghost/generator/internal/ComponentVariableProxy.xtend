package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.ghost.ghost.ObjVarDecl
import it.cnr.istc.timeline.lang.CompType
import it.cnr.istc.timeline.lang.ComponentVariable

class ComponentVariableProxy extends ProxyObject implements ComponentVariable {
	ObjVarDecl real = null;

	new(ObjVarDecl real, Register register) {
		super(register);
		this.real = real;
	}

	override getName() {
		return real.name;
	}

	override getType() {
		return getProxy(real.type) as CompType;
	}
}
