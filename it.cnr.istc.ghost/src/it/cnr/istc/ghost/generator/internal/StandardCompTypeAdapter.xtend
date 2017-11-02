package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.ghost.ghost.ComponentType

abstract class StandardCompTypeAdapter implements CompTypeAdapter {
	ComponentType real;
	
	new(ComponentType real) {
		this.real = real;
	}

	override getReal() {
		return real;
	}

	override getExternality() {
		return real?.externality;
	}

	override getName(Register register) {
		return real?.name;
	}
}
