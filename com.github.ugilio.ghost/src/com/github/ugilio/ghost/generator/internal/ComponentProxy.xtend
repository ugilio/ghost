/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import static extension com.github.ugilio.ghost.generator.internal.Utils.*;
import com.github.ugilio.ghost.ghost.AnonResDecl
import com.github.ugilio.ghost.ghost.AnonSVDecl
import com.github.ugilio.ghost.ghost.CompBody
import com.github.ugilio.ghost.ghost.CompDecl
import com.github.ugilio.ghost.ghost.NamedCompDecl
import it.cnr.istc.timeline.lang.CompType
import it.cnr.istc.timeline.lang.Component
import it.cnr.istc.timeline.lang.ComponentReference
import it.cnr.istc.timeline.lang.ComponentVariable
import java.util.HashMap
import java.util.List
import java.util.Collections

class ComponentProxy extends ProxyObject implements Component {
	CompDecl real = null;
	String name = null;
	CompType type = null;
	List<ComponentReference> bindings = null;
	HashMap<ComponentVariable, Component> map = null;

	new(CompDecl real, Register register) {
		super(register);
		this.real = real;
	}

	override getName() {
		if (name !== null)
			return name;
		return real.name;
	}

	override getType() {
		if (type === null) {
			type = if (needsSyntheticType(real))
				createSyntheticType(real,register)
			else if (real instanceof NamedCompDecl)
				getProxy(real.type) as CompType;
		}
		return type;
	}

	override getVariableBindings() {
		if (bindings === null) {
			val body = switch (real) {
				NamedCompDecl: real.body
				AnonSVDecl: real.body as CompBody
				AnonResDecl: real.body as CompBody
				default: throw new IllegalArgumentException("Wrong CompDecl type: " + real)
			}
			bindings = getProxy(body.getBindings()) as List<ComponentReference>;
			if (bindings === null)
				bindings = Collections.emptyList();
		}
		return bindings;
	}

	override getVariableMapping() {
		if (map === null) {
			map = new HashMap<ComponentVariable, Component>();
			var fromType = getType.getVariables();
			var fromComp = getVariableBindings();
			val size = fromComp.size();
			for (var i = 0; i < size; i++) {
				val binding = fromComp.get(i);
				val v = binding.variableRef;
				if (v !== null)
					map.put(v, binding.component)
				else
					map.put(fromType.get(i), binding.component);
			}
		}
		return map;
	}
	
	public def setName(String name) {
		this.name = name;
	}

}
