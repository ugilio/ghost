/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import it.cnr.istc.timeline.lang.ResourceType
import com.github.ugilio.ghost.ghost.ConstPlaceHolder

abstract class ResourceTypeProxy extends AbstractCompTypeProxy implements ResourceType {

	protected ResCompTypeAdapter real;

	new(Object real, Register register) {
		super(real,register);
		this.real = super.real as ResCompTypeAdapter;
	}

	override isConsumable() {
		return false;
	}

	override isRenewable() {
		return false;
	}
	
	private def boolean isSpecifiedValue(Object theValue) {
		return theValue !== null && !(theValue instanceof ConstPlaceHolder);
	}
	
	protected def long getValue1() {
		if (isSpecifiedValue(real?.val1) || parent === null)
			return getAValue(real?.val1);
		return (parent as ResourceTypeProxy).getValue1();
	}

	protected def long getValue2() {
		if (isSpecifiedValue(real?.val2) || parent === null)
			return getAValue(real?.val2);
		return (parent as ResourceTypeProxy).getValue2();
	}

	protected def getAValue(Object theValue) {
		if (theValue === null)
			throw new IllegalArgumentException("Invalid argument: null value");
		if (theValue instanceof ConstPlaceHolder)
			return 0L;
		return theValue as Long;
	}
}
