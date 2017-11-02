package it.cnr.istc.ghost.generator.internal

import static extension it.cnr.istc.ghost.generator.internal.Utils.*;
import it.cnr.istc.ghost.ghost.EnumDecl
import it.cnr.istc.timeline.lang.EnumLiteral
import it.cnr.istc.timeline.lang.EnumType
import java.util.List

class EnumTypeProxy extends ProxyObject implements EnumType, InternalSimpleType {
	EnumDecl real = null;
	String name = null;
	List<EnumLiteral> values = null;

	new(EnumDecl real, Register register) {
		super(register);
		this.real = real;
	}

	override getName() {
		if (name !== null)
			return name;
		return real.name;
	}

	override getValues() {
		if (values === null) {
			values = real.values.map[v|getProxy(v) as EnumLiteral].toRegularList;
		}
		return values;
	}
	
	override setName(String name) {
		this.name = name;
	}
}
	