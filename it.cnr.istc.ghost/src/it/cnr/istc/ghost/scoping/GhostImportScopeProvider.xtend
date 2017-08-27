package it.cnr.istc.ghost.scoping

import org.eclipse.xtext.scoping.impl.ImportedNamespaceAwareLocalScopeProvider
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.scoping.IScope
import org.eclipse.emf.ecore.EReference
import it.cnr.istc.ghost.ghost.ImportDecl
import org.eclipse.xtext.scoping.impl.FilteringScope
import com.google.inject.Inject
import org.eclipse.xtext.util.IResourceScopeCache
import org.eclipse.xtext.util.Tuples
import com.google.inject.Provider
import java.util.HashSet
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.IEObjectDescription

class GhostImportScopeProvider extends ImportedNamespaceAwareLocalScopeProvider {
	//consider wildcards always on
	override ImportNormalizer doCreateImportNormalizer(QualifiedName importedNamespace, boolean wildcard, boolean ignoreCase) {
		super.doCreateImportNormalizer(importedNamespace,true,ignoreCase);
	}
	
	//Allow importedNamespace from non-string features
	override getImportedNamespace(EObject object){
		val feature = object.eClass().getEStructuralFeature("importedNamespace");
		if (feature != null) {
			if (String.equals(feature.EType.instanceClass))
				return object.eGet(feature) as String;
			//FIXME: this is hackish. Get value of the feature from the text node...
			val leaves = NodeModelUtils.getNode(object).leafNodes.filter[!isHidden].toList;
			if (leaves.size>=2)
				return leaves.get(1).text;
		}
		return null;
	}
	
	//Filter out elements from global scope that don't belong to imported domains
	@Inject
	private IResourceScopeCache cache = IResourceScopeCache.NullImpl.INSTANCE;
	
	def protected HashSet<String> getImports(Resource res) {
		return cache.get(Tuples.create(res, "imports"), res, new Provider<HashSet<String>>() {
			override HashSet<String> get() {
				val root = res?.contents?.get(0);
				val names = getImportedNamespaceResolvers(root,false).
					map[n | n.importedNamespacePrefix.toString];
				return new HashSet<String>(names);
			}
		});
	}
	
	def isVisible(EObject context, IEObjectDescription desc) {
		val res = context.eResource;
		return context.eResource == desc.EObjectOrProxy.eResource || 
			getImports(res).contains(desc.qualifiedName.firstSegment);
	}
	
	def IScope filterNotImported(EObject context, EReference reference, IScope scope) {
		return new FilteringScope(scope,[o | isVisible(context,o)]);
	}
	
	override IScope getScope(EObject context, EReference reference) {
		val scope = super.getScope(context, reference);
		if (context instanceof ImportDecl)
			return scope;
		return filterNotImported(context,reference,scope);
	}
	
}