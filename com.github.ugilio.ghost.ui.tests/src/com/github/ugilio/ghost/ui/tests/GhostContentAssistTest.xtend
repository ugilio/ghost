/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.ui.tests

import org.junit.runner.RunWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.InjectWith
import org.junit.Test
import org.eclipse.xtext.ui.testing.AbstractContentAssistTest
import java.util.ArrayList
import org.junit.Ignore

@RunWith(XtextRunner)
@InjectWith(GhostUiInjectorProvider)
class GhostContentAssistTest extends AbstractContentAssistTest {
	
	static final String[] SECT_KWDS = #["transition:","synchronize:","variable:"];
	static final String[] TEMP_OPS = #["equals","meets","starts","finishes","before",
		"after", "contains", "during", "=", "!=", "<", ">", "|="];
	static final String[] RES_ACTS = #["consume","produce","require"];
	static final String[] TEMPPOINT_KWDS = #["start","end"];
	static final String[] ARITH_OPS = #["+","*","-","/","%","=","!=","<",">","<=",">="];
	
	static def String[] j(Object ... args) {
		val l = new ArrayList<String>(args.length);
		for (o : args)
			if (o.getClass().isArray)
				(o as Object[]).forEach[e|l.add(""+e)]
			else if (o instanceof Iterable<?>)
				o.forEach[e|l.add(""+e)]
			else l.add(""+o);
		return l;
	}
	
	@Test
	def void testEmpty1() {
		newBuilder.append("").assertText("domain","problem","import","type","const","comp","init","external","planned");
	}

	@Test
	def void testDomDefined() {
		newBuilder.
			append("domain dom;").
			assertText("import","type","const","comp","init","external","planned");
	}

	@Test
	def void testProblemDefined() {
		newBuilder.
			append("problem prob;").
			assertText("import","type","const","comp","init","external","planned");
	}

	@Test
	def void testImportDefined() {
		newBuilder.
			append("import invalid;").
			assertText("import","type","const","comp","init","external","planned");
	}

	@Test
	def void testTypeDefined() {
		newBuilder.
			append("type i = int [0, 100];").
			assertText("type","const","comp","init","external","planned");
	}

	@Test
	def void testSvType1() {
		newBuilder.append('''
		type T = sv(
		'''
		).
		assertText(j("contr","uncontr",SECT_KWDS));
	}

	@Test
	def void testSvType2() {
		newBuilder.append('''
		type T = sv
		'''
		).
		assertText("T");
	}

	@Test
	def void testTcExpr1() {
		newBuilder.append('''
		type T = sv(
			A -> 
		'''
		).
		assertText("A","inherited","var");
	}

	@Test
	def void testTcExpr2() {
		newBuilder.append('''
		type n = int [0, 100];
		type T = sv(
			A(n x) -> 
		'''
		).
		assertText("x","A","inherited","var");
	}

	@Test
	def void testTcExpr3() {
		newBuilder.append('''
		type n = int [0, 100];
		type T = sv(
			A(n x) -> var y = 
		'''
		).
		assertText("x","A");
	}

	@Test
	def void testTcExpr4() {
		newBuilder.append('''
		const C = 100;
		type T = sv(
			A -> 
		'''
		).
		assertText("C","A","inherited","var");
	}

	@Test
	def void testTcExpr5() {
		newBuilder.append('''
		type E = enum (EN1, EN2);
		type T = sv(
			A -> 
		'''
		).
		assertText("EN1","EN2","A","inherited","var");
	}
	
	@Test
	def void testTcExpr6() {
		newBuilder.append('''
		type E = enum (EN1, EN2);
		type T = sv(
		variable:
			v : T;
		transition:
			A -> 
		'''
		).
		assertText("EN1","EN2","A","inherited","var");
	}
	
	@Test
	def void testSvSync1() {
		newBuilder.append('''
		type T = sv(A,B
		synchronize:
		'''
		).
		assertText(j("A","B",SECT_KWDS));
	}	

	@Test
	def void testSvSyncBody1() {
		newBuilder.append('''
		type n = int [0, 100];
		const C = 100;
		type E = enum(EN1,EN2);
		comp c : sv(X,Y);
		type T = sv(A(n x),B
		variable:
			v : T;
		synchronize:
			A(x) -> (
		'''
		).
		assertText(j("x","A","B","C","EN1","EN2","c","v","this","var","inherited",TEMP_OPS,RES_ACTS,TEMPPOINT_KWDS));
	}	

	@Test
	def void testSvSyncTemp1() {
		newBuilder.append('''
		type n = int [0, 100];
		const C = 100;
		type E = enum(EN1,EN2);
		comp c : sv(X,Y);
		type T = sv(A(n x),B
		variable:
			v : T;
		synchronize:
			A(x) -> ( meets 
		'''
		).
		assertText(j("A","B","c","v","this",RES_ACTS,TEMPPOINT_KWDS));
	}	

	@Test
	def void testSvSyncComp1() {
		newBuilder.append('''
		type n = int [0, 100];
		const C = 100;
		type E = enum(EN1,EN2);
		comp c : sv(X,Y);
		type T = sv(A(n x),B
		variable:
			v : T;
		synchronize:
			A(x) -> ( meets c.
		'''
		).
		assertText("X","Y");
	}	

	@Test
	def void testSvSyncTempVar() {
		newBuilder.append('''
		type n = int [0, 100];
		const C = 100;
		type E = enum(EN1,EN2);
		comp c : sv(X,Y);
		type T = sv(A(n x),B
		variable:
			v : T;
		synchronize:
			A(x) -> (
				var y = this;
				meets 
		'''
		).
		assertText(j("A","B","c","v","y","this",RES_ACTS,TEMPPOINT_KWDS));
	}	

	@Test
	def void testSvSyncNumVar1() {
		newBuilder.append('''
		type n = int [0, 100];
		const C = 100;
		type E = enum(EN1,EN2);
		comp c : sv(X,Y);
		type T = sv(A(n x),B
		variable:
			v : T;
		synchronize:
			A(x) -> (
				var y = 12;
				y - 
		'''
		).
		assertText("x","y","C");
	}	

	@Test
	def void testSvSyncNumVar2() {
		newBuilder.append('''
		type n = int [0, 100];
		const C = 100;
		type E = enum(EN1,EN2);
		comp c : sv(X,Y);
		type T = sv(A(E x),B
		variable:
			v : T;
		synchronize:
			A(x) -> (
				var y = 12;
				y - 
		'''
		).
		assertText("y","C");
	}	

	@Test
	def void testSvSyncNumVar3() {
		newBuilder.append('''
		type n = int [0, 100];
		const C = 100;
		type E = enum(EN1,EN2);
		comp c : sv(X,Y);
		type T = sv(A(n x),B
		variable:
			v : T;
		synchronize:
			A(x) -> (
				var y = 12;
				y 
		'''
		).
		assertText(j(ARITH_OPS));
	}
	
	@Test
	def void testSvSyncUnkVar1() {
		newBuilder.append('''
		type n = int [0, 100];
		const C = 100;
		type E = enum(EN1,EN2);
		comp c : sv(X,Y);
		type T = sv(A(n x),B
		variable:
			v : T;
		synchronize:
			A(x) -> (
				var y = _;
				meets 
		'''
		).
		assertText(j("A","B","c","v","y","this",RES_ACTS,TEMPPOINT_KWDS));
	}
	
	@Test
	def void testSvSyncUnkVar2() {
		newBuilder.append('''
		type n = int [0, 100];
		const C = 100;
		type E = enum(EN1,EN2);
		comp c : sv(X,Y);
		type T = sv(A(n x),B
		variable:
			v : T;
		synchronize:
			A(x) -> (
				var y = _;
				x - 
		'''
		).
		assertText("C","x","y");
	}	

	@Test
	def void testSvSyncResAction1() {
		newBuilder.append('''
		type n = int [0, 100];
		const C = 100;
		type E = enum(EN1,EN2);
		comp c : sv(X,Y);
		comp R : resource(10);
		type T2 = resource(20);
		type T = sv(A(n x),B
		variable:
			v : T2;
		synchronize:
			A(x) -> (
			require 
		'''
		).
		assertText("v","R");
	}	

	@Test
	def void testSvSyncResAction2() {
		newBuilder.append('''
		type n = int [0, 100];
		const C = 100;
		type E = enum(EN1,EN2);
		comp c : sv(X,Y);
		comp R : resource(10);
		type T2 = resource(20,30);
		type T = sv(A(n x),B
		variable:
			v : T2;
		synchronize:
			A(x) -> (
			require 
		'''
		).
		assertText("R");
	}	

	@Test
	def void testSvSyncResAction3() {
		newBuilder.append('''
		type n = int [0, 100];
		const C = 100;
		type E = enum(EN1,EN2);
		comp c : sv(X,Y);
		comp R : resource(10);
		type T2 = resource(20,30);
		type T = sv(A(n x),B
		variable:
			v : T2;
		synchronize:
			A(x) -> (
			consume 
		'''
		).
		assertText("v");
	}
		
	@Test
	def void testRResSync1() {
		newBuilder.append('''
		type R = resource(10
		synchronize:
		'''
		).
		assertText("require","synchronize:","variable:");
	}	

	@Test
	def void testCResSync1() {
		newBuilder.append('''
		type R = resource(10,20
		synchronize:
		'''
		).
		assertText("produce","consume","synchronize:","variable:");
	}
	
	//FIXME: does not work due to syntax errors... 
	@Ignore @Test
	def void testResSyncNumPar1() {
		newBuilder.append('''
		type T = resource(10
		synchronize:
			require(x) -> 10 < 
		'''
		).
		assertText("x");
	}
	
	//FIXME: does not work due to syntax errors... 
	@Ignore @Test
	def void testResSync2() {
		newBuilder.append('''
		comp c : sv(A,B);
		type T = resource(10
		synchronize:
			require(x) -> starts  
		'''
		).
		assertText(j("c","this",RES_ACTS,TEMPPOINT_KWDS));
	}
		
	//FIXME: does not work due to syntax errors... 
	@Ignore @Test
	def void testResSync3() {
		newBuilder.append('''
		comp c : sv(A,B);
		type T = resource(10
		synchronize:
			require(x) -> starts c.
		'''
		).
		assertText("A","B");
	}
	
	@Test
	def void testBindList1() {
		newBuilder.append('''
		type T1 = sv(A,B
		variable:
			v : T2
		);
		type T2 = sv(C,D);
		comp C2 : T2;
		comp C1 : T1[
		'''
		).
		assertText("v","C2");
	}
	
	@Test
	def void testBindList1a() {
		newBuilder.append('''
		type T1 = sv(A,B
		variable:
			v : T2
		);
		type T2 = sv(C,D);
		comp C2 : T2;
		comp C1 : T1[v = 
		'''
		).
		assertText("C2");
	}
	
	@Test
	def void testBindList2() {
		newBuilder.append('''
		type T1 = sv T2(A,B
		variable:
			v : T2
		);
		type T2 = sv(C,D);
		comp C3 : sv;
		comp C2 : T2;
		comp C1 : T1[
		'''
		).
		assertText("v","C1","C2");
	}
	
	@Test
	def void testComp1() {
		newBuilder.append('''
		type n = int [0, 100];
		const C = 100;
		type E = enum(EN1,EN2);
		
		type T1 = sv(A,B);
		type T2 = sv(C,D);
		comp c : 
		'''
		).
		assertText("T1","T2","sv","resource");
	}
	
	@Test
	def void testInit1() {
		newBuilder.append('''
		type n = int [0, 100];
		const C = 100;
		type E = enum(EN1,EN2);
		
		type T1 = sv(A,B);
		type T2 = sv(C,D);
		comp c1 : T1;
		comp c2 : T2;
		
		init (
			fact 
		'''
		).
		assertText(j("c1","c2",RES_ACTS));
	}
	
	@Test
	def void testInit2() {
		newBuilder.append('''
		type n = int [0, 100];
		const C = 100;
		type E = enum(EN1,EN2);
		comp c : sv(X,Y);
		type T = sv(A(n x),B
		variable:
			v : T;
		);
		init (
			var y = 
		'''
		).
		assertText(j("C","EN1","EN2","c","y",RES_ACTS,TEMPPOINT_KWDS));
	}	
	
	@Test
	def void testApplyValue1() {
		val content = '''
		type n = int [0, 100];
		type t = sv(A(n x),
			B -> 
		''';
		newBuilder.append(content).
			applyProposal("A").
			expectContent(content+"A(x)");
	}
	
	@Test
	def void testApplyValue2() {
		val content = '''
		type n = int [0, 100];
		type t = sv(A(n x, n y, n z),
			B -> 
		''';
		newBuilder.append(content).
			applyProposal("A").
			expectContent(content+"A(x, y, z)");
	}
	
	@Test
	def void testApplyValue3() {
		val content = '''
		type n = int [0, 100];
		type t = sv(A(n,n,n),
			B -> 
		''';
		newBuilder.append(content).
			applyProposal("A").
			expectContent(content+"A(arg1, arg2, arg3)");
	}
	
	@Test
	def void testApplyResAction1() {
		val content = '''
		comp c : resource(10);
		type t = sv(
			A -> require 
		''';
		newBuilder.append(content).
			applyProposal("c").
			expectContent(content+"c(amount)");
	}
	
	@Test
	def void testApplyResAction2() {
		val content = '''
		comp c : resource(10,20);
		type t = sv(
			A -> consume 
		''';
		newBuilder.append(content).
			applyProposal("c").
			expectContent(content+"c(amount)");
	}
	
	@Test
	def void testApplyResAction3() {
		val content = '''
		comp c : resource(10,20);
		type t = sv(
			A -> produce 
		''';
		newBuilder.append(content).
			applyProposal("c").
			expectContent(content+"c(amount)");
	}
	
	@Test
	def void testApplySvTrigger1() {
		val content = '''
		type n = int [0, 100];
		type t = sv(A(n,n,n)
		synchronize:
			
		''';
		newBuilder.append(content).
			applyProposal("A").
			expectContent(content+"A(arg1, arg2, arg3) -> ");
	}
	
	@Test
	def void testApplyResActionTrigger1() {
		val content = '''
		type t = resource(10,
		synchronize:
			
		''';
		newBuilder.append(content).
			applyProposal("require").
			expectContent(content+"require(amount) -> ");
	}
	
	@Test
	def void testApplyResActionTrigger2() {
		val content = '''
		type t = resource(10,20,
		synchronize:
			
		''';
		newBuilder.append(content).
			applyProposal("produce").
			expectContent(content+"produce(amount) -> ");
	}
	
	@Test
	def void testApplyResActionTrigger3() {
		val content = '''
		type t = resource(10,20,
		synchronize:
			
		''';
		newBuilder.append(content).
			applyProposal("consume").
			expectContent(content+"consume(amount) -> ");
	}
	
	@Test
	def void testComplex() {
		newBuilder.append(
		'''
domain dom;

type n = int [0,100];

type e = enum (en1,en2);

type T = sv (
	A(n x) -> B;
	B -> A;
variable:
	v : dom.T;
synchronize:
	A(x) -> (
		meets 
		equals c2.C;
		var y = A;
	);
);

type r = resource(10,20
synchronize:
consume(x) -> ()
variable:
	v : dom.T;
);

comp c : resource(20,30);
comp c2: sv(C,D);

init (
	var start = 0;
	fact c2.C;
);		'''			
		).
		assertTextAtCursorPosition("meets ",6,"y","A", "B", "c", "c2", "v", "this", "start",
			"end", "require", "consume", "produce");
	}
}