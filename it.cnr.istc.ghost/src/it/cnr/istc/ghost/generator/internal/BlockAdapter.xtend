package it.cnr.istc.ghost.generator.internal

import java.util.List
import org.eclipse.emf.ecore.EObject

interface BlockAdapter {
	public def List<? extends Object> getContents();
	public def Object getContainer();
	public def <T extends EObject> T getContainerOfType(Class<T> clazz);
}