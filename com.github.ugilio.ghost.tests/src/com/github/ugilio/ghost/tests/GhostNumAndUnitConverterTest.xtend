/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * generated by Xtext 2.12.0
 */
package com.github.ugilio.ghost.tests

import com.google.inject.Inject
import com.github.ugilio.ghost.ghost.Ghost
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*
import static org.hamcrest.CoreMatchers.*
import org.eclipse.xtext.EcoreUtil2
import com.github.ugilio.ghost.ghost.Interval
import com.github.ugilio.ghost.conversion.NumAndUnitValueConverter
import com.github.ugilio.ghost.conversion.IntervalHelper

@RunWith(XtextRunner)
@InjectWith(GhostInjectorProvider)
class GhostNumAndUnitConverterTest{

	@Inject
	ParseHelper<Ghost> parseHelper
	
	@Inject
	NumAndUnitValueConverter converter;
	
	@Inject extension IntervalHelper intvHelper;
	
	@Test
	def void testToValue1() {
		val result = parseHelper.parse('''
type test = int 100 ms;
		''')
		val intv = EcoreUtil2.eAllOfType(result,Interval).head;
		val value = intv.lbub();
		assertThat(value,is(100L));
	}
	
	@Test
	def void testToValue2() {
		val result = parseHelper.parse('''
type test = int 100 s;
		''')
		val intv = EcoreUtil2.eAllOfType(result,Interval).head;
		val value = intv.lbub();
		assertThat(value,is(100_000L));
	}
	
	@Test
	def void testToValuePosInf() {
		val result = parseHelper.parse('''
type test = int INF s;
		''')
		val intv = EcoreUtil2.eAllOfType(result,Interval).head;
		val value = intv.lbub();
		assertThat(value,is(equalTo(Long.MAX_VALUE)));
	}
	
	@Test
	def void testToValueNegInf() {
		val result = parseHelper.parse('''
type test = int -INF s;
		''')
		val intv = EcoreUtil2.eAllOfType(result,Interval).head;
		val value = intv.lbub();
		assertThat(value,is(equalTo(Long.MIN_VALUE)));
	}
	
	@Test()
	def void testInvalidUnit() {
		val result = parseHelper.parse('''
type test = int 10 bananas;
		''')
		val err = result.eResource.errors;
		assertThat(err.size,is(1));
		assertThat(err.get(0).message,is(equalTo("Undefined unit: 'bananas'")));
	}
	
	@Test
	def void testToStringPositive() {
		val value = converter.toString(100L);
		assertThat(value,is(equalTo("100")));
	}
	
	@Test
	def void testEmptyInput() {
		val value = converter.toValue("100 ms",null);
		assertThat(value,is(equalTo(100L)));
	}
	
}