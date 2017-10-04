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
	def void testQualifInstValErr1() {
		val model = '''
type t = int [0,100];
comp c : sv(
	A(t x);
synchronize:
	A(x) -> c.x 
)
		'''.parse;
		model.assertError(GhostPackage.Literals.QUALIF_INST_VAL, GhostValidator.QUALIFINSTVAL_INCOMPATIBLE_COMP);
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
	
}
