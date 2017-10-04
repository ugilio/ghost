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

import static org.junit.Assert.*
import static org.hamcrest.CoreMatchers.*
import org.eclipse.xtext.EcoreUtil2
import it.cnr.istc.ghost.ghost.QualifInstVal
import it.cnr.istc.ghost.ghost.NamedPar
import it.cnr.istc.ghost.ghost.FormalPar
import it.cnr.istc.ghost.ghost.LocVarDecl
import it.cnr.istc.ghost.ghost.ValueDecl
import it.cnr.istc.ghost.ghost.Synchronization
import it.cnr.istc.ghost.ghost.CompDecl
import it.cnr.istc.ghost.ghost.ObjVarDecl
import it.cnr.istc.ghost.ghost.SvDecl
import it.cnr.istc.ghost.ghost.SimpleInstVal
import it.cnr.istc.ghost.ghost.BindList

@RunWith(XtextRunner)
@InjectWith(GhostInjectorProvider)
class GhostCrossRefTest{

	@Inject
	ParseHelper<Ghost> parseHelper
	
	@Test
	def void testNamedParRef() {
		val result = parseHelper.parse('''
type ANumType = int [0,100];

comp ASVWithAnonymousType : sv(
	A(ANumType x) -> B;
	B
synchronize:
	A(x) -> x < 10;
);		''')
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		val sync = EcoreUtil2.eAllOfType(result,Synchronization).head;
		val value = EcoreUtil2.eAllOfType(sync,QualifInstVal).head?.value;
		assertNotNull(value);
		assertThat(value.eIsProxy,is(false));
		val par = EcoreUtil2.eAllOfType(result,NamedPar).head;
		assertThat(par.name,is(equalTo("x")));
		assertThat(value,is(par));
	}
	
	@Test
	def void testResourceNamedParRef() {
		val result = parseHelper.parse('''
comp AResWithAnonymousType : resource(10
synchronize:
	require(x) -> x < 10;
);		''')
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		val sync = EcoreUtil2.eAllOfType(result,Synchronization).head;
		val value = EcoreUtil2.eAllOfType(sync,QualifInstVal).head?.value;
		assertNotNull(value);
		assertThat(value.eIsProxy,is(false));
		val par = EcoreUtil2.eAllOfType(result,NamedPar).head;
		assertThat(par.name,is(equalTo("x")));
		assertThat(value,is(par));
	}
	
	@Test
	def void testFormalParRef() {
		val result = parseHelper.parse('''
type ANumType = int [0,100];

comp ASVWithAnonymousType : sv(
	A(ANumType x) -> (B, x < 10);
	B
);		''')
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		val value = EcoreUtil2.eAllOfType(result,QualifInstVal).get(1).value;
		assertNotNull(value);
		assertThat(value.eIsProxy,is(false));
		val par = EcoreUtil2.eAllOfType(result,FormalPar).head;
		assertThat(par.name,is(equalTo("x")));
		assertThat(value,is(par));
	}
	
	@Test
	def void testLocVarRef() {
		val result = parseHelper.parse('''
type ANumType = int [0,100];

comp ASVWithAnonymousType : sv(
	A(ANumType x) -> B;
	B
synchronize:
	A(x) -> (var y = x + 1; y < 10;)
);		''')
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		val sync = EcoreUtil2.eAllOfType(result,Synchronization).head;
		val value = EcoreUtil2.eAllOfType(sync,QualifInstVal).get(1).value;
		assertNotNull(value);
		assertThat(value.eIsProxy,is(false));
		val par = EcoreUtil2.eAllOfType(result,LocVarDecl).head;
		assertThat(par.name,is(equalTo("y")));
		assertThat(value,is(par));
	}
	
	@Test
	def void testValueRef1() {
		val result = parseHelper.parse('''
type ANumType = int [0,100];

comp ASVWithAnonymousType : sv(
	A(ANumType x) -> B;
	B
synchronize:
	A(x) -> B
);		''')
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		val sync = EcoreUtil2.eAllOfType(result,Synchronization).head;
		val value = EcoreUtil2.eAllOfType(sync,QualifInstVal).head?.value;
		assertNotNull(value);
		assertThat(value.eIsProxy,is(false));
		val par = EcoreUtil2.eAllOfType(result,ValueDecl).get(1);
		assertThat(par.name,is(equalTo("B")));
		assertThat(value,is(par));
	}
	
	@Test
	def void testCompValueRef2a() {
		val result = parseHelper.parse('''
type ANumType = int [0,100];

comp ASVWithAnonymousType : sv(
	A(ANumType x) -> B;
	B
synchronize:
	A(x) -> ASVWithAnonymousType.B
);		''')
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		val sync = EcoreUtil2.eAllOfType(result,Synchronization).head;
		val comp = EcoreUtil2.eAllOfType(sync,QualifInstVal).head?.comp;
		assertNotNull(comp);
		assertThat(comp.eIsProxy,is(false));
		val comp2 = EcoreUtil2.eAllOfType(result,CompDecl).head;
		assertThat(comp,is(comp2));
	}
	
	@Test
	def void testCompValueRef2b() {
		val result = parseHelper.parse('''
type ANumType = int [0,100];

comp ASVWithAnonymousType : sv(
	A(ANumType x) -> B;
	B
synchronize:
	A(x) -> ASVWithAnonymousType.B
);		''')
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		val sync = EcoreUtil2.eAllOfType(result,Synchronization).head;
		val value = EcoreUtil2.eAllOfType(sync,QualifInstVal).head?.value;
		assertNotNull(value);
		assertThat(value.eIsProxy,is(false));
		val par = EcoreUtil2.eAllOfType(result,ValueDecl).get(1);
		assertThat(par.name,is(equalTo("B")));
		assertThat(value,is(par));
	}			

	@Test
	def void testCompValueRef3a() {
		val result = parseHelper.parse('''
type ANumType = int [0,100];

type ASVType = sv(
	A(ANumType x) -> B;
	B
synchronize:
	A(x) -> other.B;
variable:
	other : ASVType;
);		''')
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		val sync = EcoreUtil2.eAllOfType(result,Synchronization).head;
		val comp = EcoreUtil2.eAllOfType(sync,QualifInstVal).head?.comp;
		assertNotNull(comp);
		assertThat(comp.eIsProxy,is(false));
		val comp2 = EcoreUtil2.eAllOfType(result,ObjVarDecl).head;
		assertThat(comp,is(comp2));
	}
	
	@Test
	def void testCompValueRef3b() {
		val result = parseHelper.parse('''
type ANumType = int [0,100];

type ASVType = sv(
	A(ANumType x) -> B;
	B
synchronize:
	A(x) -> other.B;
variable:
	other : ASVType;
);		''')
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		val sync = EcoreUtil2.eAllOfType(result,Synchronization).head;
		val value = EcoreUtil2.eAllOfType(sync,QualifInstVal).head?.value;
		assertNotNull(value);
		assertThat(value.eIsProxy,is(false));
		val par = EcoreUtil2.eAllOfType(result,ValueDecl).get(1);
		assertThat(par.name,is(equalTo("B")));
		assertThat(value,is(par));
	}		

	@Test	
	def void testSyncInheritance() {
		val result = parseHelper.parse('''
type t = int [0,100];
type ct = sv (
	A(t x1, t x2)
synchronize:
	A(x) -> x < 10
);
type ct2 = sv ct(
synchronize:
	A(x) -> x < 10
)
		''');
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		val sv2 = EcoreUtil2.eAllOfType(result,SvDecl).get(1);
		val value = EcoreUtil2.eAllOfType(sv2,SimpleInstVal).head?.value;
		assertNotNull(value);
		assertThat(value.eIsProxy,is(false));
		val sv1 = EcoreUtil2.eAllOfType(result,SvDecl).head;
		val orig = EcoreUtil2.eAllOfType(sv1,ValueDecl).head;
		assertThat(orig.name,is(equalTo("A")));
		assertThat(value,is(orig));
	}
	
	@Test	
	def void testBindListNameRef() {
		val result = parseHelper.parse('''
type t = sv(A
variable:
	avar : t;
);
comp c : t[avar=c];
		''');
		assertNotNull(result);
		EcoreUtil2.resolveAll(result);
		val bl = EcoreUtil2.eAllOfType(result,BindList)?.head;
		assertNotNull(bl?.varNames);
		val ref = bl.varNames.get(0);
		assertNotNull(ref);
		assertThat(ref.eIsProxy,is(false));
		val sv = EcoreUtil2.eAllOfType(result,SvDecl).head;
		val orig = EcoreUtil2.eAllOfType(sv,ObjVarDecl).head;
		assertThat(orig.name,is(equalTo("avar")));
		assertThat(ref,is(orig));
	}
}
