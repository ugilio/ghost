package it.cnr.istc.ghost.generator.internal

import static extension it.cnr.istc.ghost.generator.internal.Utils.*;
import it.cnr.istc.ghost.ghost.LocVarDecl
import java.util.List
import org.eclipse.emf.ecore.EObject

class MultiBlockAdapterImpl implements BlockAdapter {
	private List<? extends EObject> real;
	
	new(List<? extends EObject> real) {
		this.real = real;
	}

	private def keepLastVarOnly(List<? extends Object> l, String name) {
		val sub = l.filter(LocVarDecl).filter[o|o.name == name].toRegularList;
		for (var i = 0; i < sub.size() - 1; i++)
			l.remove(sub.get(i));
	}

	override getContents() {
		val l = real.map[o|o.eContents()].flatten.toRegularList;
		keepLastVarOnly(l, 'start');
		keepLastVarOnly(l, 'horizon');
		keepLastVarOnly(l, 'resolution');
		return l;
	}

	override getContainer() {
		return null;
	}

	override <T extends EObject> getContainerOfType(Class<T> clazz) {
		return null;
	}

}
