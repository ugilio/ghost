package it.cnr.istc.ghost.generator.internal

import org.eclipse.emf.ecore.EObject
import java.util.Collections
import org.eclipse.xtext.EcoreUtil2

class BlockAdapterImpl implements BlockAdapter {
	private EObject real;

	new(EObject real) {
		this.real = real;
	}

	override getContents() {
		return if(real !== null) real.eContents() else Collections.emptyList();
	}

	override getContainer() {
		return real?.eContainer;
	}

	override <T extends EObject> getContainerOfType(Class<T> clazz) {
		return EcoreUtil2.getContainerOfType(real, clazz);
	}
}
