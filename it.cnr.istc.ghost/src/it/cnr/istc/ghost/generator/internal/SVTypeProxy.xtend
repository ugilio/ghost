/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package it.cnr.istc.ghost.generator.internal

import static extension it.cnr.istc.ghost.generator.internal.Utils.*;
import it.cnr.istc.timeline.lang.SVType
import it.cnr.istc.timeline.lang.TransitionConstraint
import it.cnr.istc.timeline.lang.Value
import java.util.Collections
import java.util.List

class SVTypeProxy extends AbstractCompTypeProxy implements SVType {
	SVCompTypeAdapter real;
	List<Value> svValues = null;
	List<TransitionConstraint> transConstr = null;

	new(Object real, Register register) {
		super(real,register);
		this.real = super.real as SVCompTypeAdapter;
	}

	override SVType getParent() {
		return (getProxy(real?.parent) as SVType);
	}

	override getDeclaredValues() {
		if (svValues === null) {
			val tmp = real?.getDeclaredValues();
			svValues = if (tmp !== null)
				tmp.map[v|getProxy(v) as Value].toRegularList
			else
				Collections.emptyList();
		}
		return svValues;
	}

	override getDeclaredTransitionConstraints() {
		if (transConstr === null) {
			val tmp = real?.getDeclaredTransitionConstraints();
			transConstr = if (tmp !== null)
				tmp.map[v|getProxy(v) as TransitionConstraint].toRegularList
			else
				Collections.emptyList();
		}
		return transConstr;
	}

	override getValues() {
		var p = getParent();
		if (p !== null)
			return merge(p.getValues(), getDeclaredValues());
		return getDeclaredValues();
	}

	override getTransitionConstraints() {
		var p = getParent();
		if (p !== null)
			return merge(p.getTransitionConstraints(), getDeclaredTransitionConstraints());
		return getDeclaredTransitionConstraints();
	}
}
