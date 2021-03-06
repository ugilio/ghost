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
import static com.github.ugilio.ghost.tests.utils.IntervalMatcher.*
import static org.hamcrest.CoreMatchers.*
import org.eclipse.xtext.EcoreUtil2
import com.github.ugilio.ghost.conversion.ConstCalculator
import com.github.ugilio.ghost.ghost.ConstExpr
import com.github.ugilio.ghost.ghost.Interval
import com.github.ugilio.ghost.ghost.EnumLiteral
import com.github.ugilio.ghost.ghost.ConstDecl
import com.github.ugilio.ghost.conversion.ConstCalculator.ConstCalculatorException
import com.github.ugilio.ghost.conversion.IntervalHelper
import com.github.ugilio.ghost.ghost.ConstPlaceHolder

@RunWith(XtextRunner)
@InjectWith(GhostInjectorProvider)
class GhostConstantCalculatorTest{

	@Inject
	ParseHelper<Ghost> parseHelper
	
	@Inject
	ConstCalculator calc;
	
	@Inject extension IntervalHelper intvHelper;
	
	private def intv(long l, long r) {
		return intvHelper.create(l,r);
	}
	
//	private def eq(Interval l, Interval r) {
//		return
//			l.lb == r.lb &&
//			l.ub == r.ub &&
//			l.lbub == r.lbub;
//	}
	
	@Test
	def void testSimpleNumber() {
		val result = parseHelper.parse('''
const c = 1;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp)
		assertThat(value,is(1L));
	}
	
	@Test
	def void testSimpleInterval() {
		val result = parseHelper.parse('''
const c = [1, 1];
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp) as Interval;
		assertThat(value,is(equalTo(intv(1,1))));
	}
	
	@Test
	def void testPlaceholder() {
		val result = parseHelper.parse('''
const c = _;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp);
		assertThat(value,is(instanceOf(ConstPlaceHolder)));
	}
	
	@Test
	def void testSimpleEnumLiteral() {
		val result = parseHelper.parse('''
type e = enum (E1);
const c = E1;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp) as EnumLiteral;
		assertThat(value.name,is(equalTo("E1")));
	}

	@Test
	def void testSimpleConstRef() {
		val result = parseHelper.parse('''
const c1 = 1;
const c2 = c1;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstDecl).filter[name=='c2'].head.value;
		val value = calc.compute(exp)
		assertThat(value,is(1L));
	}
	
	@Test
	def void testSimpleSubExp() {
		val result = parseHelper.parse('''
const c = (1);
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp)
		assertThat(value,is(1L));
	}
	
	@Test
	def void testDoubleConstRef() {
		val result = parseHelper.parse('''
const c1 = 1;
const c2 = c1 + c1;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstDecl).filter[name=='c2'].head.value;
		val value = calc.compute(exp)
		assertThat(value,is(2L));
	}
	
	@Test
	def void testNumAdd() {
		val result = parseHelper.parse('''
const c = 1 + 1;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp)
		assertThat(value,is(2L));
	}
	
	@Test
	def void testNumSub() {
		val result = parseHelper.parse('''
const c = 10 - 2;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp)
		assertThat(value,is(8L));
	}
	
	@Test
	def void testNumMult() {
		val result = parseHelper.parse('''
const c = 10 * 2;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp)
		assertThat(value,is(20L));
	}
	
	@Test
	def void testNumDiv() {
		val result = parseHelper.parse('''
const c = 10 / 2;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp)
		assertThat(value,is(5L));
	}
	
	@Test
	def void testNumMod() {
		val result = parseHelper.parse('''
const c = 10 % 4;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp)
		assertThat(value,is(2L));
	}

	@Test
	def void testNumIntvAdd() {
		val result = parseHelper.parse('''
const c = 1 + [1,2];
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp) as Interval;
		assertThat(value,is(equalTo(intv(2,3))));
	}
	
	@Test
	def void testNumIntvSub() {
		val result = parseHelper.parse('''
const c = 10 - [2,3];
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp) as Interval;
		assertThat(value,is(equalTo(intv(8,7))));
	}
	
	@Test
	def void testNumIntvMul() {
		val result = parseHelper.parse('''
const c = 10 * [2,3];
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp) as Interval;
		assertThat(value,is(equalTo(intv(20,30))));
	}
	
	@Test
	def void testNumIntvDiv() {
		val result = parseHelper.parse('''
const c = 10 / [2,4];
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp) as Interval;
		assertThat(value,is(equalTo(intv(5,2))));
	}
	
	@Test
	def void testNumIntvMod() {
		val result = parseHelper.parse('''
const c = 10 % [3,4];
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp) as Interval;
		assertThat(value,is(equalTo(intv(1,2))));
	}
	
	@Test
	def void testIntvNumAdd() {
		val result = parseHelper.parse('''
const c = [1,2] + 1;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp) as Interval;
		assertThat(value,is(equalTo(intv(2,3))));
	}
	
	@Test
	def void testIntvNumSub() {
		val result = parseHelper.parse('''
const c = [2,3] - 10;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp) as Interval;
		assertThat(value,is(equalTo(intv(-8,-7))));
	}
	
	@Test
	def void testIntvNumMul() {
		val result = parseHelper.parse('''
const c = [2,3] * 10;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp) as Interval;
		assertThat(value,is(equalTo(intv(20,30))));
	}
	
	@Test
	def void testIntvNumDiv() {
		val result = parseHelper.parse('''
const c = [10,20] / 2;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp) as Interval;
		assertThat(value,is(equalTo(intv(5,10))));
	}
	
	@Test
	def void testIntvNumMod() {
		val result = parseHelper.parse('''
const c = [10,20] % 3;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp) as Interval;
		assertThat(value,is(equalTo(intv(1,2))));
	}

	@Test
	def void testIntvAdd() {
		val result = parseHelper.parse('''
const c = [1,2] + [3,4];
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp) as Interval;
		assertThat(value,is(equalTo(intv(4,6))));
	}
	
	@Test
	def void testIntvSub() {
		val result = parseHelper.parse('''
const c = [4,5] - [2,4];
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp) as Interval;
		assertThat(value,is(equalTo(intv(2,1))));
	}
	
	@Test
	def void testIntvMul() {
		val result = parseHelper.parse('''
const c = [2,3] * [4,5];
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp) as Interval;
		assertThat(value,is(equalTo(intv(8,15))));
	}
	
	@Test
	def void testIntvDiv() {
		val result = parseHelper.parse('''
const c = [10,20] / [2,5];
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp) as Interval;
		assertThat(value,is(equalTo(intv(5,4))));
	}
	
	@Test
	def void testIntvMod() {
		val result = parseHelper.parse('''
const c = [10,20] % [3,7];
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp) as Interval;
		assertThat(value,is(equalTo(intv(1,6))));
	}

	@Test(expected = ConstCalculatorException)
	def void testDivZero() {
		val result = parseHelper.parse('''
const c = 10 / 0;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		 calc.compute(exp)
	}
	
	@Test
	def void testComplexExpression1() {
		val result = parseHelper.parse('''
const c = 7*5 + 4/3 - 47;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp)
		assertThat(value,is(35L+1L-47L));
	}
	
	@Test
	def void testComplexExpression2() {
		val result = parseHelper.parse('''
const c = 7*(4+7) * ((12+2) / (9+2)) ;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp)
		assertThat(value,is(77L * (14L / 11L)));
	}
	
	@Test
	def void testComplexExpression3() {
		val result = parseHelper.parse('''
const c1 = 7*8;
const c2 = 7*(4+7) * (c1 / (9+2)) ;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstDecl).filter[name=='c2'].head.value;
		val value = calc.compute(exp)
		assertThat(value,is(77L * (56L / 11L)));
	}
	
	@Test
	def void testEnumParen() {
		val result = parseHelper.parse('''
type e = enum (E1);
const c = (E1);
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		val value = calc.compute(exp) as EnumLiteral;
		assertThat(value.name,is(equalTo("E1")));
	}
	
	@Test(expected = ConstCalculatorException)
	def void testInvalidOp1() {
		val result = parseHelper.parse('''
type e = enum (E1);
const c = E1 + 2;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		calc.compute(exp)
	}
		
	@Test(expected = ConstCalculatorException)
	def void testInvalidOp2() {
		val result = parseHelper.parse('''
type e = enum (E1);
const c = 2 + E1;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		calc.compute(exp)
	}

	@Test(expected = ConstCalculatorException)
	def void testUndefinedConstant() {
		val result = parseHelper.parse('''
const c = 2 + E1;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		EcoreUtil2.resolveAll(exp);
		assertThat(result.eResource.errors.size,is(1));
		calc.compute(exp)
	}
	
	@Test(expected = ConstCalculatorException)
	def void testRecursiveConstant1() {
		val result = parseHelper.parse('''
const c = 2 + c;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstExpr).head;
		calc.compute(exp)
	}
	
	@Test(expected = ConstCalculatorException)
	def void testRecursiveConstant2() {
		val result = parseHelper.parse('''
const c1 = c2;
const c2 = 2 + c1;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstDecl).filter[name=='c2'].head.value;
		calc.compute(exp)
	}
	
	@Test(expected = ConstCalculatorException)
	def void testRecursiveConstant3() {
		val result = parseHelper.parse('''
const c1 = c3;
const c2 = 2 + c1;
const c3 = c2;
		''')
		val exp = EcoreUtil2.eAllOfType(result,ConstDecl).filter[name=='c2'].head.value;
		calc.compute(exp)
	}
	
}
