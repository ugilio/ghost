package it.cnr.istc.ghost.ui.wizard

import it.cnr.istc.ghost.ui.wizard.GhostNewProjectWizard
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