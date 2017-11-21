package it.cnr.istc.ghost.ui.contentassist

import org.eclipse.xtext.ui.editor.contentassist.AbstractJavaBasedContentProposalProvider.ReferenceProposalCreator
import org.eclipse.xtext.scoping.IScope
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import com.google.common.base.Predicate
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.EcoreUtil2
import java.util.ArrayList
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import it.cnr.istc.ghost.ghost.ResourceDecl
import it.cnr.istc.ghost.ghost.SvDecl
import it.cnr.istc.ghost.ghost.NamedCompDecl
import org.eclipse.xtext.naming.IQualifiedNameProvider
import com.google.inject.Inject
import org.eclipse.xtext.scoping.impl.ImportScope
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.resource.ResourceSet
import it.cnr.istc.ghost.ghost.ComponentType
import org.eclipse.xtext.util.IResourceScopeCache
import com.google.inject.Provider
import java.util.List
import org.eclipse.xtext.util.Tuples
import java.util.HashMap
import org.eclipse.emf.common.util.URI

class GhostReferenceProposalCreator extends ReferenceProposalCreator {

	@Inject
	private IQualifiedNameProvider qualifiedNameProvider;

	@Inject
	private IResourceScopeCache cache = IResourceScopeCache.NullImpl.INSTANCE;
	
	private def getNormalizersForTypeHierarchy(EObject obj) {
		var ArrayList<ImportNormalizer> list = null;
		var o = obj;
		while (o !== null) {
			o = switch (o) {
				SvDecl: o.parent
				ResourceDecl: o.parent
				NamedCompDecl: o.type
				default: null 
			}
			if (o !== null && o.eIsProxy)
				EcoreUtil.resolve(obj,null as ResourceSet);
			if (o !== null && o.eIsProxy)
				return list;
			if (list === null && o !== null)
				list = new ArrayList<ImportNormalizer>();
			if (o !== null) {
				val qn = qualifiedNameProvider.getFullyQualifiedName(o);
				list.add(new ImportNormalizer(qn,true,false));
			}
		}
		return list;
	}
	
	private def Iterable<IEObjectDescription> filterDuplicateDescriptions(Iterable<IEObjectDescription> descs) {
		val map = new HashMap<URI,IEObjectDescription>();
		for (d : descs) {
			val uri = d.EObjectURI;
			val old = map.get(uri);
			if (old === null)
				map.put(uri,d)
			else if (old !== null) {
				//prefer shorter names
				if (old.name.segmentCount > d.name.segmentCount)
					map.put(uri,d);
			}
	 	}
	 	return map.values;
	}

	override queryScope(IScope scope, EObject model, EReference reference, Predicate<IEObjectDescription> filter) {
		val list = 
		cache.get(Tuples.create(model,"hierarchyNormalizers"),model.eResource,new Provider<List<ImportNormalizer>>(){
			override get() {
				var EObject cont = EcoreUtil2.getContainerOfType(model,ComponentType);
				if (cont === null)
					cont = EcoreUtil2.getContainerOfType(model,NamedCompDecl);
				if (cont !== null)
					return getNormalizersForTypeHierarchy(cont);
				return null;
			}
			
		});
		var theScope = scope;
		if (list !== null && !list.isEmpty)
			theScope=new ImportScope(list,scope,null,reference.EReferenceType,false);
		return filterDuplicateDescriptions(theScope.getAllElements());
	}
}