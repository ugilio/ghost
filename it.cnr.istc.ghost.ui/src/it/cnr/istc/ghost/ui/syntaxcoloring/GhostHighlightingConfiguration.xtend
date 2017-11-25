/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package it.cnr.istc.ghost.ui.syntaxcoloring

import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultHighlightingConfiguration
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfigurationAcceptor
import org.eclipse.xtext.ui.editor.utils.TextStyle
import org.eclipse.swt.graphics.RGB
import org.eclipse.swt.SWT

class GhostHighlightingConfiguration extends DefaultHighlightingConfiguration {
	
	public static final String ENUM_LITERAL_ID = "enumLiteral";
	public static final String CONST_LITERAL_ID = "constLiteral";
	public static final String COMPVAR_ID = "compVar";
	public static final String INITVAR_ID = "initvar";
	public static final String ANNOTATION_ID = "annotation";
	public static final String DIRECTIVE_ID = "directive";

	override configure(IHighlightingConfigurationAcceptor acceptor) {
		acceptor.acceptDefaultHighlighting(KEYWORD_ID, "Keyword", keywordTextStyle());
		acceptor.acceptDefaultHighlighting(COMMENT_ID, "Comment", commentTextStyle());
		acceptor.acceptDefaultHighlighting(NUMBER_ID, "Number", numberTextStyle());
		acceptor.acceptDefaultHighlighting(DEFAULT_ID, "Default", defaultTextStyle());
		acceptor.acceptDefaultHighlighting(INVALID_TOKEN_ID, "Invalid Symbol", errorTextStyle());
		
		acceptor.acceptDefaultHighlighting(ENUM_LITERAL_ID, "Enum Literal", enumLiteralTextStyle());
		acceptor.acceptDefaultHighlighting(CONST_LITERAL_ID, "Const Literal", constLiteralTextStyle());
		acceptor.acceptDefaultHighlighting(COMPVAR_ID, "Component Variable", objVarDeclTextStyle());
		acceptor.acceptDefaultHighlighting(INITVAR_ID, "Init Variable", initVarTextStyle());
		acceptor.acceptDefaultHighlighting(ANNOTATION_ID, "Annotation", annotationTextStyle());
		acceptor.acceptDefaultHighlighting(DIRECTIVE_ID, "Directive", directiveTextStyle());
	}
	
	public def TextStyle enumLiteralTextStyle() {
		val textStyle = defaultTextStyle().copy();
		textStyle.setColor(new RGB(0, 0, 192));
		textStyle.setStyle(SWT.BOLD + SWT.ITALIC);
		return textStyle;
	}
	
	public def TextStyle constLiteralTextStyle() {
		val textStyle = defaultTextStyle().copy();
		textStyle.setColor(new RGB(0, 0, 192));
		textStyle.setStyle(SWT.BOLD + SWT.ITALIC);
		return textStyle;
	}
	
	public def TextStyle objVarDeclTextStyle() {
		val textStyle = defaultTextStyle().copy();
		textStyle.setColor(new RGB(0, 0, 192));
		return textStyle;
	}
	
	public def TextStyle initVarTextStyle() {
		val textStyle = defaultTextStyle().copy();
		textStyle.setColor(new RGB(0, 0, 192));
		textStyle.setStyle(SWT.ITALIC);
		return textStyle;
	}
	
	public def TextStyle annotationTextStyle() {
		val textStyle = defaultTextStyle().copy();
		textStyle.setColor(new RGB(100, 100, 100));
		return textStyle;
	}
	
	public def TextStyle directiveTextStyle() {
		val textStyle = defaultTextStyle().copy();
		textStyle.setColor(new RGB(63, 95, 191));
		return textStyle;
	}
	
}