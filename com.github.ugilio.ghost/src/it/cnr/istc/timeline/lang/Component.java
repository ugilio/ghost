/*
 * Copyright (c) 2017 PST (http://istc.cnr.it/group/pst).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *   Giulio Bernardi
 */
package it.cnr.istc.timeline.lang;

import java.util.List;
import java.util.Map;

public interface Component {
	public String getName();
	public CompType getType();
	public List<ComponentReference> getVariableBindings();
	public Map<ComponentVariable, Component> getVariableMapping();
}
