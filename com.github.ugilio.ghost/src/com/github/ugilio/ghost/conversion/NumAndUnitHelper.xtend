/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.conversion

import com.google.inject.Inject
import com.github.ugilio.ghost.conversion.NumAndUnitValueConverter
import com.github.ugilio.ghost.ghost.NumAndUnit
import org.eclipse.xtext.nodemodel.util.NodeModelUtils

class NumAndUnitHelper {
	
	@Inject
	NumAndUnitValueConverter conv;
	
	def get(NumAndUnit num) {
		if (num === null)
			return 0l;
		if (num.value === null) {
			val node = NodeModelUtils.getNode(num);
			num.value = conv.toValue(node.text,node);
		}
		return num.value;
	}
}