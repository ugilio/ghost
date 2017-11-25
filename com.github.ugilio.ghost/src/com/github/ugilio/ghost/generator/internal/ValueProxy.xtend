/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import static extension com.github.ugilio.ghost.generator.internal.Utils.*;
import com.github.ugilio.ghost.ghost.ValueDecl
import it.cnr.istc.timeline.lang.Parameter
import it.cnr.istc.timeline.lang.Value
import java.util.Collections
import java.util.List

class ValueProxy extends ProxyObject implements Value {
	ValueDecl real = null;
	List<Parameter> parlist = null;
	LexicalScope scope = null;

	new(ValueDecl real, Register register) {
		super(register);
		this.real = real;
	}

	override getName() {
		return real.name;
	}

	override getFormalParameters() {
		if (parlist === null) {
			parlist = if (real?.parlist?.values !== null)
				real.parlist.values.map[v|getProxy(v) as Parameter]
			else
				Collections.emptyList();
			scope = new LexicalScope(null);
			parlist.filter[p|!isUnnamed(p.name)].forEach[p|scope.add(p.name,p)];
			parlist.filter[p|isUnnamed(p.name)].forEach [ p |
				(p as ParameterImpl).name = genName(p.type.name, scope, true);
				scope.add(p.name,p)
			];
		}
		return parlist;
	}

	protected def LexicalScope getScope() {
		if (scope === null)
			getFormalParameters();
		return scope;
	}
}
