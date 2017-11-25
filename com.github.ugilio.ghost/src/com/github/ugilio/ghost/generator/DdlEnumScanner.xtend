/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator

import com.google.common.collect.Iterables
import com.google.common.collect.Lists
import it.cnr.istc.timeline.lang.CompType
import it.cnr.istc.timeline.lang.EnumLiteral
import it.cnr.istc.timeline.lang.Expression
import it.cnr.istc.timeline.lang.SVType
import it.cnr.istc.timeline.lang.SimpleType
import it.cnr.istc.timeline.lang.StatementBlock
import it.cnr.istc.timeline.lang.Variable
import java.util.ArrayList
import java.util.List

class DdlEnumScanner {
	
	public def List<SimpleType> scanSimpleTypeUsage(CompType type) {
		val sList = 
		type.synchronizations.
			map[s|s.bodies].flatten.
			map[scanSimpleTypeUsage].flatten;
		val tList = switch (type) {
			SVType : type.transitionConstraints.
				map[tc|tc.body].
				map[scanSimpleTypeUsage].flatten
			default : #[]
		}
		return Lists.newArrayList(Iterables.concat(sList,tList));
	}
	
	public def List<SimpleType> scanSimpleTypeUsage(StatementBlock block) {
		val data = Iterables.concat(block.expressions,block.variables);
		return new ArrayList(data.map[o|getEnums(o)].flatten.toList);
	}
	
	private def dispatch List<SimpleType> getEnums(EnumLiteral l) {
		return #[l.getEnum()];
	}
	
	private def dispatch List<SimpleType> getEnums(Expression e) {
		return e.operands.map[o|getEnums(o)].flatten.toList;
	}
	
	private def dispatch List<SimpleType> getEnums(Variable v) {
		return getEnums(v.value);
	}
	
	private def dispatch List<SimpleType> getEnums(Object o) {
		return #[]
	}
	
	private def dispatch List<SimpleType> getEnums(Void o) {
		return #[]
	}
}