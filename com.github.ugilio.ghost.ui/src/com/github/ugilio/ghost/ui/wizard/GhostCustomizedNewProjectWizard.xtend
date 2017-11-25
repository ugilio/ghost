/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.ui.wizard

import com.github.ugilio.ghost.ui.wizard.GhostNewProjectWizard
import com.google.inject.Inject
import org.eclipse.xtext.ui.wizard.IProjectCreator
import org.eclipse.xtext.ui.IImageHelper.IImageDescriptorHelper

class GhostCustomizedNewProjectWizard extends GhostNewProjectWizard {
	
	@Inject
	new (IProjectCreator projectCreator, IImageDescriptorHelper helper) {
		super(projectCreator);
		setDefaultPageImageDescriptor(helper.getImageDescriptor("newproject_big.png"));
	}

	
}