package it.cnr.istc.ghost.standalonecompiler;

import java.io.File;
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

import com.google.inject.Injector;

import it.cnr.istc.ghost.GhostStandaloneSetup;

public class Main {
	
	public static void main(String args[]) {
		String fname = args[0];
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
