package it.cnr.istc.ghost.generator.internal

import java.util.HashMap

class LexicalScope {
	LexicalScope parent;
	HashMap<String, Object> definitions = new HashMap();

	new(LexicalScope parent) {
		this.parent = parent;
	}

	def add(String name, Object value) {
		definitions.put(name, value);
	}

	def contains(String name) {
		return definitions.containsKey(name);
	}

	def getAllNames() {
		return definitions.keySet;
	}

	def Object get(String name) {
		val v = definitions.get(name);
		if (v === null && parent !== null)
			return parent.get(name);
		return v;
	}
}
