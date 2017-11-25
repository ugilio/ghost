/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.standalonecompiler;

import java.util.Arrays;
import java.util.List;

import joptsimple.OptionException;
import joptsimple.OptionSet;
import joptsimple.OptionSpec;

public class OptionParser {
	joptsimple.OptionParser parser;
	OptionSpec<Void> help;
	OptionSpec<Void> version;
	OptionSpec<String> searchPaths;
	OptionSpec<String> outputPath;
	OptionSpec<String> files;
	
	private static List<String> l(String... arg) {
		return Arrays.asList(arg);
	}
	
	public OptionParser() {
		parser = new joptsimple.OptionParser(false);
		help = parser.acceptsAll(l("help","h"), "Prints this help");
		version = parser.acceptsAll(l("version","v"), "Shows the program version");
		searchPaths = parser.acceptsAll(l("path","P")).withRequiredArg().ofType(String.class).
				describedAs("Adds the specified directory to the search path for imported domains");
		outputPath = parser.acceptsAll(l("output","O")).withRequiredArg().ofType(String.class).
				describedAs("Sets the output path where to generate compiled files");
		files = parser.nonOptions().ofType(String.class);
	}
	
	public GhostCOptions parse(String args[]) throws OptionException {
		OptionSet set = parser.parse(args);
		GhostCOptions opts = new GhostCOptions();
		opts.help = set.has(help);
		opts.version = set.has(version);
		opts.searchPaths = set.valuesOf(searchPaths);
		opts.outputPath = set.valueOf(outputPath);
		opts.fnames = set.valuesOf(files);
		return opts;
	}
	
	public static String[] getHelpMessage() {
		return new String[]{
				"Usage: ghostc [options] source-files...",
				"",
				"Options:",
				"-P, --path <path>   Adds the specified directory to the search path for",
				"                    imported domains. This option can be specified multiple",
				"                    times.",
				"-O, --output <path> Sets the output path where to generate compiled files.",
				"-h, --help          Prints this help.",
				"-v, --version       Shows the program version.",
				""
		};
		
	}

}
