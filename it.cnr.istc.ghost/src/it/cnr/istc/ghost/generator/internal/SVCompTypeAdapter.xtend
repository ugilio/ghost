package it.cnr.istc.ghost.generator.internal

import java.util.List
import it.cnr.istc.ghost.ghost.ValueDecl
import it.cnr.istc.ghost.ghost.TransConstraint

interface SVCompTypeAdapter extends CompTypeAdapter {
	def List<ValueDecl> getDeclaredValues();
	def List<TransConstraint> getDeclaredTransitionConstraints();
}
