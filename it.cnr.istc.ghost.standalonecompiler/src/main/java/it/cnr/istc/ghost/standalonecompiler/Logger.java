/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package it.cnr.istc.ghost.standalonecompiler;

import java.io.File;

import org.eclipse.emf.common.util.URI;
import org.eclipse.xtext.validation.Issue;

public class Logger {
	private URI baseUri;
	
	public Logger(File baseDir) {
		String path = baseDir.getAbsoluteFile().toString();
		baseUri = URI.createFileURI(path);
	}
	
	public void log(Issue issue) {
		
		String lev = "Unknown Error";
		switch (issue.getSeverity()) {
			case ERROR : lev = "Error"; break;
			case WARNING : lev = "Warning"; break;
			case INFO : lev = "Info"; break;
			case IGNORE : lev = "Debug"; break;
		}
		
		URI uri = issue.getUriToProblem();
		String fname = uri.deresolve(baseUri).toFileString();
		String fpos = String.format("(%d:%d)",issue.getLineNumber(),issue.getColumn());
		String msg = issue.getMessage();
		
		String fmt = String.format("[%s] %s%s: %s", lev,fname,fpos,msg);
		System.out.println(fmt);
	}

}
