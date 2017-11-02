package it.cnr.istc.ghost.generator.internal

import static extension it.cnr.istc.ghost.generator.internal.Utils.*;
import it.cnr.istc.ghost.ghost.AnonResDecl
import it.cnr.istc.ghost.ghost.AnonSVDecl
import it.cnr.istc.ghost.ghost.CompBody
import it.cnr.istc.ghost.ghost.CompDecl
import it.cnr.istc.ghost.ghost.NamedCompDecl
import it.cnr.istc.timeline.lang.CompType
import it.cnr.istc.timeline.lang.Component
import it.cnr.istc.timeline.lang.ComponentReference
import it.cnr.istc.timeline.lang.ComponentVariable
import java.util.HashMap
import java.util.List

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
