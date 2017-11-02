package it.cnr.istc.ghost.generator.internal

import static extension it.cnr.istc.ghost.generator.internal.Utils.*;
import it.cnr.istc.ghost.ghost.CompResBody
import it.cnr.istc.ghost.ghost.CompDecl
import it.cnr.istc.ghost.ghost.NamedCompDecl
import it.cnr.istc.ghost.ghost.AnonResDecl

class SyntheticResCompTypeAdapter extends SyntheticCompTypeAdapter implements ResCompTypeAdapter {

	new(CompDecl real) {
		super(real)
	}

	private def CompResBody getBody() {
		return switch (real) {
			NamedCompDecl: real.body as CompResBody
			AnonResDecl: real.body
			default: throw new IllegalArgumentException("Wrong CompDecl type: " + real)
		}
	}

	override getDeclaredSynchronizations() {
		return body?.synchronizations.map[values].flatten.toRegularList;
	}

	override getDeclaredVariables() {
		return null;
	}

	override getVal1() {
		return body?.val1?.computed;
	}

	override getVal2() {
		return body?.val2?.computed;
	}
}
