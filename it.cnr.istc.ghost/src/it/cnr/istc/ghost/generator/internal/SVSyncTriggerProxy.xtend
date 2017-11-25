/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package it.cnr.istc.ghost.generator.internal

import static extension it.cnr.istc.ghost.generator.internal.Utils.*;
import it.cnr.istc.ghost.ghost.SimpleInstVal
import it.cnr.istc.timeline.lang.Parameter
import it.cnr.istc.timeline.lang.SVSyncTrigger
import it.cnr.istc.timeline.lang.Value
import java.util.ArrayList
import java.util.Collections
import java.util.List

class SVSyncTriggerProxy extends AbstractSyncTriggerProxy implements SVSyncTrigger {
	SimpleInstVal real = null;
	List<Parameter> arguments = null;
	LexicalScope scope = null;

	new(SimpleInstVal real, Register register) {
		super(register);
		this.real = real;
	}

	override getValue() {
		return getProxy(real.value) as Value;
	}

	override LexicalScope getScope() {
		if (scope === null)
			getArguments();
		return scope;
	}

	override getArguments() {
		if (arguments === null) {
			scope = new LexicalScope(null);

			var tmp = getProxy(real?.arglist) as List<Parameter>;
			if(tmp === null) tmp = Collections.emptyList();
			val value = getValue();
			val count = if(value?.formalParameters === null) 0 else value.formalParameters.size();

			arguments = new ArrayList(count);
			arguments.addAll(tmp);
			for (var i = tmp.size(); i < count; i++)
				arguments.add(new ParameterImpl(null, value.formalParameters.get(i).type));

			arguments.filter[p|!isUnnamed(p.name)].forEach[p|scope.add(p.name, p)];
			for (var i = 0; i < count; i++) {
				val p = arguments.get(i);
				if (isUnnamed(p.name)) {
					val origName = value?.formalParameters?.get(i)?.name;
					(p as ParameterImpl).name = genName(origName, scope, true);
					scope.add(p.name, p);
				}
			}
		}
		return arguments;
	}

}
