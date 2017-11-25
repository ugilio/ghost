/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package it.cnr.istc.ghost.generator.internal

import static extension it.cnr.istc.ghost.generator.internal.Utils.*;
import it.cnr.istc.timeline.lang.StatementBlock
import it.cnr.istc.timeline.lang.SyncTrigger
import it.cnr.istc.timeline.lang.Synchronization
import java.util.List

class SynchronizationProxy extends ProxyObject implements Synchronization {
	it.cnr.istc.ghost.ghost.Synchronization real = null;
	List<StatementBlock> bodies = null;

	new(it.cnr.istc.ghost.ghost.Synchronization real, Register register) {
		super(register);
		this.real = real;
	}

	override getTrigger() {
		return getProxy(real.trigger) as SyncTrigger;
	}

	override getBodies() {
		if (bodies === null) {
			val scope = (getTrigger() as AbstractSyncTriggerProxy).getScope();
			bodies = real.bodies.map[b|new BlockImpl(new BlockAdapterImpl(b), scope, register) as StatementBlock].toRegularList;
		}
		return bodies;
	}

}
