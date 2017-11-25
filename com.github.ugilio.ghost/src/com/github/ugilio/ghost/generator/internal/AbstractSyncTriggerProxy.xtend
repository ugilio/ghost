/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import it.cnr.istc.timeline.lang.SyncTrigger

abstract class AbstractSyncTriggerProxy extends ProxyObject implements SyncTrigger {
	protected abstract def LexicalScope getScope();
	
	new(Register register) {
		super(register);
	}
}
