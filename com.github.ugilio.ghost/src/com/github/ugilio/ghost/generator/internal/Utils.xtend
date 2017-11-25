/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import java.util.Collection
import java.util.ArrayList
import com.google.common.collect.Lists
import java.util.List
import com.github.ugilio.ghost.ghost.CompDecl
import com.github.ugilio.ghost.ghost.AnonSVDecl
import com.github.ugilio.ghost.ghost.AnonResDecl
import com.github.ugilio.ghost.ghost.NamedCompDecl
import com.github.ugilio.ghost.ghost.CompSVBody
import it.cnr.istc.timeline.lang.CompType
import com.github.ugilio.ghost.ghost.CompResBody
import java.util.HashMap
import java.util.function.Function
import it.cnr.istc.timeline.lang.Interval
import com.github.ugilio.ghost.conversion.NumberValueConverter
import com.github.ugilio.ghost.ghost.ResourceDecl
import com.github.ugilio.ghost.ghost.Externality
import com.github.ugilio.ghost.ghost.SvDecl

public class Utils {
	public static def <T> List<T> toRegularList(Iterable<T> it) {
		if (it === null) return new ArrayList();
		
		return switch (it) {
			Collection<T>: new ArrayList<T>(it)
			default: Lists.newArrayList(it)
		}
	}
	
	protected static def <T> List<T> retainRedef(List<T> list, Function<T,String> getName) {
		val newList = new ArrayList(list);
		val map = new HashMap<String,T>();
		list.forEach[e|
			val name = getName.apply(e);
			val old = map.put(name,e);
			if (old !== null) {
				newList.remove(e);
				val idx = newList.indexOf(old);
				newList.set(idx,e);
			}
		]
		return newList;
	}

	protected static def boolean isUnnamed(Object name) {
		return (name === null || "_" == name);
	}
	
	protected static def boolean isConsumable(ResourceDecl res) {
		if (res?.body?.val2!==null)
			return true;
		if (res?.parent===null)
			return false;
		return isConsumable(res.parent);
	}
	
	protected static def boolean isConsumable(CompResBody body) {
		if (body?.val2!==null)
			return true;
		return false;
	}
	
	public static def boolean needsSyntheticType(CompDecl decl) {
		return switch (decl) {
			AnonSVDecl:
				true
			AnonResDecl:
				true
			NamedCompDecl: {
				if (decl.externality != Externality.UNSPECIFIED)
					return true;
				val body = decl?.body;
				if (body?.synchronizations !== null && body.synchronizations.size() > 0)
					return true;
				switch (body) {
					CompSVBody:
						return (body.transitions !== null && body.transitions.size() > 0)
					CompResBody:
						return (body.val1 !== null || body.val2 !== null)
					default:
						false
				}
			}
			default:
				false
		}
	}

	protected static def CompType createSyntheticType(CompDecl decl, Register register) {
		switch (decl) {
			AnonSVDecl:
				return new SVTypeProxy(decl, register)
			AnonResDecl:
				return if (isConsumable(decl.body))
					new ConsumableResourceTypeProxy(decl,register)
				else
					new RenewableResourceTypeProxy(decl,register)
			NamedCompDecl: {
				val type = decl?.type;
				switch (type) {
					SvDecl:
						return new SVTypeProxy(decl,register)
					ResourceDecl:
						return if (isConsumable(type))
							new ConsumableResourceTypeProxy(decl,register)
						else
							new RenewableResourceTypeProxy(decl,register)
				}
			}
		}
		throw new IllegalArgumentException("Cannot create synthetic type for " + decl);
	}

	def static genName(String suggestion, LexicalScope scope) {
		return genName(suggestion, scope, true);
	}

	def static genName(String suggestion, LexicalScope scope, boolean alwaysNumber) {
		var base = if (suggestion === null || suggestion.length==0) "unnamed" else suggestion;
		if (base.matches("^\\D.*\\d+$"))
			base=base.replaceFirst("\\d+$","");
		if (!alwaysNumber && scope.get(base) === null)
			return base;
		var cnt = 1;
		while (scope.get(base+cnt) !== null)
			cnt++;
		return base+cnt;
	}
	
	public static final Interval ZeroInterval = new IntervalImpl(0,0);
	public static final Interval ZeroInfInterval = new IntervalImpl(0,NumberValueConverter.MAX_VALUE);
	public static final Interval OneInfInterval = new IntervalImpl(1,NumberValueConverter.MAX_VALUE);
}