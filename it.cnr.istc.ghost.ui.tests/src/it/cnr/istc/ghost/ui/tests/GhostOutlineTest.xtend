package it.cnr.istc.ghost.ui.tests

import org.eclipse.xtext.ui.testing.AbstractOutlineTest
import org.junit.runner.RunWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.InjectWith
import org.junit.Test

@RunWith(XtextRunner)
@InjectWith(GhostUiInjectorProvider)
class GhostOutlineTest extends AbstractOutlineTest {
	
	override protected getEditorId() {
		return "it.cnr.istc.ghost.Ghost";
	}
	
	@Test
	def void testDomain1() {
		'''
		domain MyDomain;
		'''.assertAllLabels(
		'''MyDomain'''			
		);
	}
	
	@Test
	def void testProblem1() {
		'''
		problem MyProblem;
		'''.assertAllLabels(
		'''MyProblem'''			
		);
	}
	
	@Test
	def void testImport1() {
		'''
		import someImport;
		'''.assertAllLabels(
		'''someImport'''			
		);
	}
	
	@Test
	def void testIntType1() {
		'''
		type aIntType = int [0, 100];
		'''.assertAllLabels(
		'''aIntType'''			
		);
	}
	
	@Test
	def void testEnumType1() {
		'''
		type aEnumType = enum(E1, E2)
		'''.assertAllLabels(
		'''
		aEnumType
		  E1
		  E2
		'''			
		);
	}
	
	@Test
	def void testEnumType2() {
		'''
		type aEnumType = enum
		'''.assertAllLabels(
		'''
		aEnumType
		'''			
		);
	}
	
	@Test
	def void testConst1() {
		'''
		const A_CONSTANT = 217+2-7;
		'''.assertAllLabels(
		'''
		A_CONSTANT
		'''			
		);
	}
	
	@Test
	def void testStateVariable1() {
		'''
type aStateVariable = sv;
		'''.assertAllLabels(
		'''
		aStateVariable
		'''			
		);
	}
	
	@Test
	def void testStateVariable2() {
		'''
external type aStateVariable = sv(
	contr A(aIntType x) [10,20] -> B;
	uncontr B -> C;
synchronize:
	B -> require aVar(10);
transition:
	C -> A;
variable:
	aVar : aRenewableResource;
);		'''.assertAllLabels(
		'''
		aStateVariable
		  A(aIntType)
		  B()
		  B()
		  C()
		  aVar: aRenewableResource
		'''			
		);
	}
	
	@Test
	def void testResource1() {
		'''
planned type aRenewableResource = resource (30
synchronize:
	require(x) -> x < 10 or x > 20;
);
		'''.assertAllLabels(
		'''
		aRenewableResource
		  require(x)
		'''			
		);
	}
	
	@Test
	def void testResource2() {
		'''
planned type aConsumableResource = resource (10,20
synchronize:
	consume(x) -> x > 0;
variable:
	anotherVar : aStateVariable;
);
		'''.assertAllLabels(
		'''
		aConsumableResource
		  consume(x)
		  anotherVar: aStateVariable
		'''			
		);
	}
	
	@Test
	def void testComp1() {
		'''
		comp c1 : sv;
		'''.assertAllLabels(
		'''
		c1
		'''			
		);
	}
	
	@Test
	def void testComp2() {
		'''
comp aComp : aStateVariable[aRRes] (
	uncontr A(aIntType x) [10,20] -> inherited;	
);
		'''.assertAllLabels(
		'''
		aComp
		  A(aIntType)
		'''			
		);
	}
	
	@Test
	def void testComp3() {
		'''
external type aStateVariable = sv(
	contr A(aIntType x) [10,20] -> B;
	uncontr B -> C;
synchronize:
	B -> require aVar(10);
transition:
	C -> A;
variable:
	aVar : aRenewableResource;
);

planned type aRenewableResource = resource (30);
comp aRRes : aRenewableResource;

comp aComp : aStateVariable[aRRes] (
	uncontr A(aIntType x) [10,20] -> inherited;	
);
		'''.assertAllLabels(
		'''
		aStateVariable
		  A(aIntType)
		  B()
		  B()
		  C()
		  aVar: aRenewableResource
		aRenewableResource
		aRRes
		aComp
		  A(aIntType)
		'''			
		);
	}
	
	@Test
	def void testInit1() {
		'''
init (
	var start = 0; var horizon = 100; var resolution = 200; 
);
		'''.assertAllLabels(
		'''
		init
		'''			
		);
	}
	
/*
	@Test
	def void testVeryBig() {
		'''
domain MyDomain;

import TheDomain;

type aIntType = int [0, 100];

type aEnumType = enum(E1, E2);
//type anotherEnumType = enum;

const A_CONSTANT = 217;

external type aStateVariable = sv(
	contr A(aIntType x) [10,20] -> B;
	uncontr B -> C;
synchronize:
	B -> require aVar(10);
transition:
	C -> A;
variable:
	aVar : aRenewableResource;
);

type anotherStateVariable = sv(D,E);

planned type aRenewableResource = resource (30
synchronize:
	require(x) -> x < 10 or x > 20;
);

planned type aConsumableResource = resource (10,20
synchronize:
	consume(x) -> x > 0;
variable:
	anotherVar : aStateVariable;
);

external comp aComp2 : anotherStateVariable;

comp aRRes : aRenewableResource;
comp aCRes : aConsumableResource[aComp];

comp aComp : aStateVariable[aRRes] (
	uncontr A(aIntType x) [10,20] -> inherited;	
);


init (
	var start = 0; var horizon = 100; var resolution = 200; 
	fact aComp.A at 0 10 20;
	fact aComp2.D at 0 10 20;
	goal aComp.B; 
);		'''.assertAllLabels(
		'''
MyDomain
TheDomain
aIntType
aEnumType
  E1
  E2
A_CONSTANT
aStateVariable
  A(aIntType)
  B()
  B()
  C()
  aVar: aRenewableResource
anotherStateVariable
  D()
  E()
aRenewableResource
  require(x)
aConsumableResource
  consume(x)
  anotherVar: aStateVariable
aComp2
aRRes
aCRes
aComp
  A(aIntType)
init]'''			
		);
	}
 */	
}