package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.timeline.lang.SyncTrigger

abstract class AbstractSyncTriggerProxy extends ProxyObject implements SyncTrigger {
	protected abstract def LexicalScope getScope();
	
	new(Register register) {
		super(register);
	}
}
