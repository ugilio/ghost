package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.timeline.lang.TemporalExpression

interface InternalTemporalExpression extends TemporalExpression {
	def void setLeft(Object left);
	def void setRight(Object right);
}