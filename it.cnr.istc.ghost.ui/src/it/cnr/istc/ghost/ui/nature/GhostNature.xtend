package it.cnr.istc.ghost.ui.nature

import org.eclipse.core.resources.IProjectNature
import org.eclipse.core.resources.IProject

class GhostNature implements IProjectNature {
	
	public static String ID = "it.cnr.istc.ghost.ui.nature.GhostNature";

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