package it.cnr.istc.ghost.generator.internal

import static extension it.cnr.istc.ghost.generator.internal.Utils.*;
import it.cnr.istc.ghost.ghost.CompDecl
import it.cnr.istc.ghost.ghost.CompSVBody
import it.cnr.istc.ghost.ghost.NamedCompDecl
import it.cnr.istc.ghost.ghost.AnonSVDecl

class SyntheticSVCompTypeAdapter extends SyntheticCompTypeAdapter implements SVCompTypeAdapter {

	new(CompDecl real) {
		super(real)
	}

	private def CompSVBody getBody() {
		return switch (real) {
			NamedCompDecl: real.body as CompSVBody
			AnonSVDecl: real.body
			default: throw new IllegalArgumentException("Wrong CompDecl type: " + real)
		}
	}

	override getDeclaredSynchronizations() {
		return body?.synchronizations?.map[values]?.flatten.toRegularList;
	}

	override getDeclaredVariables() {
		return null;
	}

	override getDeclaredValues() {
		return body?.transitions?.map[values]?.flatten?.map[head].toRegularList;
	}

	override getDeclaredTransitionConstraints() {
		return body?.transitions?.map[values]?.flatten.toRegularList;
	}
}
