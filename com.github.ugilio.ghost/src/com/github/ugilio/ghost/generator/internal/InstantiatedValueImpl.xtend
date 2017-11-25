/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import it.cnr.istc.timeline.lang.InstantiatedValue
import java.util.ArrayList
import java.util.List

class InstantiatedValueImpl implements InstantiatedValue {
	Object comp = null;
	Object value = null;
	List<Object> arguments = null;
	boolean thisSync = false;

	new(Object comp, Object value, List<Object> arguments) {
		this.comp = comp;
		this.value = value;
		this.arguments = if(arguments === null) null else new ArrayList(arguments);
	}

	override getComponent() {
		return comp;
	}

	override getValue() {
		return value;
	}

	override getArguments() {
		return arguments;
	}

	override isThisSync() {
		return thisSync;
	}
	
	package def setThisSync(boolean thisSync) {
		this.thisSync = thisSync;
	}
	
	package def setArguments(List<Object> arguments) {
		this.arguments = arguments;
	}
}
