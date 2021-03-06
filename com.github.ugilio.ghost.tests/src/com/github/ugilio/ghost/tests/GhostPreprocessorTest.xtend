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
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import com.github.ugilio.ghost.ghost.GhostPackage
import com.github.ugilio.ghost.linking.GhostLinker
import org.eclipse.xtext.EcoreUtil2
import com.github.ugilio.ghost.ghost.ConstDecl

@RunWith(XtextRunner)
@InjectWith(GhostInjectorProvider)
class GhostPreprocessorTest{

	@Inject
	ParseHelper<Ghost> parseHelper
	
	@Inject extension ValidationTestHelper;
	
	@Test
	def void testUnit1() {
		val result = parseHelper.parse('''
$unit s 10
const test = 1 s;
		''')
		assertThat(result.eResource.errors,is(equalTo(emptyList)));
		val const = EcoreUtil2.eAllOfType(result,ConstDecl).head;
		assertThat(const.value.computed,is(10l));
	}
	
	@Test
	def void testDefaults1() {
		val result = parseHelper.parse('''
$set duration [1,2]
		''')
		assertThat(result.eResource.errors,is(equalTo(emptyList)));
	}
	
	@Test
	def void testInvalid1() {
		val result = parseHelper.parse('''
$set
		''')
		result.assertError(GhostPackage.Literals.GHOST,GhostLinker.PREPROCESSOR_ERROR)
	}
	
	@Test
	def void testInvalid2() {
		val result = parseHelper.parse('''
$unit
		''')
		result.assertError(GhostPackage.Literals.GHOST,GhostLinker.PREPROCESSOR_ERROR)
	}
	
	@Test
	def void testInvalid3() {
		val result = parseHelper.parse('''
$invalid
		''')
		result.assertError(GhostPackage.Literals.GHOST,GhostLinker.PREPROCESSOR_ERROR)
	}
}
