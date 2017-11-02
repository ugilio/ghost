package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.timeline.lang.Parameter
import it.cnr.istc.timeline.lang.SimpleType

class ParameterImpl implements Parameter {
	String name;
	SimpleType type;

	new(String name, SimpleType type) {
		this.name = name;
		this.type = type;
	}

	override getName() {
		return name;
	}

	override getType() {
		return type;
	}

	protected def setName(String name) {
		this.name = name;
	}
}
