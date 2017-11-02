package it.cnr.istc.ghost.generator.internal

import static extension it.cnr.istc.ghost.generator.internal.Utils.*;
import it.cnr.istc.ghost.ghost.ValueDecl
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
