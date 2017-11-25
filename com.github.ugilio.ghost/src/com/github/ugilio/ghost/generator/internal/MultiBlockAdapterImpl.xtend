/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import static extension com.github.ugilio.ghost.generator.internal.Utils.*;
import com.github.ugilio.ghost.ghost.LocVarDecl
import java.util.List
import org.eclipse.emf.ecore.EObject

class MultiBlockAdapterImpl implements BlockAdapter {
	private List<? extends EObject> real;
	
	new(List<? extends EObject> real) {
		this.real = real;
	}

	private def keepLastVarOnly(List<? extends Object> l, String name) {
		val sub = l.filter(LocVarDecl).filter[o|o.name == name].toRegularList;
		for (var i = 0; i < sub.size() - 1; i++)
			l.remove(sub.get(i));
	}

	override getContents() {
		val l = real.map[o|o.eContents()].flatten.toRegularList;
		keepLastVarOnly(l, 'start');
		keepLastVarOnly(l, 'horizon');
		keepLastVarOnly(l, 'resolution');
		return l;
	}

	override getContainer() {
		return null;
	}

	override <T extends EObject> getContainerOfType(Class<T> clazz) {
		return null;
	}

}
