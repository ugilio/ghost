/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import static extension com.github.ugilio.ghost.generator.internal.Utils.*;
import com.github.ugilio.ghost.ghost.AnonResDecl
import com.github.ugilio.ghost.ghost.AnonSVDecl
import com.github.ugilio.ghost.ghost.Externality
import com.github.ugilio.ghost.ghost.NamedCompDecl
import com.github.ugilio.ghost.ghost.ResourceDecl
import com.github.ugilio.ghost.ghost.SvDecl
import it.cnr.istc.timeline.lang.CompType
import it.cnr.istc.timeline.lang.ComponentVariable
import it.cnr.istc.timeline.lang.ResSyncTrigger
import it.cnr.istc.timeline.lang.SVSyncTrigger
import it.cnr.istc.timeline.lang.Synchronization
import it.cnr.istc.timeline.lang.TransitionConstraint
import it.cnr.istc.timeline.lang.Value
import java.util.ArrayList
import java.util.Collections
import java.util.List

abstract class AbstractCompTypeProxy extends ProxyObject implements CompType {
	protected CompTypeAdapter real;
	String name = null;
	Boolean externality = null;	
	List<Synchronization> synchronizations = null;
	List<ComponentVariable> variables = null;
	
	protected static def CompTypeAdapter getCompTypeAdapter(Object o) {
		return
		switch (o) {
			SvDecl : new StandardSVCompTypeAdapter(o)
			ResourceDecl : new StandardResCompTypeAdapter(o)
			AnonSVDecl : new SyntheticSVCompTypeAdapter(o)
			AnonResDecl : new SyntheticResCompTypeAdapter(o)
			NamedCompDecl : switch (o.type) {
								SvDecl : new SyntheticSVCompTypeAdapter(o)
								ResourceDecl : new SyntheticResCompTypeAdapter(o)
								default : throw new IllegalArgumentException("Don't know how to create adapter for "+o.type)
							}
			default : throw new IllegalArgumentException("Don't know how to create adapter for "+o)
		}
	}

	new(Object real, Register register) {
		super(register);
		this.real = getCompTypeAdapter(real);
	}

	protected def Externality getExternality() {
		var tmp = real?.externality;
		if (tmp == Externality.UNSPECIFIED) {
			val p = getParent() as AbstractCompTypeProxy;
			if (p !== null)
				tmp = p.getExternality();
		}
		if (tmp == Externality.UNSPECIFIED)
			tmp = getDefaultExternality(real.real);
		return tmp;
	}

	override isExternal() {
		if (externality === null)
			externality = getExternality() == Externality.EXTERNAL;
		return (externality == true);
	}
	
	def dispatch String getChildName(SVSyncTrigger t1) {
		return t1?.value?.name;
	}

	def dispatch String getChildName(ResSyncTrigger t1) {
		return t1?.action.toString();
	}

	def dispatch String getChildName(Synchronization s1) {
		return getChildName(s1?.trigger);
	}

	def dispatch String getChildName(Value v1) {
		return v1.name;
	}

	def dispatch String getChildName(TransitionConstraint tc1) {
		return tc1?.head?.name;
	}

	def dispatch String getChildName(ComponentVariable v1) {
		return v1?.name;
	}

	def dispatch String getChildName(Object o1) { o1.toString() }
	def dispatch String getChildName(Void o1) { null }
	
	

	def <T> List<T> merge(List<T> parent, List<T> child) {
		val l = new ArrayList(parent.size + child.size);
		l.addAll(parent);
		l.addAll(child);
		return Utils.retainRedef(l,[e|getChildName(e)]);
	}

	override getDeclaredSynchronizations() {
		if (synchronizations === null) {
			val tmp = real?.getDeclaredSynchronizations();
			synchronizations = if (tmp !== null)
				tmp.map[v|getProxy(v) as Synchronization].toRegularList
			else
				Collections.emptyList();
		}
		return synchronizations;
	}

	override getDeclaredVariables() {
		if (variables === null) {
			val tmp = real?.getDeclaredVariables();
			variables = if (tmp !== null)
				tmp.map[v|getProxy(v) as ComponentVariable].toList
			else
				Collections.emptyList();
		}
		return variables;
	}

	override getSynchronizations() {
		var p = getParent();
		if (p !== null)
			return merge(p.getSynchronizations(), getDeclaredSynchronizations());
		return getDeclaredSynchronizations();
	}

	override getVariables() {
		var p = getParent();
		if (p !== null)
			return merge(p.getVariables(), getDeclaredVariables());
		return getDeclaredVariables();
	}

	override getName() {
		if (name !== null)
			return name;
		return real.getName(register);
	}
	
	public def void setName(String name) {
		this.name = name;
	}
}
