/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import com.github.ugilio.ghost.ghost.ComponentType

abstract class StandardCompTypeAdapter implements CompTypeAdapter {
	ComponentType real;
	
	new(ComponentType real) {
		this.real = real;
	}

	override getReal() {
		return real;
	}

	override getExternality() {
		return real?.externality;
	}

	override getName(Register register) {
		return real?.name;
	}
}
