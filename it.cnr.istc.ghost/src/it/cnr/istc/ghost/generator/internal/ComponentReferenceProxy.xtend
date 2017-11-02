package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.ghost.ghost.BindPar
import it.cnr.istc.timeline.lang.Component
import it.cnr.istc.timeline.lang.ComponentReference
import it.cnr.istc.timeline.lang.ComponentVariable

class ComponentReferenceProxy extends ProxyObject implements ComponentReference {
	BindPar real = null;

	new(BindPar real, Register register) {
		super(register);
		this.real = real;
	}

	override getName() {
		return real?.name?.name;
	}

	override getComponent() {
		return getProxy(real?.value) as Component;
	}

	override getVariableRef() {
		return getProxy(real?.name) as ComponentVariable;
	}
}
