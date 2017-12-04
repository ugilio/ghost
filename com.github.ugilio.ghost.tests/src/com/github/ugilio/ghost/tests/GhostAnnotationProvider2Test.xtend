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

import com.github.ugilio.ghost.ghost.Ghost
import com.github.ugilio.ghost.ghost.GhostPackage
import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.junit.Test
import org.junit.runner.RunWith
import com.github.ugilio.ghost.preprocessor.AnnotationProcessor

@RunWith(XtextRunner)
@InjectWith(GhostInjectorProvider)
class GhostAnnotationProvider2Test{
	
	@Inject extension ParseHelper<Ghost> parseHelper
	@Inject extension ValidationTestHelper
	
	@Test
	def void testWarn1() {
		val result = parseHelper.parse('''
		@ann
		type n = int[0,100];
		''');
		result.assertWarning(GhostPackage.Literals.INT_DECL,
			AnnotationProcessor.ANNOTATION_UNKNOWN_TARGET);
	}
	
	@Test
	def void testErr1() {
		val result = parseHelper.parse('''
		type t = sv (A,B
			@ann
		);
		comp c : t;
		''');
		result.assertError(GhostPackage.Literals.SV_BODY,
			AnnotationProcessor.ANNOTATION_ERROR);
	}
	
	@Test
	def void testType1() {
		val model = '''
			@ann
			type t = sv;
		'''.parse;
		model.assertNoIssues();
//		model.assertNoWarnings(GhostPackage.Literals.SV_DECL,
//			AnnotationProcessor.ANNOTATION_UNKNOWN_TARGET);
	}
	
	@Test
	def void testComp1() {
		val model = '''
			@ann
			comp c : sv;
		'''.parse;
		model.assertNoIssues();
	}
	
	@Test
	def void testTcHead1() {
		val model = '''
			type t = sv(
				@(ann) A -> B, B
			);
		'''.parse;
		model.assertNoIssues();
	}
	
	@Test
	def void testSyncTrigger1() {
		val model = '''
			type t = sv(
				A -> B, B
			synchronize:
				@(ann) A -> 10 > 0;
			);
		'''.parse;
		model.assertNoIssues();
	}
	
	@Test
	def void testSyncTrigger2() {
		val model = '''
			type t = resource(10
			synchronize:
				@(ann) require(x) -> x > 0;
			);
		'''.parse;
		model.assertNoIssues();
	}
	
	@Test
	def void testIcd1() {
		val model = '''
			comp c : sv(
				A -> B, B
			synchronize:
				A -> before @(ann) c.B;
			);
		'''.parse;
		model.assertNoIssues();
	}
	
	@Test
	def void testVariable1() {
		val model = '''
			comp c : sv(
				A -> B, B
			synchronize:
				A -> (
					@(ann) var cd = c.B;
					before cd
				);
			);
		'''.parse;
		model.assertNoIssues();
	}
	
}
