/*
 * generated by Xtext 2.12.0
 */
package it.cnr.istc.ghost.tests

import com.google.inject.Inject
import it.cnr.istc.ghost.ghost.Ghost
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.Test
import org.junit.runner.RunWith

import org.eclipse.xtext.testing.validation.ValidationTestHelper
import it.cnr.istc.ghost.ghost.GhostPackage
import it.cnr.istc.ghost.validation.GhostValidator

@RunWith(XtextRunner)
@InjectWith(GhostInjectorProvider)
class GhostValidatorTest{

	@Inject extension ParseHelper<Ghost>
	@Inject extension ValidationTestHelper
	
	//Cyclic hierarchy tests
	
	@Test
	def void testHierarchySVSelf() {
		val model = '''
type t = sv t;
		'''.parse;
		model.assertError(GhostPackage.Literals.SV_DECL,
			GhostValidator.CYCLIC_HIERARCHY);
	}
	
	@Test
	def void testHierarchySV2() {
		val model = '''
type t1 = sv t2;
type t2 = sv t1;
		'''.parse;
		model.assertError(GhostPackage.Literals.SV_DECL,
			GhostValidator.CYCLIC_HIERARCHY);
	}
	
	@Test
	def void testHierarchySV3() {
		val model = '''
type t1 = sv t3;
type t2 = sv t1;
type t3 = sv t2;
		'''.parse;
		model.assertError(GhostPackage.Literals.SV_DECL,
			GhostValidator.CYCLIC_HIERARCHY);
	}
	
	@Test
	def void testHierarchyResSelf() {
		val model = '''
type t = resource t(10);
		'''.parse;
		model.assertError(GhostPackage.Literals.RESOURCE_DECL,
			GhostValidator.CYCLIC_HIERARCHY);
	}
	
	@Test
	def void testHierarchyRes2() {
		val model = '''
type t1 = resource t2(10);
type t2 = resource t1(20);
		'''.parse;
		model.assertError(GhostPackage.Literals.RESOURCE_DECL,
			GhostValidator.CYCLIC_HIERARCHY);
	}
	
	@Test
	def void testHierarchyRes3() {
		val model = '''
type t1 = resource t3(10);
type t2 = resource t1(20);
type t3 = resource t2(30);
		'''.parse;
		model.assertError(GhostPackage.Literals.RESOURCE_DECL,
			GhostValidator.CYCLIC_HIERARCHY);
	}
	
	//Empty enum tests
	
	@Test
	def void testEmptyEnum() {
		val model = '''
type en = enum();
		'''.parse;
		model.assertError(GhostPackage.Literals.ENUM_DECL,
			GhostValidator.EMPTY_ENUM);
	}
	
	//Duplicate identifiers test

	@Test
	def void testDupl1() {
		val model = '''
type t1 = sv;
type t1 = sv;
		'''.parse;
		model.assertError(GhostPackage.Literals.GHOST, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	@Test
	def void testDupl2() {
		val model = '''
type t1 = sv;
comp t1 : sv;
		'''.parse;
		model.assertError(GhostPackage.Literals.GHOST, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	@Test
	def void testDupl3() {
		val model = '''
type t1 = int;
const t1 = 10;
		'''.parse;
		model.assertError(GhostPackage.Literals.GHOST, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	@Test
	def void testDupl4() {
		val model = '''
comp t1 : sv;
const t1 = 10;
		'''.parse;
		model.assertError(GhostPackage.Literals.GHOST, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	//Duplicate arguments
	
	@Test
	def void testDuplArgs1() {
		val model = '''
type t = int [0,100];
comp c : sv(
	A(t x, t x);
)
		'''.parse;
		model.assertError(GhostPackage.Literals.FORMAL_PAR_LIST, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	@Test
	def void testDuplArgs2() {
		val model = '''
type t1 = int [0,100];
type t2 = int [0,100];
comp c : sv(
	A(t1 x, t2 x);
)
		'''.parse;
		model.assertError(GhostPackage.Literals.FORMAL_PAR_LIST, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	@Test
	def void testDuplArgs3() {
		val model = '''
type t = int [0,100];
comp c : sv(
	A(t x, t y);
synchronize:
	A(x, x) -> x < 10
)
		'''.parse;
		model.assertError(GhostPackage.Literals.NAME_ONLY_PAR_LIST, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	@Test
	def void testDuplArgsPlaceholder1() {
		val model = '''
type t = int [0,100];
comp c : sv(
	A(t _, t _)
)
		'''.parse;
		model.assertNoErrors;
	}
	
	@Test
	def void testDuplArgsPlaceholder2() {
		val model = '''
type t = int [0,100];
comp c : sv(
	A(t x, t y); B
synchronize:
	A(_, _) -> B
)
		'''.parse;
		model.assertNoErrors;
	}
	
	//Duplicate local variables
	
	@Test
	def void testDuplLocVar1() {
		val model = '''
comp c : sv(
	A -> (var x = 1; var x = 2)
)
		'''.parse;
		model.assertError(GhostPackage.Literals.TRANS_CONSTR_BODY, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	@Test
	def void testDuplLocVar2() {
		val model = '''
type t = int [0,100];
comp c : sv(
	A(t x) -> var x = 1
)
		'''.parse;
		model.assertError(GhostPackage.Literals.TRANS_CONSTR_BODY, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	@Test
	def void testDuplLocVar3() {
		val model = '''
comp c : sv(
	A
synchronize:
	A -> (var x = 1; var x = 2)
)
		'''.parse;
		model.assertError(GhostPackage.Literals.SYNC_BODY, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	@Test
	def void testDuplLocVar4() {
		val model = '''
type t = int [0,100];
comp c : sv(
	A(t x)
synchronize:
	A(x) -> var x = 1
)
		'''.parse;
		model.assertError(GhostPackage.Literals.SYNC_BODY, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	//Duplicate values

	@Test
	def void testDuplValues1() {
		val model = '''
comp c : sv(
	A,A
)
		'''.parse;
		model.assertError(GhostPackage.Literals.TRANS_CONSTRAINT, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	@Test
	def void testDuplValues2() {
		val model = '''
type t = int [0,100];
comp c : sv(
	A(t x),A(t x)
)
		'''.parse;
		model.assertError(GhostPackage.Literals.TRANS_CONSTRAINT, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	@Test
	def void testDuplValues3() {
		val model = '''
type t = int [0,100];
comp c : sv(
	A(t x),A
)
		'''.parse;
		model.assertError(GhostPackage.Literals.TRANS_CONSTRAINT, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	//Duplicate synchronizations
	
	@Test
	def void testDuplSync1() {
		val model = '''
type t = int [0,100];
comp c : sv(
	A(t x)
synchronize:
	A(x) -> x < 10;
	A(x) -> x < 10;
)
		'''.parse;
		model.assertError(GhostPackage.Literals.SYNCHRONIZATION, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	@Test
	def void testDuplSync2() {
		val model = '''
type t = int [0,100];
comp c : sv(
	A(t x), B
synchronize:
	A(x) -> x < 10;
	A(x) -> B;
)
		'''.parse;
		model.assertError(GhostPackage.Literals.SYNCHRONIZATION, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	@Test
	def void testDuplSync3() {
		val model = '''
comp c : resource(10
synchronize:
	require(x) -> x < 10;
	require(x) -> x < 10;
)
		'''.parse;
		model.assertError(GhostPackage.Literals.SYNCHRONIZATION, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	@Test
	def void testDuplSync4() {
		val model = '''
comp c : resource(10
synchronize:
	require(x) -> x < 10;
	require(x) -> (var y = 10; y > x);
)
		'''.parse;
		model.assertError(GhostPackage.Literals.SYNCHRONIZATION, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	//Duplicate object variable
	
	@Test
	def void testDuplObjVar1() {
		val model = '''
type t = sv(
	A
variable:
	other: t,
	other: t
)
		'''.parse;
		model.assertError(GhostPackage.Literals.VARIABLE_SECTION, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	@Test
	def void testDuplObjVar2() {
		val model = '''
type t1 = sv(B);
type t2 = sv(
	A
variable:
	other: t1,
	other: t2
)
		'''.parse;
		model.assertError(GhostPackage.Literals.VARIABLE_SECTION, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	//Duplicate "inherited"
	@Test
	def void testDuplInherited1() {
		val model = '''
type ct = sv(
	A -> B, B
),
type ct2 = sv ct(
	A -> (inherited, inherited)
)
		'''.parse;
		model.assertError(GhostPackage.Literals.TRANS_CONSTR_BODY, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	@Test
	def void testDuplInherited2() {
		val model = '''
type t = int [0,100];
type ct = sv(
	A(t x)
synchronize:
	A(x) -> x < 10
),
type ct2 = sv ct(
synchronize:
	A -> (inherited, inherited)
)
		'''.parse;
		model.assertError(GhostPackage.Literals.SYNC_BODY, GhostValidator.DUPLICATE_IDENTIFIER);
	}
	
	//Duplicate imports
		
	@Test
	def void testDuplImport1() {
		val model = '''
import dom;
import dom;
		'''.parse;
		model.assertError(GhostPackage.Literals.GHOST, GhostValidator.DUPLICATE_IMPORT);
	}
	
	@Test
	def void testDuplImport2() {
		val dom = '''
domain dom;
		'''.parse;
		val model = '''
import dom;
import dom;
		'''.parse(dom.eResource.resourceSet);
		model.assertError(GhostPackage.Literals.GHOST, GhostValidator.DUPLICATE_IMPORT);
	}
	
	@Test
	def void testNoDuplDeclImport() {
		val dom = '''
domain dom;
		'''.parse;
		val model = '''
import dom;
type dom = sv;
		'''.parse(dom.eResource.resourceSet);
		model.assertNoErrors;
	}
	
	@Test
	def void testNoDuplInit() {
		val model = '''
init();
		'''.parse;
		model.assertNoErrors;
	}

	//Checks for QualifInstVal

	@Test
	def void testQualifInstValOk1() {
		val model = '''
type t = int [0,100];
comp c : sv(
	A(t x);
synchronize:
	A(x) -> c.A 
)
		'''.parse;
		model.assertNoErrors;
	}
	
	@Test
	def void testQualifInstValErr2() {
		val model = '''
type t = int [0,100];
comp c : sv(
	A(t x);
synchronize:
	A(x) -> x(1) 
)
		'''.parse;
		model.assertError(GhostPackage.Literals.QUALIF_INST_VAL, GhostValidator.QUALIFINSTVAL_INCOMPATIBLE_ARGS);
	}
	
	//Checks for ResConstr

	@Test
	def void testResourceConstrOk1() {
		val model = '''
comp r : resource(10);
comp c : sv(
	A
synchronize:
	A -> require r(10); 
)
		'''.parse;
		model.assertNoErrors;
	}
	
	@Test
	def void testResourceConstrOk2() {
		val model = '''
type tr = resource(10);
comp r : tr;
comp c : sv(
	A
synchronize:
	A -> require r(10); 
)
		'''.parse;
		model.assertNoErrors;
	}
	
	@Test
	def void testResourceConstrOk3() {
		val model = '''
type tr = resource(10);
type tc = sv(
	A
synchronize:
	A -> require r(10);
variable:
	r : tr; 
)
		'''.parse;
		model.assertNoErrors;
	}
	
	@Test
	def void testResourceConstrErr1() {
		val model = '''
comp r : sv;
comp c : sv(
	A
synchronize:
	A -> require r(10); 
)
		'''.parse;
		model.assertError(GhostPackage.Literals.RES_CONSTR,
			GhostValidator.RESCONSTR_INCOMPATIBLE_COMP);
	}
	
	@Test
	def void testResourceConstrErr2() {
		val model = '''
type tr = sv10);
comp r : tr;
comp c : sv(
	A
synchronize:
	A -> require r(10); 
)
		'''.parse;
		model.assertError(GhostPackage.Literals.RES_CONSTR,
			GhostValidator.RESCONSTR_INCOMPATIBLE_COMP);
	}
	
	@Test
	def void testResourceConstrErr3() {
		val model = '''
type tr = sv;
comp c : sv(
	A
synchronize:
	A -> require r(10);
variable:
	r : tr; 
)
		'''.parse;
		model.assertError(GhostPackage.Literals.RES_CONSTR,
			GhostValidator.RESCONSTR_INCOMPATIBLE_COMP);
	}
	
	@Test
	def void testResourceConstrErr4() {
		val model = '''
comp r : resource(10,20);
comp c : sv(
	A
synchronize:
	A -> require r(10); 
)
		'''.parse;
		model.assertError(GhostPackage.Literals.RES_CONSTR,
			GhostValidator.RESACTION_WRONGRES);
	}
	
	@Test
	def void testResourceConstrErr5() {
		val model = '''
comp r : resource(10);
comp c : sv(
	A
synchronize:
	A -> produce r(10); 
)
		'''.parse;
		model.assertError(GhostPackage.Literals.RES_CONSTR,
			GhostValidator.RESACTION_WRONGRES);
	}
	
	@Test
	def void testResourceConstrErr6() {
		val model = '''
comp r : resource(10);
comp c : sv(
	A
synchronize:
	A -> consume r(10); 
)
		'''.parse;
		model.assertError(GhostPackage.Literals.RES_CONSTR,
			GhostValidator.RESACTION_WRONGRES);
	}
	
	@Test
	def void testResInstVal1() {
		val model = '''
comp r : resource(10,20
synchronize:
	require(x) -> x < 10; 
)
		'''.parse;
		model.assertError(GhostPackage.Literals.RES_SIMPLE_INST_VAL,
			GhostValidator.RESACTION_WRONGRES);
	}
	
	@Test
	def void testResInstVal2() {
		val model = '''
comp r : resource(10
synchronize:
	produce(x) -> x < 10; 
)
		'''.parse;
		model.assertError(GhostPackage.Literals.RES_SIMPLE_INST_VAL,
			GhostValidator.RESACTION_WRONGRES);
	}
	
	@Test
	def void testResInstVal3() {
		val model = '''
comp r : resource(10
synchronize:
	consume(x) -> x < 10; 
)
		'''.parse;
		model.assertError(GhostPackage.Literals.RES_SIMPLE_INST_VAL,
			GhostValidator.RESACTION_WRONGRES);
	}
	
	//Synchronizations tests
	@Test
	def void testResActionInNonRes() {
		val model = '''
type t = sv(
	A;
synchronize:
	require (x) -> A;
)
		'''.parse;
		model.assertError(GhostPackage.Literals.RES_SIMPLE_INST_VAL, GhostValidator.RESACTION_NONRES);
	}
	
	@Test
	def void testSynchArgsMatch1() {
		val model = '''
type t = int [0,100];
comp c : sv(
	A(t x1, t x2), B
synchronize:
	A -> B
)
		'''.parse;
		model.assertNoErrors;
	}
	
	@Test
	def void testSynchArgsMatch2() {
		val model = '''
type t = int [0,100];
comp c : sv(
	A(t x1, t x2), B
synchronize:
	A(y) -> B
)
		'''.parse;
		model.assertNoErrors;
	}
	
	@Test
	def void testSynchArgsMatch3() {
		val model = '''
type t = int [0,100];
comp c : sv(
	A(t x1, t x2), B
synchronize:
	A(y1, y2) -> B
)
		'''.parse;
		model.assertNoErrors;
	}
	
	@Test
	def void testSynchArgsMatch4() {
		val model = '''
type t = int [0,100];
comp c : sv(
	A(t x1, t x2), B
synchronize:
	A(_, y2) -> B
)
		'''.parse;
		model.assertNoErrors;
	}

	@Test
	def void testSynchArgsMatch5() {
		val model = '''
type t = int [0,100];
comp c : sv(
	A(t x1, t x2), B
synchronize:
	A(y1, _) -> B
)
		'''.parse;
		model.assertNoErrors;
	}
	
	@Test
	def void testSynchArgsMatch6() {
		val model = '''
type t = int [0,100];
comp c : sv(
	A(t x1, t x2), B
synchronize:
	A(y1, y2, y3) -> B
)
		'''.parse;
		model.assertError(GhostPackage.Literals.SIMPLE_INST_VAL, GhostValidator.SYNCH_INVALID_PARNUM);
	}	

	@Test
	def void testSynchArgsMatch7() {
		val model = '''
type t = int [0,100];
comp c : sv(
	A(t x1, t x2), B
synchronize:
	A(y1, y2, _) -> B
)
		'''.parse;
		model.assertError(GhostPackage.Literals.SIMPLE_INST_VAL, GhostValidator.SYNCH_INVALID_PARNUM);
	}
	
	
	//Inheritance tests
	@Test
	def void testInheritance1() {
		val model = '''
type t = int [0,100];
type ct = sv (
	A(t x1, t x2)
);
comp c : ct(
	A(t y1, t y2)
)
		'''.parse;
		model.assertNoErrors;
	}
	
	@Test
	def void testInheritance2() {
		val model = '''
type t = int [0,100];
type ct = sv (
	A(t x1, t x2)
);
type ct2 = sv ct(
	A(t y1, t y2)
)
		'''.parse;
		model.assertNoErrors;
	}
	
	@Test
	def void testInheritance3() {
		val model = '''
type t = int [0,100];
type t2 = int [0,50];
type ct = sv (
	A(t x1, t x2)
);
comp c : ct(
	A(t2 y1, t2 y2)
)
		'''.parse;
		model.assertError(GhostPackage.Literals.VALUE_DECL, GhostValidator.INHERITANCE_INCOMPATIBLE_PARAMS);
	}
	
	@Test
	def void testInheritance4() {
		val model = '''
type t = int [0,100];
type t2 = int [0,50];
type ct = sv (
	A(t x1, t x2)
);
type ct2 = sv ct(
	A(t2 y1, t2 y2)
)
		'''.parse;
		model.assertError(GhostPackage.Literals.VALUE_DECL, GhostValidator.INHERITANCE_INCOMPATIBLE_PARAMS);
	}
	
	@Test
	def void testInheritance5() {
		val model = '''
type t = int [0,100];
type ct = sv (
	A(t x1, t x2)
);
comp c : ct(
	A(t x1)
)
		'''.parse;
		model.assertError(GhostPackage.Literals.VALUE_DECL, GhostValidator.INHERITANCE_INCOMPATIBLE_PARAMS);
	}
	
	@Test
	def void testInheritance6() {
		val model = '''
type t = int [0,100];
type ct = sv (
	A(t x1, t x2)
);
type ct2 = sv ct(
	A(t x1)
)
		'''.parse;
		model.assertError(GhostPackage.Literals.VALUE_DECL, GhostValidator.INHERITANCE_INCOMPATIBLE_PARAMS);
	}
	
	@Test
	def void testConsRenewInheritance1() {
		val model = '''
type r1 = resource (_,_);
type r2 = resource r1(_);
		'''.parse;
		model.assertWarning(GhostPackage.Literals.RESOURCE_DECL,GhostValidator.RENEWABLE_CONSUMABLE_MIX
		);
	}
	
	@Test
	def void testConsRenewInheritance2() {
		val model = '''
type r1 = resource (_);
type r2 = resource r1(_,_);
		'''.parse;
		model.assertWarning(GhostPackage.Literals.RESOURCE_DECL,GhostValidator.RENEWABLE_CONSUMABLE_MIX
		);
	}
	
	@Test
	def void testConsRenewInheritance3() {
		val model = '''
type r1 = resource (_,_);
comp r2 : r1(10);
		'''.parse;
		model.assertWarning(GhostPackage.Literals.COMP_DECL,GhostValidator.RENEWABLE_CONSUMABLE_MIX
		);
	}
	
	@Test
	def void testConsRenewInheritance4() {
		val model = '''
type r1 = resource (_);
comp r2 : r1(10,20);
		'''.parse;
		model.assertWarning(GhostPackage.Literals.COMP_DECL,GhostValidator.RENEWABLE_CONSUMABLE_MIX
		);
	}
	
	@Test
	def void testWrongInheritedKwd1() {
		val model = '''
type t = int [0,100];
type ct = sv (
	A(t x1, t x2) -> inherited
);
		'''.parse;
		model.assertError(GhostPackage.Literals.TRANS_CONSTR_BODY, GhostValidator.INHERITED_KWD_NO_ANCESTOR);
	}
	
	@Test
	def void testWrongInheritedKwd2() {
		val model = '''
type t = int [0,100];
comp c : sv (
	A(t x1, t x2) -> inherited
);
		'''.parse;
		model.assertError(GhostPackage.Literals.TRANS_CONSTR_BODY, GhostValidator.INHERITED_KWD_NO_ANCESTOR);
	}
	
	@Test
	def void testWrongInheritedKwd3() {
		val model = '''
type t = int [0,100];
type ct = sv (
	A(t x1, t x2)
synchronize:
	A -> inherited
);
		'''.parse;
		model.assertError(GhostPackage.Literals.SYNC_BODY, GhostValidator.INHERITED_KWD_NO_ANCESTOR);
	}
	
	@Test
	def void testWrongInheritedKwd4() {
		val model = '''
type t = int [0,100];
comp c : sv (
	A(t x1, t x2)
synchronize:
	A -> inherited
);
		'''.parse;
		model.assertError(GhostPackage.Literals.SYNC_BODY, GhostValidator.INHERITED_KWD_NO_ANCESTOR);
	}
	
	@Test
	def void testWrongInheritedKwd5() {
		val model = '''
type t = int [0,100];
type ct = resource (
synchronize:
	require(x) -> inherited
);
		'''.parse;
		model.assertError(GhostPackage.Literals.SYNC_BODY, GhostValidator.INHERITED_KWD_NO_ANCESTOR);
	}
	
	@Test
	def void testWrongInheritedKwd6() {
		val model = '''
comp c : resource (10
synchronize:
	require(x) -> inherited
);
		'''.parse;
		model.assertError(GhostPackage.Literals.SYNC_BODY, GhostValidator.INHERITED_KWD_NO_ANCESTOR);
	}
	
	@Test
	def void testInheritedKwdOk1() {
		val model = '''
type t = int [0,100];
type ct = sv (
	A(t x1, t x2)
);
type ct2 = sv ct(
	A(t y1, t y2) -> inherited
)
		'''.parse;
		model.assertNoErrors;
	}
	
	@Test
	def void testInheritedKwdOk2() {
		val model = '''
type t = int [0,100];
type ct = sv (
	A(t x1, t x2)
synchronize:
	A(x) -> x < 10
);
type ct2 = sv ct(
synchronize:
	A -> inherited
)
		'''.parse;
		model.assertNoErrors;
	}
	
	@Test
	def void testInheritedKwdOk3() {
		val model = '''
type r = resource (10
synchronize:
	require(x) -> x < 10
);
type r2 = resource r(10
synchronize:
	require(x) -> inherited
);
		'''.parse;
		model.assertNoErrors;
	}
	
	@Test
	def void testInheritedMultiBranch() {
		val model = '''
type t1 = sv(
	A
synchronize:
	A -> 1 < 0 or 7 > 5
);
type t2 = sv t1(
synchronize:
	A -> inherited
);
		'''.parse;
		model.assertError(GhostPackage.Literals.SYNC_BODY, GhostValidator.INHERITANCE_MULTIBRANCH);
	}

	//Recursive local variable definition	
	@Test
	def void testRecLocVarDef1() {
		val model = '''
comp c : sv (
	A -> var x = x;
);
		'''.parse;
		model.assertError(GhostPackage.Literals.LOC_VAR_DECL, GhostValidator.RECURSIVE_VARDECL);
	}
	
	@Test
	def void testRecLocVarDef2() {
		val model = '''
comp c : sv (
	A -> var x = (52 + 11)*x;
);
		'''.parse;
		model.assertError(GhostPackage.Literals.EXPRESSION, GhostValidator.RECURSIVE_VARDECL);
	}
	
	@Test
	def void testBindList1() {
		val model = '''
type t1 = sv;

type T = sv(
variable:
	A : t1, B : t1;
);
comp c1 : t1;
comp c2 : t1;
comp c3 : T[A = c1, B = c2];
		'''.parse;
		model.assertNoErrors();
	}
	
	@Test
	def void testBindList2() {
		val model = '''
type t1 = sv;

type T = sv(
variable:
	A : t1, B : t1;
);
comp c1 : t1;
comp c2 : t1;
comp c3 : T[c1, c2];
		'''.parse;
		model.assertNoErrors();
	}
	
	@Test
	def void testBindList3() {
		val model = '''
type t1 = sv;

type T = sv(
variable:
	A : t1, B : t1;
);
comp c1 : t1;
comp c2 : t1;
comp c3 : T[B = c1, c2];
		'''.parse;
		model.assertError(GhostPackage.Literals.BIND_LIST, GhostValidator.BINDLIST_MULTIPLEVAR);
	}
	
	@Test
	def void testBindList4() {
		val model = '''
type t1 = sv;

type T = sv(
variable:
	A : t1, B : t1;
);
comp c1 : t1;
comp c2 : t1;
comp c3 : T[A = c1, A = c2];
		'''.parse;
		model.assertError(GhostPackage.Literals.BIND_LIST, GhostValidator.BINDLIST_MULTIPLEVAR);
	}
	
	@Test
	def void testBindListUnbound1() {
		val model = '''
type t1 = sv;

type T = sv(
variable:
	A : t1, B : t1;
);
comp c1 : t1;
comp c2 : t1;
comp c3 : T[c1];
		'''.parse;
		model.assertError(GhostPackage.Literals.BIND_LIST, GhostValidator.BINDLIST_SOME_UNBOUND);
	}
	
	@Test
	def void testBindListTooMuch1() {
		val model = '''
type t1 = sv;

type T = sv(
variable:
	A : t1;
);
comp c1 : t1;
comp c2 : t1;
comp c3 : T[c1,c2];
		'''.parse;
		model.assertError(GhostPackage.Literals.BIND_LIST, GhostValidator.BINDLIST_TOO_LARGE);
	}
	
	@Test
	def void testBindListTooMuch2() {
		val model = '''
type T = sv;
comp c1 : T;
comp c2 : T;
comp c3 : T[c1,c2];
		'''.parse;
		model.assertError(GhostPackage.Literals.BIND_LIST, GhostValidator.BINDLIST_TOO_LARGE);
	}
	
	@Test
	def void testBindListTooMuch3() {
		val model = '''
comp c1 : sv;
comp c2 : sv[c1];
		'''.parse;
		model.assertError(GhostPackage.Literals.BIND_LIST, GhostValidator.BINDLIST_TOO_LARGE);
	}

	@Test
	def void testBindListInherited1() {
		val model = '''
type t1 = sv;

type S = sv(
variable:
	A : t1;
);
type T = sv S(
variable:
	B : t1;
);
comp c1 : t1;
comp c2 : t1;
comp c3 : T[A = c1, B = c2];
		'''.parse;
		model.assertNoErrors();
	}
	
	@Test
	def void testBindListInherited2() {
		val model = '''
type t1 = sv;

type S = sv(
variable:
	A : t1;
);
type T = sv S(
variable:
	B : t1;
);
comp c1 : t1;
comp c2 : t1;
comp c3 : T[c1, c2];
		'''.parse;
		model.assertNoErrors();
	}
	
	@Test
	def void testBindListInherited3() {
		val model = '''
type t1 = sv;

type S = sv(
variable:
	A : t1;
);
type T = sv S(
variable:
	A : t1, B : t1;
);
comp c1 : t1;
comp c2 : t1;
comp c3 : T[A = c1, B = c2];
		'''.parse;
		model.assertNoErrors();
	}
	
	
}
