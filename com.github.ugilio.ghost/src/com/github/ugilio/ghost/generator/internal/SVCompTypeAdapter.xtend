/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import java.util.List
import com.github.ugilio.ghost.ghost.ValueDecl
import com.github.ugilio.ghost.ghost.TransConstraint

interface SVCompTypeAdapter extends CompTypeAdapter {
	def List<ValueDecl> getDeclaredValues();
	def List<TransConstraint> getDeclaredTransitionConstraints();
}
