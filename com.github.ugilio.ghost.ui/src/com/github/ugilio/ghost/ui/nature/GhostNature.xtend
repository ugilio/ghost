/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.ui.nature

import org.eclipse.core.resources.IProjectNature
import org.eclipse.core.resources.IProject

class GhostNature implements IProjectNature {
	
	public static String ID = "com.github.ugilio.ghost.ui.nature.GhostNature";

	private IProject project;
	
	override configure() { }
	
	override deconfigure() {}
	
	override getProject() {
		return project;
	}
	
	override setProject(IProject project) {
		this.project = project;
	}
	
}