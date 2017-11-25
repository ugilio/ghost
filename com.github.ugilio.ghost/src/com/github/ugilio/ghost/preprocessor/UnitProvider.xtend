/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.preprocessor

import static com.github.ugilio.ghost.utils.ArithUtils.*;

import org.eclipse.xtext.util.Strings
import java.util.Set
import java.util.HashSet
import org.eclipse.xtext.util.IResourceScopeCache
import com.google.inject.Inject
import org.eclipse.emf.ecore.resource.Resource
import com.google.inject.Provider
import com.google.inject.Singleton
import org.eclipse.xtext.conversion.ValueConverterException
import com.github.ugilio.ghost.preprocessor.DefinitionList
import com.github.ugilio.ghost.preprocessor.DefinitionList.DefinitionListException
import com.github.ugilio.ghost.preprocessor.DefinitionList.KeyNotFoundException
import com.github.ugilio.ghost.conversion.NumberValueConverter

@Singleton
class UnitProvider {
	
	@Inject
	IResourceScopeCache cache;
	
	@Inject
	NumberValueConverter numConv;
	
	private def ResourceSpecificProvider getResourceSpecific(Resource resource) {
		cache.get("unitProvider",resource,new Provider<ResourceSpecificProvider>{
			override ResourceSpecificProvider get() {
				return new ResourceSpecificProvider(numConv);
			}}
		);
	}
	
	def long getValue(Resource res, String unit, int offset) {
		getResourceSpecific(res).getValue(unit, offset);
	}
	
	def addUnit(Resource res, String unit, String value, int offset) {
		getResourceSpecific(res).addUnit(unit,value,offset);
	}	
	
	public static class ResourceSpecificProvider extends DefinitionList<String> {
		
		NumberValueConverter numConv;

		@Inject
		new(NumberValueConverter numConv) {
			super();
			this.numConv = numConv;

			addUnit("ms", "1");
			addUnit("sec", "1000 ms");
			addUnit("min", "60 sec");
			addUnit("hrs", "60 min");
			addUnit("days", "24 hrs");

			addUnit("s", "1 sec");
			addUnit("m", "1 min");
			addUnit("h", "1 hrs");
			addUnit("hours", "1 hrs");
			addUnit("d", "1 days");
		}

		def long getValue(String str) {
			return getValue(str, 0);
		}

		def long getValue(String aStr, int offset) {
			val str = aStr?.trim;
			if (Strings.isEmpty(str))
				throw new UnitProviderException("Input string cannot be empty");
			if (offset < 0)
				throw new UnitProviderException("Negative offset: " + offset);
			return expand(str, offset, new HashSet<String>());
		}

		def addUnit(String unit, String value) {
			addUnit(unit, value, 0);
		}

		def addUnit(String aUnit, String aValue, int offset) {
			if (Strings.isEmpty(aUnit?.trim))
				throw new UnitProviderException("Unit cannot be empty");
			try
			{
				var value = aValue?.trim;
				if (Strings.isEmpty(value)) value = null;
				add(aUnit,value,offset);
			}
			catch (DefinitionListException e)
			{
				throw new UnitProviderException(e.message);
			}
		}

		private def isUnary(String s) {
			"+".equals(s) || '-'.equals(s);
		}
		
		private def boolean hasUnit(String[] segs) {
			if (segs.length <= 1)
				return false;
			if (segs.length == 2 && isUnary(segs.get(0)))
				return false;
			return true;
		}

		private def Long expand(String string, int offset, Set<String> processing) {
			var segs = string.split("\\s");
			try {
			if (hasUnit(segs)) {
				val unit = segs.get(segs.length-1);
				if (processing.contains(unit))
					throw new UnitProviderException(String.format("Recursive unit definition: '%s'", unit));
				processing.add(unit);
				val multFactor = expand(internalGetValue(unit, offset), offset, processing);
				val number = string.substring(0,string.length-unit.length);
				processing.remove(unit);
				return mul(multFactor , numConv.toValue(number,null));
			}
			return numConv.toValue(string,null);
			}
			catch (ValueConverterException e) {
				throw new UnitProviderException(String.format(
				"Invalid number while expanding unit definition '%s'",string));
			}
			catch (KeyNotFoundException e) {
				throw new UnitProviderException(String.format("Undefined unit: '%s'", e.key));
			}
		}
	}
	
	static class UnitProviderException extends Exception{
		new (String message) {
			super(message);
		}
		
	}
	
}