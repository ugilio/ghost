package it.cnr.istc.ghost.standalonecompiler;

import java.io.File;
import java.util.Collections;
import java.util.List;

import org.eclipse.emf.common.util.URI;
import org.eclipse.xtext.diagnostics.Severity;
import org.eclipse.xtext.generator.GeneratorDelegate;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.eclipse.xtext.util.CancelIndicator;
import org.eclipse.xtext.validation.CheckMode;
import org.eclipse.xtext.validation.IResourceValidator;
import org.eclipse.xtext.validation.Issue;

import com.google.devtools.common.options.OptionsParser;
import com.google.devtools.common.options.OptionsParsingException;
import com.google.inject.Injector;

import it.cnr.istc.ghost.GhostStandaloneSetup;

public class Main {
	
	private static String GHOSTC_VERSION = "1.0.0-SNAPSHOT";
	
	private static String VERSION_STR = "Ghost compiler "+GHOSTC_VERSION+". Copyright (c) 2017 Giulio Bernardi.";
	
	private static int ERR_OK = 0;
	private static int ERR_CMDLINE = 1;
	private static int ERR_NOFILES = 2;
	
	private static void printHelp(OptionsParser p) {
		String help[] = new String[]{
				VERSION_STR,
				"",
				"Usage: ghostc [options] source-files...",
				p.describeOptions(Collections.emptyMap(),
						OptionsParser.HelpVerbosity.LONG),
				""
		};
		
		for (String s : help)
			System.out.println(s);
	}
	
	private static void printVersion() {
		System.out.println(VERSION_STR);
		System.out.println();
	}
	
	private static GhostCOptions parseOptions(String args[]) {
		OptionsParser p = OptionsParser.newOptionsParser(GhostCOptions.class);
		try {
			p.parse(args);
		}
		catch (OptionsParsingException e) {
			System.err.println("Cannot parse command line: "+e.getMessage());
			printHelp(p);
			System.exit(ERR_CMDLINE);
		}
		GhostCOptions opts = p.getOptions(GhostCOptions.class);
		opts.fnames=p.getResidue();
		if (opts.help)
			printHelp(p);
		else if (opts.version)
			printVersion();
		else
			return opts;
		System.exit(ERR_OK);
		return null;
	}
	
	public static void err(String msg, int code) {
		System.err.println(msg);
		System.exit(code);
	}
	
	public static void main(String args[]) {
		GhostCOptions opts = parseOptions(args);
		if (opts.fnames.size()==0)
			err("No source files specified",ERR_NOFILES);
		String fname = opts.fnames.get(0);
		
		Logger logger = new Logger(new File("."));
		
		Injector injector = new GhostStandaloneSetup().createInjectorAndDoEMFRegistration();
		XtextResourceSet rs = injector.getInstance(XtextResourceSet.class);
		
		XtextResource resource = (XtextResource)rs.getResource(URI.createFileURI(fname),true);
		//add dependent files...
		
		IResourceValidator validator = 
				resource.getResourceServiceProvider().getResourceValidator();
		List<Issue> issues = validator.validate(resource, CheckMode.ALL, CancelIndicator.NullImpl);
		for (Issue issue : issues)
			logger.log(issue);
		
		if (!issues.stream().anyMatch(p -> p.getSeverity()==Severity.ERROR))
		{
			GeneratorDelegate generator = injector.getInstance(GeneratorDelegate.class);
			JavaIoFileSystemAccess fsa = injector.getInstance(JavaIoFileSystemAccess.class);
			fsa.setOutputPath(".");
			generator.doGenerate(resource, fsa);
		}
		
	}

}
