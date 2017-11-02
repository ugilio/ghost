package it.cnr.istc.ghost.generator.internal

import static extension it.cnr.istc.ghost.generator.internal.Utils.*;
import it.cnr.istc.ghost.ghost.CompDecl
import it.cnr.istc.ghost.ghost.NamedCompDecl

abstract class SyntheticCompTypeAdapter implements CompTypeAdapter {
	protected CompDecl real;
	String name = null;

	new(CompDecl real) {
		this.real = real;
	}

	override getParent() {
		switch (real) {
			NamedCompDecl: real.type
			default: null
		}
	}

	override getReal() {
		return real;
	}

	override getExternality() {
		return real?.externality;
	}

	override getName(Register register) {
		if (name === null) {
			name = genName(real?.name + "Type", register.getGlobalScope(), false);
			register.getGlobalScope().add(name, real);
		}
		return name;
	}
}
