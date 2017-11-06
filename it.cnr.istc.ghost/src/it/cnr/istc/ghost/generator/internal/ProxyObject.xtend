package it.cnr.istc.ghost.generator.internal

import org.eclipse.emf.ecore.EObject
import it.cnr.istc.timeline.lang.Interval
import it.cnr.istc.ghost.ghost.Externality
import it.cnr.istc.timeline.lang.Controllability
import it.cnr.istc.timeline.lang.TemporalOperator

class ProxyObject {
	protected Register register;
	
	new(Register register) {
		this.register = register;
	}
	
	protected def getProxy(Object real) {
		return register?.getProxy(real);
	}
	
	protected def replaceProxy(Object real, Object proxy) {
		register?.replaceProxy(real,proxy);
	} 
	
	protected def TemporalOperator getTemporalOperator(String name) {
		return register?.getTemporalOperator(name);
	}	
	
	protected def Interval getDefaultInterval(EObject obj) {
		return register?.getDefaultInterval(obj);
	}
	
	protected def Externality getDefaultExternality(EObject obj) {
		return register?.getDefaultExternality(obj);
	}	
	
	protected def Controllability getDefaultControllability(EObject obj) {
		return register?.getDefaultControllability(obj);
	}
}