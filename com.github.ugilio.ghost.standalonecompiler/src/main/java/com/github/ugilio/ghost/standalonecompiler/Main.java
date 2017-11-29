/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.standalonecompiler;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.PriorityQueue;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.common.util.WrappedException;
import org.eclipse.xtext.diagnostics.Severity;
import org.eclipse.xtext.generator.GeneratorDelegate;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.eclipse.xtext.util.CancelIndicator;
import org.eclipse.xtext.util.RuntimeIOException;
import org.eclipse.xtext.validation.CheckMode;
import org.eclipse.xtext.validation.IResourceValidator;
import org.eclipse.xtext.validation.Issue;

import com.google.inject.Injector;

import com.github.ugilio.ghost.GhostStandaloneSetup;
import joptsimple.OptionException;

public class Main {
	
	private static String GHOSTC_VERSION = "0.1.0-SNAPSHOT";
	
	private static String VERSION_STR = "Ghost compiler "+GHOSTC_VERSION+". Copyright (c) 2017 Giulio Bernardi.";
	
	private static int ERR_OK = 0;
	private static int ERR_CMDLINE = 1;
	private static int ERR_NOFILES = 2;
	private static int ERR_FILENOTFOUND = 3;
	private static int ERR_IOERROR = 4;
	private static int ERR_DIRERROR = 5;
	
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
	
	private static Stream<File> getFiles(File dir) {
		return Arrays.stream(
				dir.listFiles(f -> f.getName().toLowerCase().endsWith(".ghost"))).
				filter(f -> f.canRead()).
				map(f -> f.getAbsoluteFile());
	}
	
	private static void checkDir(String dir) {
		File f = new File(dir);
		if (!f.exists())
			err(String.format("Directory '%s' on the search path does not exist",dir),
					ERR_DIRERROR);
		if (!f.isDirectory())
			err(String.format("Search path entry '%s' is not a directory",dir),
					ERR_DIRERROR);
		if (!f.canRead() || !f.canExecute())
			err(String.format("Cannot list directory '%s': permission denied",dir),
					ERR_DIRERROR);
	}
	
	private static void scanSearchPath(GhostCOptions opts, XtextResourceSet rs) {
		for (String d : opts.searchPaths)
			checkDir(d);
		
		HashSet<File> alreadyAdded = new HashSet<>();
		opts.fnames.stream().map(f -> new File(f).getAbsoluteFile()).
			forEach(f -> alreadyAdded.add(f));
		
		ArrayList<String> allDirs = new ArrayList<>(opts.searchPaths.size()+opts.fnames.size());
		allDirs.addAll(
		opts.fnames.stream().
			map(f -> new File(f).getAbsoluteFile().getParentFile()).
			filter(f -> f.canRead() && f.canExecute()).
			map(f -> f.toString()).
			distinct().collect(Collectors.toList()));
		allDirs.addAll(opts.searchPaths);
		allDirs.stream().
			flatMap(p -> getFiles(new File(p))).
			filter(f -> !alreadyAdded.contains(f)).
			forEach(f -> rs.createResource(URI.createFileURI(f.getPath()),"ghost"));
	}
	
	private static List<Issue> sortIssues(List<Issue> list) {
		if (list.size()<=1)
			return list;
		PriorityQueue<Issue> q = 
		new PriorityQueue<>(list.size(), new Comparator<Issue>() {
			@Override
			public int compare(Issue o1, Issue o2) {
				String uri1 = o1.getUriToProblem().toFileString();
				String uri2 = o2.getUriToProblem().toFileString();
				int tmp = uri1.compareTo(uri2);
				if (tmp != 0)
					return tmp;
				tmp = o1.getLineNumber()-o2.getLineNumber();
				if (tmp != 0)
					return tmp;
				tmp = o1.getColumn()-o2.getColumn();
				if (tmp != 0)
					return tmp;
				return o1.hashCode()-o2.hashCode();
			}
		});
		q.addAll(list);
		list = new ArrayList<>(list.size());
		while (q.peek() != null)
			list.add(q.poll());
		return list;
	}
	
	public static void main(String args[]) {
		try {
		GhostCOptions opts = parseOptions(args);
		if (opts.fnames.size()==0)
			err("No source files specified",ERR_NOFILES);
		
		Logger logger = new Logger(new File("."));
		
		Injector injector = new GhostStandaloneSetup().createInjectorAndDoEMFRegistration();
		XtextResourceSet rs = injector.getInstance(XtextResourceSet.class);

		scanSearchPath(opts, rs);
		
		List<XtextResource> resources = 
				opts.fnames.stream().map(f -> loadFile(rs,f)).
				collect(Collectors.toList());
		
		for (XtextResource resource : resources) {
			IResourceValidator validator = 
				resource.getResourceServiceProvider().getResourceValidator();
			List<Issue> issues = validator.validate(resource, CheckMode.ALL, CancelIndicator.NullImpl);
			for (Issue issue : sortIssues(issues))
				logger.log(issue);
		
			if (!issues.stream().anyMatch(p -> p.getSeverity()==Severity.ERROR))
			{
				GeneratorDelegate generator = injector.getInstance(GeneratorDelegate.class);
				JavaIoFileSystemAccess fsa = injector.getInstance(JavaIoFileSystemAccess.class);
				String path = opts.outputPath;
				if (path == null)
					path = new File(resource.getURI().toFileString()).getParent();
				if (path == null) path = ".";
				fsa.setOutputPath(path);
				generator.doGenerate(resource, fsa);
			}
		}
		}
		catch (RuntimeIOException e) {
			Throwable exc = e;
			while (exc.getCause() != null)
				exc = exc.getCause();
			err("I/O error: "+exc.getMessage(),ERR_IOERROR);
		}
	}

}
