/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.ui.syntaxcoloring

import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultAntlrTokenToAttributeIdMapper

class GhostTokenToAttributeIdMapper extends DefaultAntlrTokenToAttributeIdMapper {
	
	override calculateId(String tokenName, int tokenType) {
		val id = 
		switch (tokenName) {
			case "RULE_BR_ANNOTATION", case "RULE_SL_ANNOTATION":
				GhostHighlightingConfiguration.ANNOTATION_ID
			case "RULE_DIRECTIVE": GhostHighlightingConfiguration.DIRECTIVE_ID
			default: super.calculateId(tokenName, tokenType)
		}
		return id;
	}	
}