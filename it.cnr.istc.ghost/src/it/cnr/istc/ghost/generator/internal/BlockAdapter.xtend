/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package it.cnr.istc.ghost.generator.internal

import java.util.List
import org.eclipse.emf.ecore.EObject

interface BlockAdapter {
	public def List<? extends Object> getContents();
	public def Object getContainer();
	public def <T extends EObject> T getContainerOfType(Class<T> clazz);
}