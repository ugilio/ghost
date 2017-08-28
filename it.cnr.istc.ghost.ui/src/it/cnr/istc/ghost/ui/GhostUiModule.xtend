/*
 * generated by Xtext 2.10.0
 */
package it.cnr.istc.ghost.ui

import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import com.google.inject.Provider
import org.eclipse.xtext.resource.containers.IAllContainersState

/**
 * Use this class to register components to be used within the Eclipse IDE.
 */
@FinalFieldsConstructor
class GhostUiModule extends AbstractGhostUiModule {
	
	/**
	/* Each project acts as a container and the project references
	/* (Properties → Project References) are the visible containers.
	*/
	override Provider<IAllContainersState> provideIAllContainersState() {
		return org.eclipse.xtext.ui.shared.Access.getWorkspaceProjectsState()
	}
}