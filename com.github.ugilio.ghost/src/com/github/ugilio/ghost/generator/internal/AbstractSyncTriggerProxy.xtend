/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import it.cnr.istc.timeline.lang.SyncTrigger
import it.cnr.istc.timeline.lang.AnnotatedObject
import org.eclipse.emf.ecore.EObject

abstract class AbstractSyncTriggerProxy extends ProxyObject implements SyncTrigger, AnnotatedObject {
	protected abstract def LexicalScope getScope();
	
	new(Register register) {
		super(register);
	}
	
	protected def abstract EObject getReal();
	
	override getAnnotations() {
		val p = Utils.getType(register,real)?.parent;
		if (p !== null) {
			val pt = Utils.getParentSync(p,this)?.trigger;
			if (pt instanceof AnnotatedObject)
				return Utils.merge(pt.getAnnotations(),register.getAnnotationsFor(real),[s|s]);
		}
		return register.getAnnotationsFor(real);
	}
	
}
