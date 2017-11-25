/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import org.eclipse.emf.ecore.EObject
import it.cnr.istc.timeline.lang.Interval
import com.github.ugilio.ghost.ghost.Externality
import it.cnr.istc.timeline.lang.Controllability
import it.cnr.istc.timeline.lang.TemporalOperator

class ProxyObject {
	protected Register register;
	
	new(Register register) {
		this.register = register;
	}
	
	protected def getProxy(Object real) {
		return register?.getProxy(real);
	}
	
	protected def replaceProxy(Object real, Object proxy) {
		register?.replaceProxy(real,proxy);
	} 
	
	protected def TemporalOperator getTemporalOperator(String name) {
		return register?.getTemporalOperator(name);
	}	
	
	protected def Interval getDefaultInterval(EObject obj) {
		return register?.getDefaultInterval(obj);
	}
	
	protected def Externality getDefaultExternality(EObject obj) {
		return register?.getDefaultExternality(obj);
	}	
	
	protected def Controllability getDefaultControllability(EObject obj) {
		return register?.getDefaultControllability(obj);
	}
}