/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.ui.wizard

import com.github.ugilio.ghost.ui.wizard.GhostProjectCreator
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.resources.IProject
import java.util.ArrayList
import com.github.ugilio.ghost.ui.nature.GhostNature

class GhostCustomProjectCreator extends GhostProjectCreator {
	
	override enhanceProject(IProject project, IProgressMonitor monitor) {
		addNature(project,GhostNature.ID);
		super.enhanceProject(project, monitor);
	}
	
	
	private def void addNature(IProject project, String natureID) {
		if (!project.hasNature(natureID)) {
			val description = project.getDescription();
			val prevNatures= description.getNatureIds();
			val newNatures= new ArrayList<String>(prevNatures.length + 1);
			newNatures.addAll(prevNatures);
			newNatures.add(0,natureID);
			description.setNatureIds(newNatures);
			project.setDescription(description, null);
		}
	}
	
}