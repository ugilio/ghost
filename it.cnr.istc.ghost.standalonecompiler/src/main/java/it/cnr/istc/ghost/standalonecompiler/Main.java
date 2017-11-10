package it.cnr.istc.ghost.standalonecompiler;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.List;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.common.util.WrappedException;
import org.eclipse.xtext.diagnostics.Severity;
import org.eclipse.xtext.generator.GeneratorDelegate;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.eclipse.xtext.util.CancelIndicator;
import org.eclipse.xtext.validation.CheckMode;
import org.eclipse.xtext.validation.IResourceValidator;
import org.eclipse.xtext.validation.Issue;

import com.google.inject.Injector;

import it.cnr.istc.ghost.GhostStandaloneSetup;
import joptsimple.OptionException;

public class Main {
	
	private static String GHOSTC_VERSION = "1.0.0-SNAPSHOT";
	
	private static String VERSION_STR = "Ghost compiler "+GHOSTC_VERSION+". Copyright (c) 2017 Giulio Bernardi.";
	
	private static int ERR_OK = 0;
	private static int ERR_CMDLINE = 1;
	private static int ERR_NOFILES = 2;
	private static int ERR_FILENOTFOUND = 3;
	private static int ERR_IOERROR = 4;
	
	private static void printHelp() {
		printVersion();
		for (String s : OptionParser.getHelpMessage())
			System.out.println(s);
	}
	
	private static void printHelpErr() {
		for (String s : OptionParser.getHelpMessage())
			System.err.println(s);
	}
	
	private static void printVersion() {
		System.out.println(VERSION_STR);
		System.out.println();
	}
	
	private static GhostCOptions parseOptions(String args[]) {
		OptionParser p = new OptionParser();
		GhostCOptions opts = null;;
		try {
			opts = p.parse(args);
		}
		catch (OptionException e) {
			System.err.println("Wrong arguments: "+e.getMessage());
			printHelpErr();
			System.exit(ERR_CMDLINE);
		}
		if (opts.help)
			printHelp();
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
	
	private static XtextResource loadFile(XtextResourceSet rs, String fname) {
		URI uri = URI.createFileURI(fname);
		rs.createResource(uri, "ghost");
		try {
			return (XtextResource)rs.getResource(uri, true);
		}
		catch (WrappedException w) {
			Exception e = w.exception();
			if (e instanceof FileNotFoundException)
				err(String.format("File '%s' does not exist.",fname),ERR_FILENOTFOUND);
			else
				err(String.format("Cannot read file '%s': ", e.getMessage()),ERR_IOERROR);
		}
		return null;
	}
	
	public static void main(String args[]) {
		GhostCOptions opts = parseOptions(args);
		if (opts.fnames.size()==0)
			err("No source files specified",ERR_NOFILES);
		String fname = opts.fnames.get(0);
		
		Logger logger = new Logger(new File("."));
		
		Injector injector = new GhostStandaloneSetup().createInjectorAndDoEMFRegistration();
		XtextResourceSet rs = injector.getInstance(XtextResourceSet.class);

		XtextResource resource = loadFile(rs,fname);
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
