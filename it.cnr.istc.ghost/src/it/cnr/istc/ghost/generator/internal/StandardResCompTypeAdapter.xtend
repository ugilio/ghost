package it.cnr.istc.ghost.generator.internal

import static extension it.cnr.istc.ghost.generator.internal.Utils.*;
import it.cnr.istc.ghost.ghost.ResourceDecl

class StandardResCompTypeAdapter extends StandardCompTypeAdapter implements ResCompTypeAdapter {
	ResourceDecl real;

	new(ResourceDecl real) {
		super(real);
		this.real = real;
	}

	override getParent() {
		return real?.parent;
	}

	override getDeclaredSynchronizations() {
		return real?.body?.synchronizations?.map[values]?.flatten.toRegularList;
	}

	override getDeclaredVariables() {
		return real?.body?.variables?.map[values]?.flatten.toRegularList;
	}

	override getVal1() {
		return real?.body?.val1?.computed;
	}

	override getVal2() {
		return real?.body?.val2?.computed;
	}

}
