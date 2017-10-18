/*
 * generated by Xtext 2.12.0
 */
package it.cnr.istc.ghost.tests

import com.google.inject.Inject
import it.cnr.istc.ghost.conversion.IntervalHelper
import it.cnr.istc.ghost.conversion.NumAndUnitValueConverter
import it.cnr.istc.ghost.ghost.Controllability
import it.cnr.istc.ghost.ghost.Ghost
import it.cnr.istc.ghost.preprocessor.DefaultsProvider.DefaultsProviderException
import it.cnr.istc.ghost.preprocessor.DefaultsProvider.ResourceSpecificProvider
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

import static it.cnr.istc.ghost.tests.utils.IntervalMatcher.*
import static org.hamcrest.CoreMatchers.*
import static org.junit.Assert.*

@RunWith(XtextRunner)
@InjectWith(GhostInjectorProvider)
class GhostDefaultsProviderTest{
	
	@Inject extension ParseHelper<Ghost> parseHelper;

	ResourceSpecificProvider p;
	
	Resource r;
	
	@Inject
	NumAndUnitValueConverter conv;
	
	@Inject
	IntervalHelper intvHelper;

	@Before
	def void setUp() {
		val model = "$set some dummy value".parse;
		r = model.eResource;
		p = new ResourceSpecificProvider(r,conv);
	}
	
	private def intv(long l, long r) {
		return intvHelper.create(l,r);
	}

	private def intv(long v) {
		return intvHelper.create(v);
	}

	@Test
	def void testAllDefaultDefinitions() {
		assertThat(p.getDuration(0),is(equalTo(intv(0,Long.MAX_VALUE))));
		assertThat(p.isExternal(0),is(false));
		assertThat(p.getControllability(0),is(equalTo(Controllability.UNKNOWN)));
		assertThat(p.getStart(0),is(0L));
		assertThat(p.getHorizon(0),is(1000L));
	}
	
	@Test
	def void testDuration1() {
		p.addDefinition("duration","[10,20]",1);
		assertThat(p.getDuration(2),is(equalTo(intv(10,20))));
	}
	
	@Test
	def void testDuration2() {
		p.addDefinition("duration","[   10  ,   20  ]",1);
		assertThat(p.getDuration(2),is(equalTo(intv(10,20))));
	}
	
	@Test
	def void testDuration3() {
		p.addDefinition("duration","10",1);
		assertThat(p.getDuration(2),is(equalTo(intv(10))));
	}
	
	@Test
	def void testDuration4() {
		p.addDefinition("duration","10 s",1);
		assertThat(p.getDuration(2),is(equalTo(intv(10000))));
	}
	
	@Test
	def void testDuration5() {
		p.addDefinition("duration","[ 10 s, 20 s]",1);
		assertThat(p.getDuration(2),is(equalTo(intv(10000,20000))));
	}
	
	@Test(expected=DefaultsProviderException)
	def void testInvalidDuration1() {
		p.addDefinition("duration","10a",1);
	}
	
	@Test(expected=DefaultsProviderException)
	def void testInvalidDuration2() {
		p.addDefinition("duration","10,20",1);
	}
	
	@Test(expected=DefaultsProviderException)
	def void testInvalidDuration3() {
		p.addDefinition("duration","[10,20",1);
	}
	
	@Test(expected=DefaultsProviderException)
	def void testInvalidDuration4() {
		p.addDefinition("duration","[10 20]",1);
	}
	
	@Test(expected=DefaultsProviderException)
	def void testInvalidDuration5() {
		p.addDefinition("duration","[10]",1);
	}
	
	@Test(expected=DefaultsProviderException)
	def void testInvalidDuration6() {
		p.addDefinition("duration","",1);
	}
	
	@Test(expected=DefaultsProviderException)
	def void testInvalidDuration7() {
		p.addDefinition("duration","[10,20] and some extraneous input",1);
	}
	
	@Test
	def void testPlanned() {
		p.addDefinition("planned","",1);
		assertThat(p.isExternal(2),is(false));
	}
	
	@Test
	def void testExternal() {
		p.addDefinition("external","",1);
		assertThat(p.isExternal(2),is(true));
	}
	
	@Test(expected=DefaultsProviderException)
	def void testInvalidPlanned() {
		p.addDefinition("planned","extraneous input",1);
	}
	
	@Test(expected=DefaultsProviderException)
	def void testInvalidExternal() {
		p.addDefinition("external","extraneous input",1);
	}
	
	@Test()
	def void testContr1() {
		p.addDefinition("contr","contr",1);
		assertThat(p.getControllability(2),is(equalTo(Controllability.CONTROLLABLE)));
	}
	
	@Test()
	def void testContr2() {
		p.addDefinition("contr","uncontr",1);
		assertThat(p.getControllability(2),is(equalTo(Controllability.UNCONTROLLABLE)));
	}
	
	@Test()
	def void testContr3() {
		p.addDefinition("contr","unknown",1);
		assertThat(p.getControllability(2),is(equalTo(Controllability.UNKNOWN)));
	}
	
	@Test(expected=DefaultsProviderException)
	def void testInvalidContr1() {
		p.addDefinition("contr","wrong",1);
	}
	
	@Test(expected=DefaultsProviderException)
	def void testInvalidContr2() {
		p.addDefinition("contr","",1);
	}
	
	@Test(expected=DefaultsProviderException)
	def void testInvalidContr3() {
		p.addDefinition("contr","contr with other extraneous input",1);
	}
	
	@Test()
	def void testStart1() {
		p.addDefinition("start","12",1);
		assertThat(p.getStart(2),is(12l));
	}
	
	@Test()
	def void testStart2() {
		p.addDefinition("start","12 s",1);
		assertThat(p.getStart(2),is(12000l));
	}
	
	@Test(expected=DefaultsProviderException)
	def void testInvalidStart1() {
		p.addDefinition("start","wrong",1);
	}
	
	@Test(expected=DefaultsProviderException)
	def void testInvalidStart2() {
		p.addDefinition("start","",1);
	}
	
	@Test(expected=DefaultsProviderException)
	def void testInvalidStart3() {
		p.addDefinition("start","_",1);
	}
	
	@Test(expected=DefaultsProviderException)
	def void testInvalidStart4() {
		p.addDefinition("start","12 extraneous input",1);
	}
	
	@Test()
	def void testHorizon1() {
		p.addDefinition("horizon","12",1);
		assertThat(p.getHorizon(2),is(12l));
	}
	
	@Test()
	def void testRedef1() {
		p.addDefinition("start","12",1);
		p.addDefinition("start","24",5);
		assertThat(p.getStart(2),is(12l));
	}
	
	@Test()
	def void testRedef2() {
		p.addDefinition("start","12",1);
		p.addDefinition("start","24",5);
		assertThat(p.getStart(6),is(24l));
	}
	
	@Test(expected=DefaultsProviderException)
	def void testInvalidKey() {
		p.addDefinition("something","wrong",1);
	}
	
}
