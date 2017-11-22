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
import com.google.common.base.Function
import org.eclipse.jface.text.contentassist.ICompletionProposal
import it.cnr.istc.ghost.ghost.GhostPackage
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import it.cnr.istc.ghost.ghost.ValueDecl
import it.cnr.istc.ghost.ghost.FormalPar
import org.eclipse.jface.text.link.LinkedPositionGroup
import org.eclipse.jface.text.link.LinkedPosition
import org.eclipse.jface.text.link.LinkedModeModel
import org.eclipse.jface.text.link.LinkedModeUI

class GhostReferenceProposalCreator extends ReferenceProposalCreator {

	@Inject
	private IQualifiedNameProvider qualifiedNameProvider;

	@Inject
	private IResourceScopeCache cache = IResourceScopeCache.NullImpl.INSTANCE;
	
	protected ContentAssistContext context;
	
	public def void setContext(ContentAssistContext context) {
		this.context = context;
	}
	
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
	
	override getWrappedFactory(EObject model, EReference reference,
				Function<IEObjectDescription, ICompletionProposal> proposalFactory) {
		return [od|
			val result = proposalFactory.apply(od);
			if (result instanceof ConfigurableCompletionProposal)
				//Add "." after component in qualified instantiated values
				if (reference == GhostPackage.Literals.QUALIF_INST_VAL__COMP) {
					result.textApplier = [doc,prop|
						prop.cursorPosition=prop.cursorPosition+1;
						doc.replace(prop.getReplacementOffset(),
							prop.getReplacementLength(),
							prop.getReplacementString()+"."
						);						
					];
				}
				else if (reference == GhostPackage.Literals.QUALIF_INST_VAL__VALUE
					|| reference == GhostPackage.Literals.SIMPLE_INST_VAL__VALUE) {
					val obj = od.EObjectOrProxy;
					val extraArgs = if (reference == GhostPackage.Literals.SIMPLE_INST_VAL__VALUE)
						" -> " else null;
					if (obj instanceof ValueDecl) {
						setProposalForValueDecl(result,obj.parlist?.values,extraArgs);
					}
				}
				else if (reference == GhostPackage.Literals.RES_CONSTR__RES) {
					setProposalForArgList(result,#["amount"]);
				}
			return result;
		];
	}
	
	private def void setProposalForValueDecl(ConfigurableCompletionProposal p,
		List<FormalPar> values, String extraArgs) {
		if (values === null || values.length == 0)
			return;
		var argcount = 1;
		val names = new ArrayList<String>(values.size());
		for (v : values) {
			if (v.name === null)
				names.add("arg"+argcount++)
			else
				names.add(v.name);
		}
		setProposalForArgList(p,names,extraArgs);
	}
	
	private def void setProposalForArgList(ConfigurableCompletionProposal p,
		List<String> names) {
		setProposalForArgList(p, names, null);
	}
	
	private def void setProposalForArgList(ConfigurableCompletionProposal p,
		List<String> names, String extraArg) {
		if (names === null || names.length == 0)
			return;
		p.textApplier = [doc,prop|
			var argStr = "(";
			var start = prop.cursorPosition + prop.replacementOffset+1;
			val selStart = start;
			val selLength = names.get(0).length;
			val groups = new ArrayList<LinkedPositionGroup>(names.size());
			for (n : names) {
				val group= new LinkedPositionGroup();
				group.addPosition(new LinkedPosition(doc, start, n.length, LinkedPositionGroup.NO_STOP));
				groups.add(group);
				argStr+=n+", ";
				start+=n.length+2;				
			}
			argStr=argStr.substring(0,argStr.length-2)+")"+if (extraArg===null) "" else extraArg;
			
			doc.replace(prop.getReplacementOffset(),
				prop.getReplacementLength(),
				prop.getReplacementString()+argStr
			);
			prop.cursorPosition=prop.cursorPosition+argStr.length;
			
			prop.selectionStart =  selStart;
			prop.selectionLength = selLength;
			
			if (context?.viewer !== null) {
				val model= new LinkedModeModel();
				for (g : groups)
					model.addGroup(g);
				model.forceInstall();

				val ui= new LinkedModeUI(model, context.viewer);
				/*
				ui.setExitPolicy([env,ev,offs,len|
					switch (ev.character as int) {
						case 0x0d, case 0x0a: ev.character='\t'
					}
					return null;
				]);
				*/
				ui.setExitPosition(context.viewer, prop.replacementOffset + prop.cursorPosition, 0, Integer.MAX_VALUE);
				ui.setCyclingMode(LinkedModeUI.CYCLE_NEVER);
				ui.enter();
			}
		];
	}
}