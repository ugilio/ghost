/*
 * generated by Xtext 2.12.0
 */
package it.cnr.istc.ghost.tests

import com.google.inject.Inject
import it.cnr.istc.ghost.ghost.CompResBody
import it.cnr.istc.ghost.ghost.CompSVBody
import it.cnr.istc.ghost.ghost.ConstLiteralUsage
import it.cnr.istc.ghost.ghost.Ghost
import it.cnr.istc.ghost.ghost.NamedCompDecl
import it.cnr.istc.ghost.ghost.Synchronization
import it.cnr.istc.ghost.ghost.ValueDecl
import it.cnr.istc.ghost.linking.GhostLinker
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.linking.impl.XtextLinkingDiagnostic
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.Test
import org.junit.runner.RunWith

import static org.hamcrest.Matchers.*
import static org.junit.Assert.*
import it.cnr.istc.ghost.ghost.QualifInstVal
import it.cnr.istc.ghost.ghost.IntDecl
import it.cnr.istc.ghost.ghost.ImportDecl
import it.cnr.istc.ghost.ghost.FormalPar

@RunWith(XtextRunner)
@InjectWith(GhostInjectorProvider)
class GhostLinkerTest{

	@Inject
	ParseHelper<Ghost> parseHelper
	
	private def void assertError(EObject obj, String code) {
		val err = obj?.eResource?.errors?.filter(XtextLinkingDiagnostic)?.filter(e|e.code==code).head;
		if (err !== null)
			return;
		val errStr = obj?.eResource?.errors?.join(",");
		assertTrue(String.format("Expected error of type '%s' but got '%s'",code,errStr),false);
	}
	
	private def Ghost multiparse(CharSequence ...sources) {
		var tmp = parseHelper.parse(sources.get(0));
		val rs = tmp.eResource.resourceSet;
		for (var i = 1; i < sources.size(); i++)
			tmp = parseHelper.parse(sources.get(i),rs);
		return tmp;
	}
	
	@Test
	def void testNamedCompDecl1() {
		val result = parseHelper.parse('''
type T = sv(A,B);
comp c : T(C);
		''');
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		assertThat(result.eResource.errors,is(equalTo(emptyList)));
		val comp = EcoreUtil2.eAllOfType(result,NamedCompDecl).head;
		assertThat(comp.body,is(instanceOf(CompSVBody)));
		val C = EcoreUtil2.eAllOfType(result,ValueDecl).filter[v|v.name=='C'].head;
		assertNotNull(C);
	}
	
	@Test
	def void testNamedCompDecl2() {
		val result = parseHelper.parse('''
type T = sv(A,B);
comp c : T(C,D);
		''');
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		assertThat(result.eResource.errors,is(equalTo(emptyList)));
		val comp = EcoreUtil2.eAllOfType(result,NamedCompDecl).head;
		assertThat(comp.body,is(instanceOf(CompSVBody)));
		val C = EcoreUtil2.eAllOfType(result,ValueDecl).filter[v|v.name=='C'].head;
		assertNotNull(C);
		assertThat(C.eIsProxy(),is(notNullValue));
		val D = EcoreUtil2.eAllOfType(result,ValueDecl).filter[v|v.name=='D'].head;
		assertNotNull(D);
		assertThat(D.eIsProxy(),is(notNullValue));
	}
	
	@Test
	def void testNamedCompDecl3() {
		val result = parseHelper.parse('''
type T = sv(A,B);
comp c : T(15+7-2);
		''');
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		//The validator will catch this error
		assertThat(result.eResource.errors,is(equalTo(emptyList)));
		val comp = EcoreUtil2.eAllOfType(result,NamedCompDecl).head;
		assertThat(comp.body,is(instanceOf(CompResBody)));
	}
	
	@Test
	def void testNamedCompDecl4() {
		val result = parseHelper.parse('''
type T = sv(A,B);
comp c : T(   contr   C);
		''');
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		assertThat(result.eResource.errors,is(equalTo(emptyList)));
		val C = EcoreUtil2.eAllOfType(result,ValueDecl).filter[v|v.name=='C'].head;
		assertNotNull(C);
		assertThat(C.eIsProxy(),is(notNullValue));
	}	
		
	@Test
	def void testNamedCompDecl5() {
		val result = parseHelper.parse('''
type T = sv(A,B);
comp c : T(   uncontr   C );
		''');
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		assertThat(result.eResource.errors,is(equalTo(emptyList)));
		val C = EcoreUtil2.eAllOfType(result,ValueDecl).filter[v|v.name=='C'].head;
		assertNotNull(C);
		assertThat(C.eIsProxy(),is(notNullValue));
	}	
		
	@Test
	def void testNamedCompDecl6() {
		val result = parseHelper.parse('''
type T = sv(A,B);
comp c : T(C,D,E);
		''');
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		assertThat(result.eResource.errors,is(equalTo(emptyList)));
		val comp = EcoreUtil2.eAllOfType(result,NamedCompDecl).head;
		assertThat(comp.body,is(instanceOf(CompSVBody)));
		val E = EcoreUtil2.eAllOfType(result,ValueDecl).filter[v|v.name=='E'].head;
		assertNotNull(E);
		assertThat(E.eIsProxy(),is(notNullValue));
	}	
		
	@Test
	def void testNamedCompDecl7() {
		val result = parseHelper.parse('''
type T = sv(A,B);
comp c : T(C
synchronize:
	C -> A
);
		''');
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		assertThat(result.eResource.errors,is(equalTo(emptyList)));
		val comp = EcoreUtil2.eAllOfType(result,NamedCompDecl).head;
		assertThat(comp.body,is(instanceOf(CompSVBody)));
		val sync = EcoreUtil2.eAllOfType(result,Synchronization).head;
		val qiv = EcoreUtil2.eAllOfType(sync,QualifInstVal).head;
		assertThat(qiv,is(notNullValue));
		val A = qiv.value;
		assertThat(A,is(notNullValue));
		assertThat(A.eIsProxy,is(false));
	}	
	
	@Test
	def void testNamedCompDecl8() {
		val result = parseHelper.parse('''
type t = sv(A,B
synchronize:
        A -> B
);
comp c : t(
synchronize:
        A -> inherited
)
		''');
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		assertThat(result.eResource.errors,is(equalTo(emptyList)));
		val comp = EcoreUtil2.eAllOfType(result,NamedCompDecl).head;
		assertThat(comp.body,is(instanceOf(CompSVBody)));
		val sync = EcoreUtil2.eAllOfType(result,Synchronization).head;
		assertThat(sync,is(notNullValue));
	}	
	
	@Test
	def void testNamedCompDeclRes1() {
		val result = parseHelper.parse('''
const C = 10;


type T = resource(10);
comp R : T(C);
		''');
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		assertThat(result.eResource.errors,is(equalTo(emptyList)));
		val comp = EcoreUtil2.eAllOfType(result,NamedCompDecl).head;
		assertThat(comp.body,is(instanceOf(CompResBody)));
		val C = EcoreUtil2.eAllOfType(result,ConstLiteralUsage).map[clu|clu.value].head;
		assertNotNull(C);
		assertThat(C.eIsProxy,is(false));
	}
	
	@Test
	def void testNamedCompDeclRes2() {
		val result = parseHelper.parse('''
const C = 10;
const D = 20;

type T = resource(_,_);
comp R : T(C,D);
		''');
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		assertThat(result.eResource.errors,is(equalTo(emptyList)));
		val comp = EcoreUtil2.eAllOfType(result,NamedCompDecl).head;
		assertThat(comp.body,is(instanceOf(CompResBody)));
		val C = EcoreUtil2.eAllOfType(result,ConstLiteralUsage).map[clu|clu.value].head;
		val D = EcoreUtil2.eAllOfType(result,ConstLiteralUsage).map[clu|clu.value].get(1);
		assertNotNull(C);
		assertThat(C.eIsProxy,is(false));
		assertNotNull(D);
		assertThat(D.eIsProxy,is(false));
	}
	
	@Test
	def void testNamedCompDeclRes3() {
		val result = parseHelper.parse('''
const C = 10;
type T = resource(_);
comp c : T(C
synchronize:
	require(x) -> x < 10
);
		''');
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		assertThat(result.eResource.errors,is(equalTo(emptyList)));
		val comp = EcoreUtil2.eAllOfType(result,NamedCompDecl).head;
		assertThat(comp.body,is(instanceOf(CompResBody)));
		val sync = EcoreUtil2.eAllOfType(result,Synchronization).head;
		assertThat(sync,is(notNullValue));
	}		
	
	@Test
	def void testNamedCompDeclRes4() {
		val result = parseHelper.parse('''
type T = resource(10);
comp c : T(
synchronize:
	require(x) -> x < 10
);
		''');
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		assertThat(result.eResource.errors,is(equalTo(emptyList)));
		val comp = EcoreUtil2.eAllOfType(result,NamedCompDecl).head;
		assertThat(comp.body,is(instanceOf(CompResBody)));
		val sync = EcoreUtil2.eAllOfType(result,Synchronization).head;
		assertThat(sync,is(notNullValue));
	}		
	
	@Test
	def void testNamedCompDeclResErr1() {
		val result = parseHelper.parse('''
type T = resource(10);
comp R : T(C);
		''');
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		val comp = EcoreUtil2.eAllOfType(result,NamedCompDecl).head;
		assertThat(comp.body,is(instanceOf(CompResBody)));
		val C = EcoreUtil2.eAllOfType(result,ConstLiteralUsage).map[clu|clu.value].head;
		assertNotNull(C);
		assertThat(C.eIsProxy,is(true));
	}
	
	@Test
	def void testNamedCompDeclResErr2() {
		val result = parseHelper.parse('''
type T = resource(_,_);
comp R : T(C,D,E);
		''');
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		val comp = EcoreUtil2.eAllOfType(result,NamedCompDecl).head;
		assertThat(comp.body,is(instanceOf(CompResBody)));
		result.assertError(GhostLinker.RES_TOO_MANY_ARGS);
	}
	
	@Test
	def void testNamedCompDeclResErr3() {
		val result = parseHelper.parse('''
const C = 10;
type T = resource(_);
comp R : T(contr C);
		''');
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		//The validator will catch this error
		assertThat(result.eResource.errors,is(equalTo(emptyList)));
		val comp = EcoreUtil2.eAllOfType(result,NamedCompDecl).head;
		assertThat(comp.body,is(instanceOf(CompSVBody)));
	}
	
	@Test
	def void testNamedCompDeclResRegular1() {
		val result = parseHelper.parse('''
type T = resource(_);
comp R : T(12+7);
		''');
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		assertThat(result.eResource.errors,is(equalTo(emptyList)));
		val comp = EcoreUtil2.eAllOfType(result,NamedCompDecl).head;
		assertThat(comp.body,is(instanceOf(CompResBody)));
	}
	
	@Test
	def void testTypeShadowing1() {
		val result = multiparse(
'''
domain d1;

type I = int [10, 20];
		''',
'''
import d1;

type I = int [20, 40];
comp C : sv(A(I));
		''');
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		assertThat(result.eResource.errors,is(equalTo(emptyList)));
		val d1 = EcoreUtil2.eAllOfType(result,ImportDecl).head.importedNamespace;
		val g1 = EcoreUtil2.getContainerOfType(d1,Ghost);
		val i1 = EcoreUtil2.eAllOfType(g1,IntDecl).head;
		val i2 = EcoreUtil2.eAllOfType(result,IntDecl).head;
		val p1 = EcoreUtil2.eAllOfType(result,FormalPar).head;
		assertThat(i1,is(not(sameInstance(p1.type))));
		assertThat(p1.type,is(i2));
	}	
}
