/*
 * generated by Xtext 2.12.0
 */
package it.cnr.istc.ghost.tests

import it.cnr.istc.ghost.preprocessor.UnitProvider.ResourceSpecificProvider
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

import static org.hamcrest.CoreMatchers.*
import static org.junit.Assert.*
import it.cnr.istc.ghost.preprocessor.UnitProvider.UnitProviderException
import org.junit.Before
import com.google.inject.Inject

@RunWith(XtextRunner)
@InjectWith(GhostInjectorProvider)
class GhostUnitProviderTest{

	@Inject
	ResourceSpecificProvider p;

	@Before
	def void setUp() {
		//p = new ResourceSpecificProvider();
	}

	@Test
	def void testValueOnly() {
		val value = p.getValue("1");
		assertThat(value,is(1L));
	}
	
	@Test
	def void testMs1() {
		val value = p.getValue("1 ms");
		assertThat(value,is(1L));
	}
	
	@Test
	def void testMs2() {
		val value = p.getValue("2 ms");
		assertThat(value,is(2L));
	}
	
	@Test
	def void testSec1() {
		val value = p.getValue("2 sec");
		assertThat(value,is(2000L));
	}
	
	@Test
	def void testS1() {
		val value = p.getValue("2 s");
		assertThat(value,is(2000L));
	}
	
	@Test
	def void testAllDefaultDefinitions() {
		assertThat(p.getValue("1 ms"),is(1L));
		assertThat(p.getValue("1 sec"), is(1000L));
		assertThat(p.getValue("1 min"), is(60000L));
		assertThat(p.getValue("1 hrs"), is(3600L*1000L));
		assertThat(p.getValue("1 days"), is(24L*3600L*1000L));

		assertThat(p.getValue("1 s"), is(1000L));
		assertThat(p.getValue("1 m"), is(60000L));
		assertThat(p.getValue("1 h"), is(3600L*1000L));
		assertThat(p.getValue("1 hours"), is(3600L*1000L));
		assertThat(p.getValue("1 d"), is(24L*3600L*1000L));
	}
	
	@Test
	def void testNegative() {
		val value = p.getValue("- 2 s");
		assertThat(value,is(-2000L));
	}
	
	@Test
	def void testAdd() {
		p.addUnit("a","10",1);
		val value = p.getValue("2 a",2);
		assertThat(value,is(20L));
	}
	
	@Test
	def void testAddBefore() {
		p.addUnit("a","10",10);
		p.addUnit("a","2",2);
		assertThat(p.getValue("1 a",3), is(2L));
		assertThat(p.getValue("1 a",11), is(10L));
	}
	
	@Test
	def void testReplace() {
		p.addUnit("a","10",10);
		p.addUnit("a","2",10);
		assertThat(p.getValue("1 a",11), is(2L));
	}
	
	@Test(expected = UnitProviderException)
	def void testUselessAdd() {
		p.addUnit("a","10",1);
		p.getValue("2 a",0);
	}
	
	@Test
	def void testRedefine1() {
		p.addUnit("sec","1",1);
		val value = p.getValue("2 sec",2);
		assertThat(value,is(2L));
	}
	
	@Test
	def void testRedefine2() {
		p.addUnit("sec","1",1);
		val value = p.getValue("2 sec",2);
		assertThat(value,is(2L));
	}
	
	@Test
	def void testRedefine3() {
		p.addUnit("sec","1",1);
		val value = p.getValue("2 min",2);
		assertThat(value,is(120L));
	}
	
	@Test
	def void testRedefine4() {
		p.addUnit("sec","1",1);
		p.addUnit("sec","10",2);
		val value = p.getValue("2 sec",3);
		assertThat(value,is(20L));
	}
	
	@Test
	def void testRedefine5() {
		p.addUnit("sec","1",1);
		p.addUnit("sec","10",3);
		val value = p.getValue("2 sec",2);
		assertThat(value,is(2L));
	}

	@Test(expected = UnitProviderException)
	def void testUndefine() {
		p.addUnit("a","1",1);
		p.addUnit("a","",2);
		p.getValue("1 a",3);
	}

	@Test
	def void testUndefine2() {
		p.addUnit("a","1",1);
		p.addUnit("a","",3);
		val value = p.getValue("1 a",2);
		assertThat(value,is(1L));
	}

	@Test(expected = UnitProviderException)
	def void testRecursive1() {
		p.addUnit("ms","1 sec",1);
		p.getValue("1 sec",2);
	}
	
	@Test(expected = UnitProviderException)
	def void testRecursive2() {
		p.addUnit("sec","1 days",1);
		p.getValue("1 days",2);
	}
	
	@Test(expected = UnitProviderException)
	def void testInvalid1() {
		p.getValue("1ms");
	}
	
	@Test(expected = UnitProviderException)
	def void testInvalid2() {
		p.getValue("ms");
	}
	
	@Test(expected = UnitProviderException)
	def void testInvalid3() {
		p.getValue("12 undefined_unit");
	}
	
	@Test(expected = UnitProviderException)
	def void testNull() {
		p.getValue(null);
	}
	
	@Test(expected = UnitProviderException)
	def void testEmpty() {
		p.getValue("");
	}
	
	@Test(expected = UnitProviderException)
	def void testWrongOffset() {
		p.getValue("1 ms",-1);
	}

	@Test(expected = UnitProviderException)
	def void testAddEmptyUnit() {
		p.addUnit("","1");
	}
	
	@Test(expected = UnitProviderException)
	def void testAddNullUnit() {
		p.addUnit(null,"1");
	}
	
	@Test()
	def void testAddNullValue() {
		p.addUnit("a",null);
		//no exception raised
		assertTrue(true);
	}
	
	@Test()
	def void testAddEmptyValue() {
		p.addUnit("a","");
		//no exception raised
		assertTrue(true);
	}
	
	@Test(expected = UnitProviderException)
	def void testAddInvalidOffset() {
		p.addUnit("a","1",-1);
	}
	
}
