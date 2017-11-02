/*
 * generated by Xtext 2.12.0
 */
package it.cnr.istc.ghost.generator

import com.google.inject.Inject
import it.cnr.istc.ghost.ghost.Ghost
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class GhostGenerator extends AbstractGenerator {
	@Inject
	DdlProducer generator;
	
	private def String getOutFileName(Resource res) {
		return res.URI.trimFileExtension.appendFileExtension("ddl").lastSegment();
	}
	
	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		//Cannot compile if there are errors
		if (resource.errors.size()>0)
			return;

		val ghost = resource.contents.get(0) as Ghost;

		val String output = generator.doGenerate(ghost);
		
		val outName = getOutFileName(resource);
		fsa.generateFile(outName, output);
	}
}
