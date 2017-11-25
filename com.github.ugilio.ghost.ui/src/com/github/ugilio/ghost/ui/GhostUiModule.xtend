/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * generated by Xtext 2.12.0
 */
package com.github.ugilio.ghost.ui

import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import com.google.inject.Provider
import org.eclipse.xtext.resource.containers.IAllContainersState
import com.github.ugilio.ghost.ui.contentassist.NullHover
import com.github.ugilio.ghost.ui.wizard.GhostCustomProjectCreator
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfiguration
import com.github.ugilio.ghost.ui.syntaxcoloring.GhostHighlightingConfiguration
import org.eclipse.xtext.ui.editor.syntaxcoloring.AbstractAntlrTokenToAttributeIdMapper
import com.github.ugilio.ghost.ui.syntaxcoloring.GhostTokenToAttributeIdMapper
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator
import com.github.ugilio.ghost.ui.syntaxcoloring.GhostSemanticHighlightingCalculator

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
	
	override bindIEObjectHover() {
		return NullHover;
	}
	
	override bindIProjectCreator() {
		return GhostCustomProjectCreator;
	}
	
	def Class<? extends IHighlightingConfiguration> bindIHighlightingConfiguration() {
		return GhostHighlightingConfiguration;
	}
	
	def Class<? extends AbstractAntlrTokenToAttributeIdMapper> bindAbstractAntlrTokenToAttributeIdMapper() {
		return GhostTokenToAttributeIdMapper;
	}
	
	def Class<? extends ISemanticHighlightingCalculator> bindIdeSemanticHighlightingCalculator() {
		return GhostSemanticHighlightingCalculator;
	}
	
}