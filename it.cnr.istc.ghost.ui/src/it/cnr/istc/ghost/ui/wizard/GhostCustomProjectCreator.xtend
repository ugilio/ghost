package it.cnr.istc.ghost.ui.wizard

import it.cnr.istc.ghost.ui.wizard.GhostProjectCreator
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.resources.IProject
import java.util.ArrayList
import it.cnr.istc.ghost.ui.nature.GhostNature

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