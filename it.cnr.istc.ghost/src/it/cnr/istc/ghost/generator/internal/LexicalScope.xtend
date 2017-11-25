/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
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
