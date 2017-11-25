/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package it.cnr.istc.ghost.conversion

import it.cnr.istc.ghost.ghost.GhostFactory
import it.cnr.istc.ghost.ghost.Interval
import com.google.inject.Inject
import it.cnr.istc.ghost.ghost.NumAndUnit

class IntervalHelper {
	
	@Inject extension NumAndUnitHelper numHelper;
	
	def create(long lb, long ub) {
		val intv = GhostFactory.eINSTANCE.createInterval();
		intv.lb = GhostFactory.eINSTANCE.createNumAndUnit();
		intv.ub = GhostFactory.eINSTANCE.createNumAndUnit();
		intv.lb.value=lb;
		intv.ub.value=ub;
		return intv;
	}
	
	def create(long lbub) {
		val intv = GhostFactory.eINSTANCE.createInterval();
		intv.lbub = GhostFactory.eINSTANCE.createNumAndUnit();
		intv.lbub.value=lbub;
		return intv;
	}
	
	def Long lb(Interval intv) {
		return get(intv.getLb());
	}
	
	def Long ub(Interval intv) {
		return get(intv.getUb());
	}

	def Long lbub(Interval intv) {
		return get(intv.getLbub());
	}
	
	def void setLb(Interval intv, Long value) {
		set(intv.lb,value);
	}
	
	def void setUb(Interval intv, Long value) {
		set(intv.ub,value);
	}
	
	def void setLbUb(Interval intv, Long value) {
		set(intv.lbub,value);
	}
	
	private def set(NumAndUnit num, Long value) {
		var n = num;
		if (n === null)
			n = GhostFactory.eINSTANCE.createNumAndUnit();
		n.value=value;
		return n;
	}
}