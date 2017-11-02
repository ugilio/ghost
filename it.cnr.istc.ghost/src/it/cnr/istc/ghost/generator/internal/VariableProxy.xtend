package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.ghost.ghost.LocVarDecl
import it.cnr.istc.timeline.lang.Variable

class VariableProxy extends ProxyObject implements Variable {
	LocVarDecl real = null;
	String name = null;
	Object value = null;

	new(LocVarDecl real, Register register) {
		super(register);
		this.real = real;
	}
	
	new(String name, Object value) {
		this(null as LocVarDecl,null as Register);
		this.name = name;
		this.value = value;
	}

	override getName() {
		if (name !== null)
			return name;
		return real?.name
	}

	override getValue() {
		if (value !== null)
			return value;
		return getProxy(real?.value);
	}

	def setName(String name) {
		this.name = name;
	}
	
	def setValue(Object value) {
		this.value = value;
	}

}
