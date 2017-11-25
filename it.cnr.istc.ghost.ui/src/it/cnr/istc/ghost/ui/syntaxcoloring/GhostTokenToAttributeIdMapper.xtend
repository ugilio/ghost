package it.cnr.istc.ghost.ui.syntaxcoloring

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