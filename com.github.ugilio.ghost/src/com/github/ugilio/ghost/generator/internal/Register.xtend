/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import com.google.inject.Inject
import com.github.ugilio.ghost.ghost.ArgList
import com.github.ugilio.ghost.ghost.BindList
import com.github.ugilio.ghost.ghost.BindPar
import com.github.ugilio.ghost.ghost.CompDecl
import com.github.ugilio.ghost.ghost.ConstDecl
import com.github.ugilio.ghost.ghost.EnumDecl
import com.github.ugilio.ghost.ghost.Expression
import com.github.ugilio.ghost.ghost.Externality
import com.github.ugilio.ghost.ghost.FactGoal
import com.github.ugilio.ghost.ghost.FormalPar
import com.github.ugilio.ghost.ghost.IntDecl
import com.github.ugilio.ghost.ghost.LocVarDecl
import com.github.ugilio.ghost.ghost.NameOnlyParList
import com.github.ugilio.ghost.ghost.NamedPar
import com.github.ugilio.ghost.ghost.NumAndUnit
import com.github.ugilio.ghost.ghost.ObjVarDecl
import com.github.ugilio.ghost.ghost.PlaceHolder
import com.github.ugilio.ghost.ghost.QualifInstVal
import com.github.ugilio.ghost.ghost.ResConstr
import com.github.ugilio.ghost.ghost.ResSimpleInstVal
import com.github.ugilio.ghost.ghost.ResourceDecl
import com.github.ugilio.ghost.ghost.SimpleInstVal
import com.github.ugilio.ghost.ghost.SvDecl
import com.github.ugilio.ghost.ghost.ThisKwd
import com.github.ugilio.ghost.ghost.TimePointOp
import com.github.ugilio.ghost.ghost.TransConstraint
import com.github.ugilio.ghost.ghost.ValueDecl
import com.github.ugilio.ghost.preprocessor.DefaultsProvider
import it.cnr.istc.timeline.lang.Component
import it.cnr.istc.timeline.lang.ComponentReference
import it.cnr.istc.timeline.lang.ComponentVariable
import it.cnr.istc.timeline.lang.Controllability
import it.cnr.istc.timeline.lang.EnumLiteral
import it.cnr.istc.timeline.lang.EnumType
import it.cnr.istc.timeline.lang.IntType
import it.cnr.istc.timeline.lang.Interval
import it.cnr.istc.timeline.lang.Parameter
import it.cnr.istc.timeline.lang.ResSyncTrigger
import it.cnr.istc.timeline.lang.ResourceAction
import it.cnr.istc.timeline.lang.ResourceType
import it.cnr.istc.timeline.lang.SVSyncTrigger
import it.cnr.istc.timeline.lang.SVType
import it.cnr.istc.timeline.lang.SimpleType
import it.cnr.istc.timeline.lang.SyncTrigger
import it.cnr.istc.timeline.lang.Synchronization
import it.cnr.istc.timeline.lang.TemporalOperator
import it.cnr.istc.timeline.lang.TimePointSelector
import it.cnr.istc.timeline.lang.TransitionConstraint
import it.cnr.istc.timeline.lang.Value
import it.cnr.istc.timeline.lang.Variable
import java.util.Collections
import java.util.HashMap
import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.nodemodel.util.NodeModelUtils

class Register {
	Map<Object,Object> proxies = new HashMap<Object,Object>();
	Map<String,TemporalOperator> tempOperatorsMap;
	LexicalScope globalScope = new LexicalScope(null);
	
	@Inject
	DefaultsProvider defProvider;

	public def getProxy(Object real) {
		if (real === null)
			return null;
		var proxy = proxies.get(real);
		if (proxy === null) {
			proxy = createProxy(real);
			proxies.put(real,proxy);
		}
		return proxy;
	}
	
	protected def replaceProxy(Object real, Object proxy) {
		proxies.put(real,proxy);
	} 
	
	protected def dispatch SVType createProxy(SvDecl real) {
		return new SVTypeProxy(real,this);
	}
	
	protected def dispatch ResourceType createProxy(ResourceDecl real) {
		if (Utils.isConsumable(real))
			return new ConsumableResourceTypeProxy(real,this)
		else
			return new RenewableResourceTypeProxy(real,this);
	}
	
	protected def dispatch IntType createProxy(IntDecl real) {
		return new IntTypeProxy(real,this);
	}
	
	protected def dispatch EnumType createProxy(EnumDecl real) {
		return new EnumTypeProxy(real,this);
	}
	
	protected def dispatch Component createProxy(CompDecl real) {
		return new ComponentProxy(real,this);
	}
	
	protected def dispatch TransitionConstraint createProxy(TransConstraint real) {
		return new TransitionConstraintProxy(real,this);
	}
	
	protected def dispatch List<Parameter> createProxy(NameOnlyParList real) {
		return if (real?.values !== null)
			real.values.
			map[v|getProxy(v) as Parameter]
		else Collections.emptyList();
	}
	
	protected def dispatch List<Object> createProxy(ArgList real) {
		return if (real?.values !== null)
			real.values.
			map[v|getProxy(v)]
		else Collections.emptyList();
	}
	
	protected def dispatch Synchronization createProxy(com.github.ugilio.ghost.ghost.Synchronization real) {
		return new SynchronizationProxy(real,this);
	}
	
	protected def dispatch ComponentVariable createProxy(ObjVarDecl real) {
		return new ComponentVariableProxy(real,this);
	}
	
	protected def dispatch ComponentReference createProxy(BindPar real) {
		return new ComponentReferenceProxy(real,this);
	}
	
	protected def dispatch List<ComponentReference> createProxy(BindList real) {
		return if (real?.values !== null)
			real.values.
			map[v|getProxy(v) as ComponentReference]
		else Collections.emptyList();
	}
	
	protected def dispatch Value createProxy(ValueDecl real) {
		return new ValueProxy(real,this);
	}
	
	protected def dispatch Parameter createProxy(FormalPar real) {
		return new ParameterImpl(real.name,getProxy(real.type) as SimpleType);
	}
	
	protected def dispatch Parameter createProxy(NamedPar real) {
		return new ParameterImpl(real.name,getProxy(real.type) as SimpleType);
	}
	
	protected def dispatch EnumLiteral createProxy(com.github.ugilio.ghost.ghost.EnumLiteral real) {
		return new EnumLiteralProxy(real,this);
	}
	
	protected def dispatch Controllability createProxy(com.github.ugilio.ghost.ghost.Controllability real) {
		return if (real==com.github.ugilio.ghost.ghost.Controllability.CONTROLLABLE)
				Controllability.CONTROLLABLE
			else if (real==com.github.ugilio.ghost.ghost.Controllability.UNCONTROLLABLE)
				Controllability.UNCONTROLLABLE
			else
				Controllability.UNKNOWN;
	}
	
	protected def dispatch ResourceAction createProxy(com.github.ugilio.ghost.ghost.ResourceAction real) {
		return if (real==com.github.ugilio.ghost.ghost.ResourceAction.REQUIRE)
				ResourceAction.REQUIRE
			else if (real==com.github.ugilio.ghost.ghost.ResourceAction.CONSUME)
				ResourceAction.CONSUME
			else
				if (real==com.github.ugilio.ghost.ghost.ResourceAction.PRODUCE)
				ResourceAction.PRODUCE;
	}
	
	protected def dispatch TimePointSelector createProxy(com.github.ugilio.ghost.ghost.TimePointSelector real) {
		return if (real==com.github.ugilio.ghost.ghost.TimePointSelector.START)
				TimePointSelector.START
			else if (real==com.github.ugilio.ghost.ghost.TimePointSelector.END)
				TimePointSelector.END;
	}
	
	protected def dispatch SyncTrigger createProxy(SimpleInstVal value) {
		return new SVSyncTriggerProxy(value,this);
	}
	
	protected def dispatch SyncTrigger createProxy(ResSimpleInstVal value) {
		return new ResSyncTriggerProxy(value,this);
	}
	
	protected def dispatch Object createProxy(Expression exp) {
		switch (exp) {
			//FIXME: implement me
			PlaceHolder : null
			default: if (exp.op === null) new ExpressionImpl(exp,this)
					else new TemporalExpressionImpl(exp,this) 
		}
	}
	
	protected def dispatch Object createProxy(ThisKwd exp) {
		val s = EcoreUtil2.getContainerOfType(exp,com.github.ugilio.ghost.ghost.Synchronization);
		val t = getProxy(s?.trigger);
		val value = 
		switch (t) {
			SVSyncTrigger: t.value
			ResSyncTrigger: t.action
		}
		val iv = new InstantiatedValueImpl(null,value,null);
		iv.thisSync = true;
		return iv;
	}

	protected def dispatch Long createProxy(NumAndUnit num) {
		return num.value;
	}
	
	protected def dispatch Interval createProxy(com.github.ugilio.ghost.ghost.Interval real) {
		return new IntervalProxy(real,this);
	}
	
	protected def dispatch Object createProxy(QualifInstVal real) {
		if (real.value instanceof ValueDecl)
			return new InstantiatedValueImpl(
				getProxy(real.comp),
				getProxy(real.value) as Value,
				getProxy(real.arglist) as List<Object>);
		return getProxy(real.value);
	}
	
	protected def dispatch Object createProxy(FactGoal real) {
		return new FactProxy(real,this);
	}
	
	protected def dispatch Object createProxy(ResConstr real) {
			return new InstantiatedValueImpl(
				getProxy(real.res),
				getProxy(real.type),
				Collections.singletonList(getProxy(real.amount)));
	}
	
	protected def dispatch Object createProxy(TimePointOp real) {
		return new TimePointOperationProxy(real,this);
	}
	
	protected def dispatch Object createProxy(ConstDecl real) {
		val value = real?.value?.computed;
		switch(value) {
			Long: return value
			default: return null //includes ConstPlaceHolder
		}
	}
	
	protected def dispatch Variable createProxy(LocVarDecl real) {
		return new VariableProxy(real,this);
	}
	
	protected def dispatch Object createProxy(Object real) {
		return real;
	}
	
	protected def dispatch Object createProxy(Void real) {
		return null;
	}
		
	protected def Interval getDefaultInterval(EObject obj) {
		val node = NodeModelUtils.getNode(obj);
		return getProxy(defProvider.getDuration(obj.eResource,node.offset)) as Interval;
	}
	
	protected def Externality getDefaultExternality(EObject obj) {
		val node = NodeModelUtils.getNode(obj);
		val ext = defProvider.isExternal(obj.eResource,node.offset);
		return if (ext) Externality.EXTERNAL else Externality.PLANNED;
	}

	protected def Controllability getDefaultControllability(EObject obj) {
		val node = NodeModelUtils.getNode(obj);
		val contr = defProvider.getControllability(obj.eResource,node.offset);
		return getProxy(contr) as Controllability;
	}
	
	protected def TemporalOperator getTemporalOperator(String name) {
		if (tempOperatorsMap === null) {
			val map = new HashMap<String,TemporalOperator>();
			map.put('=',TemporalOperator.EQUALS);
			map.put('equals',TemporalOperator.EQUALS);
			map.put('|=',TemporalOperator.MEETS);
			map.put('meets',TemporalOperator.MEETS);
			map.put('starts',TemporalOperator.STARTS);
			map.put('finishes',TemporalOperator.FINISHES);
			map.put('<',TemporalOperator.BEFORE);
			map.put('before',TemporalOperator.BEFORE);
			map.put('>',TemporalOperator.AFTER);
			map.put('after',TemporalOperator.AFTER);
			map.put('contains',TemporalOperator.CONTAINS);
			map.put('during',TemporalOperator.DURING);
			tempOperatorsMap = map;
		}
		return tempOperatorsMap.get(name);
	}
	
	public def LexicalScope getGlobalScope() {
		return globalScope;
	}	
}