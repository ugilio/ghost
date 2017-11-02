package it.cnr.istc.ghost.generator.internal

import static extension it.cnr.istc.ghost.generator.internal.Utils.*;
import it.cnr.istc.ghost.ghost.ResSimpleInstVal
import it.cnr.istc.timeline.lang.Parameter
import it.cnr.istc.timeline.lang.ResSyncTrigger
import it.cnr.istc.timeline.lang.ResourceAction

class ResSyncTriggerProxy extends AbstractSyncTriggerProxy implements ResSyncTrigger {
	ResSimpleInstVal real = null;
	LexicalScope scope = null;
	Parameter arg = null;

	new(ResSimpleInstVal real, Register register) {
		super(register);
		this.real = real;
	}

	override getAction() {
		return getProxy(real?.type) as ResourceAction;
	}

	override getArgument() {
		if (arg === null) {
			scope = new LexicalScope(null);

			arg = getProxy(real?.arg) as Parameter;
			if (isUnnamed(arg.name))
				(arg as ParameterImpl).name = genName("amount", scope, true);
			scope.add(arg.name, arg);
		}

		return arg;
	}

	override protected getScope() {
		if (scope === null)
			getArgument();
		return scope;
	}

}
