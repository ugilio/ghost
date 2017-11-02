package it.cnr.istc.ghost.generator.internal

import static extension it.cnr.istc.ghost.generator.internal.Utils.*;
import it.cnr.istc.ghost.ghost.SvDecl

class StandardSVCompTypeAdapter extends StandardCompTypeAdapter implements SVCompTypeAdapter {
	SvDecl real;

	new(SvDecl real) {
		super(real);
		this.real = real;
	}

	override getParent() {
		return real?.parent;
	}

	override getDeclaredSynchronizations() {
		return real?.body?.synchronizations?.map[values]?.flatten?.toRegularList;
	}

	override getDeclaredVariables() {
		return real?.body?.variables?.map[values]?.flatten?.toRegularList;
	}

	override getDeclaredValues() {
		return real?.body?.transitions?.map[values]?.flatten?.map[head]?.toRegularList;
	}

	override getDeclaredTransitionConstraints() {
		return real?.body?.transitions?.map[values]?.flatten?.toRegularList;
	}
}
