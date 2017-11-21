package it.cnr.istc.ghost.utils

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2
import it.cnr.istc.ghost.ghost.Synchronization
import it.cnr.istc.ghost.ghost.NamedPar
import java.util.Collections
import it.cnr.istc.ghost.ghost.LocVarDecl
import com.google.common.collect.Iterables
import it.cnr.istc.ghost.ghost.SyncBody
import it.cnr.istc.ghost.ghost.TransConstraint
import it.cnr.istc.ghost.ghost.FormalPar
import it.cnr.istc.ghost.ghost.InitSection
import it.cnr.istc.ghost.ghost.ResourceDecl
import it.cnr.istc.ghost.ghost.AnonResDecl
import it.cnr.istc.ghost.ghost.NamedCompDecl
import it.cnr.istc.ghost.ghost.ComponentType
import it.cnr.istc.ghost.ghost.SvDecl
import it.cnr.istc.ghost.ghost.ResSimpleInstVal
import it.cnr.istc.ghost.ghost.SimpleInstVal
import it.cnr.istc.ghost.ghost.ValueDecl
import it.cnr.istc.ghost.ghost.ConstExpr
import it.cnr.istc.ghost.ghost.CompResBody
import it.cnr.istc.ghost.ghost.ConstPlaceHolder
import it.cnr.istc.ghost.ghost.ObjVarDecl
import java.util.List
import java.util.ArrayList

class Utils {
	
	public static def getSymbolsForBlock(EObject context) {
		//Inside a synchronization body
		var syncbody = EcoreUtil2.getContainerOfType(context,SyncBody);
		if (syncbody === null) {
			//This is for the content assist...
			val sync = EcoreUtil2.getContainerOfType(context,Synchronization);
			if (sync?.bodies !== null && sync.bodies.size() > 0)
				syncbody = sync.bodies.get(0);
		}
		if (syncbody !== null) {
			val trigger = (syncbody.eContainer as Synchronization).trigger;
			val args = if (trigger !== null) EcoreUtil2.eAllOfType(trigger,NamedPar)
						else Collections.emptyList;
			val locVars = EcoreUtil2.eAllOfType(syncbody,LocVarDecl);
			return Iterables.concat(args,locVars);
		}
		//Inside a transition constraint body
		val tc = EcoreUtil2.getContainerOfType(context,TransConstraint);
		if (tc !== null) {
			val head = tc.head;
			val tcbody = tc.body;
			val args = if (head !== null) EcoreUtil2.eAllOfType(head,FormalPar)
						else Collections.emptyList;
			val locVars = EcoreUtil2.eAllOfType(tcbody,LocVarDecl);
			return Iterables.concat(args,locVars);
		}
		//Inside a init section
		val initSection = EcoreUtil2.getContainerOfType(context,InitSection);
		if (initSection !== null) {
			return EcoreUtil2.eAllOfType(initSection,LocVarDecl);
		}
		return null;
	}
	
	public static def dispatch boolean isConsumable(ResourceDecl decl) {
		if (decl?.body?.val2 !== null)
			return true;
		if (decl?.parent === null)
			return false;
		return isConsumable(decl?.parent);
	}
	
	public static def dispatch boolean isConsumable(AnonResDecl decl) {
		return decl?.body?.val2 !== null;
	}
	
	public static def dispatch boolean isConsumable(NamedCompDecl decl) {
		return isConsumable(decl.type);
	}
	
	public static def dispatch boolean isConsumable(ObjVarDecl decl) {
		return isConsumable(decl.type);
	}
	
	public static def dispatch boolean isConsumable(Object decl) { false }
	public static def dispatch boolean isConsumable(Void decl) { false }	
	
	public static def boolean isResource(Object obj) {
		return
		switch(obj) {
			ResourceDecl,
			AnonResDecl : true
			NamedCompDecl: obj?.type instanceof ResourceDecl
			ObjVarDecl: obj?.type instanceof ResourceDecl
			default: false
		}
	}
	
	private static def EObject getContainingResource(EObject obj) {
		var EObject cont = EcoreUtil2.getContainerOfType(obj,ResourceDecl);
		if (cont === null) cont = EcoreUtil2.getContainerOfType(obj,NamedCompDecl);
		if (cont === null) cont = EcoreUtil2.getContainerOfType(obj,AnonResDecl);
		return cont;
	}
	
	public static def boolean isInResource(EObject obj) {
		return isResource(getContainingResource(obj));
	}
	
	public static def boolean isInConsumable(EObject obj) {
		return isConsumable(getContainingResource(obj));
	}

	public static def dispatch ComponentType getParent(SvDecl decl) {
		return decl.parent;
	}

	public static def dispatch ComponentType getParent(ResourceDecl decl) {
		return decl.parent;
	}
	
	public static def dispatch ComponentType getParent(Object o) { null }
	public static def dispatch ComponentType getParent(Void o) { null }
	
	public static def boolean areTypesCompatible(ComponentType requestedType,
		ComponentType actualType) {
		//avoid errors on erroneous types 
		if (requestedType === null || actualType === null
			|| requestedType.eIsProxy || actualType.eIsProxy)
			return true;
		var t = actualType;
		while (t !== null && t !== requestedType)
			t = t.parent;
		return (t === requestedType); 
	}

	private static def contains(List<ObjVarDecl> vars, String name) {
		for (v : vars)
			if (v.name==name)
				return true;
		return false;
	}
	
	public static def List<ObjVarDecl> getVariables(ComponentType type) {
		if (type === null)
			return Collections.emptyList;
		val fromParent = getVariables(type.parent);
		val secs = 
		switch (type) {
			SvDecl: type.body?.variables
			ResourceDecl: type.body?.variables
			default : null
		}
		val fromThis = if (secs !== null) secs.map[sec|sec.values].flatten
			else Collections.emptyList();
		val result = new ArrayList(fromParent.size+fromThis.size);
		result.addAll(fromParent);
		result.addAll(fromThis.filter[v|!contains(fromParent,v.name)]);
		return result;
	}
	
	public static def getParentType(EObject o) {
		if (o === null)
			return null;
		//we are in a component with a type, find the type
		val comp = EcoreUtil2.getContainerOfType(o,NamedCompDecl);
		if (comp !== null && comp.type instanceof SvDecl)
			return comp.type
		else if (comp !== null && comp.type instanceof ResourceDecl)
			return comp.type
		else {
		//we are in a type, find the parent, if any
			val type = EcoreUtil2.getContainerOfType(o,SvDecl)?.parent;
			if (type !== null)
				return type;
			return EcoreUtil2.getContainerOfType(o,ResourceDecl)?.parent;
		}
	}	
	
	
	public static def getParentValue(ValueDecl o) {
		val name = o?.name;
		if (name === null || o === null)
			return null;
		val tmp = getParentType(o);
		if (! (tmp instanceof SvDecl))
			return null;
		var type = tmp as SvDecl;

		while (type !== null) {
			val parentVal = EcoreUtil2.eAllOfType(type,ValueDecl).filter[v|v.name==name].head;
			if (parentVal !== null) {
				//found the value we are inheriting from.
				return parentVal;
			}
			type = type.parent;
		}
		return null;			
	}
	
	public static def dispatch getParentSync(SimpleInstVal o) {
		val name = o?.value?.name;
		if (name === null || o === null)
			return null;
		var type = getParentType(o) as SvDecl;
			
		while (type !== null) {
			val parentSync = EcoreUtil2.eAllOfType(type,SimpleInstVal).filter[v|v?.value?.name==name].head;
			if (parentSync !== null) {
				//found the sync we are inheriting from.
				return parentSync;
			}
			type = type.parent;
		}
		return null;			
	}		
	
	public static def dispatch getParentSync(ResSimpleInstVal o) {
		val action = o?.type;
		if (action === null || o === null)
			return null;
		var type = getParentType(o) as ResourceDecl;

		while (type !== null) {
			val parentSync = EcoreUtil2.eAllOfType(type,ResSimpleInstVal).filter[v|v?.type==action].head;
			if (parentSync !== null) {
				//found the sync we are inheriting from.
				return parentSync;
			}
			type = type.parent;
		}
		return null;			
	}
	
	public static def boolean isUnspecified(ConstExpr o) {
		return (o === null) || (o instanceof ConstPlaceHolder);
	}
	
	public static def ConstExpr getVal1(ResourceDecl decl) {
		if (decl === null)
			return null;
		if (isUnspecified(decl.body?.val1))
			return getVal1(decl.parent);
		return decl.body.val1;
	}
	
	public static def ConstExpr getVal1(NamedCompDecl decl) {
		if (! (decl.body instanceof CompResBody))
			return getVal1(decl.type as ResourceDecl);
		val body = decl.body as CompResBody;
		if (isUnspecified(body?.val1))
			return getVal1(decl.type as ResourceDecl);
		return body?.val1;
	}
	
	public static def ConstExpr getVal2(ResourceDecl decl) {
		if (decl === null)
			return null;
		if (isUnspecified(decl.body?.val2))
			return getVal2(decl.parent);
		return decl.body.val2;
	}
	
	public static def ConstExpr getVal2(NamedCompDecl decl) {
		if (! (decl.body instanceof CompResBody))
			return getVal2(decl.type as ResourceDecl);
		val body = decl.body as CompResBody;
		if (isUnspecified(body?.val2))
			return getVal2(decl.type as ResourceDecl);
		return body?.val2;
	}	
	
}