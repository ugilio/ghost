/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.preprocessor

import org.eclipse.xtext.util.Strings
import org.eclipse.xtext.util.IResourceScopeCache
import com.google.inject.Inject
import org.eclipse.emf.ecore.resource.Resource
import com.google.inject.Provider
import com.google.inject.Singleton
import org.eclipse.xtext.conversion.ValueConverterException
import com.github.ugilio.ghost.preprocessor.DefinitionList
import com.github.ugilio.ghost.preprocessor.DefinitionList.DefinitionListException
import com.github.ugilio.ghost.preprocessor.DefinitionList.KeyNotFoundException
import com.github.ugilio.ghost.ghost.GhostFactory
import com.github.ugilio.ghost.conversion.NumAndUnitValueConverter
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import com.github.ugilio.ghost.ghost.Interval
import com.github.ugilio.ghost.ghost.Controllability
import com.github.ugilio.ghost.ghost.Externality

@Singleton
class DefaultsProvider {
	
	@Inject
	IResourceScopeCache cache;
	
	@Inject
	NumAndUnitValueConverter numConv;
	
	private def ResourceSpecificProvider getResourceSpecific(Resource resource) {
		cache.get("defaultsProvider",resource,new Provider<ResourceSpecificProvider>{
			override ResourceSpecificProvider get() {
				return new ResourceSpecificProvider(resource,numConv);
			}}
		);
	}
	
	public def Interval getDuration(Resource res, int offset) {
		getResourceSpecific(res).getDuration(offset);
	}

	public def boolean isExternal(Resource res, int offset) {
		getResourceSpecific(res).isExternal(offset);
	}

	public def Controllability getControllability(Resource res, int offset) {
		getResourceSpecific(res).getControllability(offset);
	}

	public def long getStart(Resource res, int offset) {
		getResourceSpecific(res).getStart(offset);
	}

	public def long getHorizon(Resource res, int offset) {
		getResourceSpecific(res).getHorizon(offset);
	}
	
	def addDefinition(Resource res, String key, String value, int offset) {
		getResourceSpecific(res).addDefinition(key,value,offset);
	}	
	
	public static class ResourceSpecificProvider extends DefinitionList<Object> {
		
		NumAndUnitValueConverter numConv;
		
		Resource resource;
		
		@Inject
		new(Resource resource, NumAndUnitValueConverter numConv) {
			super();
			this.resource = resource;
			this.numConv = numConv;

			addDefinition("duration", "[0, +INF]");
			addDefinition("planned", "");
			addDefinition("contr", "unknown");
			addDefinition("start", "0");
			addDefinition("horizon", "1000");
		}
		
		private def expected(String expected, String actual) {
			if (!Strings.equal(expected,actual))
				throw new DefaultsProviderException(String.format(
				"'%s' expected but '%s' found",expected,actual))
		}

		private def Object getValue(String aStr, int offset) {
			val str = aStr?.trim;
			if (Strings.isEmpty(str))
				throw new DefaultsProviderException("Input string cannot be empty");
			if (offset < 0)
				throw new DefaultsProviderException("Negative offset: " + offset);
			try {
				internalGetValue(str, offset)
			}
			catch (KeyNotFoundException e) {
				//not meaningful, it means null was stored
				return null;
			}
		}

		def addDefinition(String key, String value) {
			addDefinition(key, value, 0);
		}

		def addDefinition(String aKey, String aValue, int offset) {
			try
			{
				add(adjustKey(aKey),parseDefinition(aKey,aValue,offset),offset);
			}
			catch (DefinitionListException e)
			{
				throw new DefaultsProviderException(e.message);
			}
		}
		
		private def adjustKey(String key) {
			if ("external".equals(key?.trim))
				return "planned";
			return key;
		}
		
		protected def parseDefinition(String aKey, String aValue, int offset) {
			val parsed = 
			switch (aKey) {
				case "duration": parseInterval(aValue,offset)
				case "planned": parseExtPlanned(aKey,aValue)
				case "external": parseExtPlanned(aKey,aValue)
				case "contr": parseControllability(aValue)
				case "start": parseNumber(aValue,offset)
				case "horizon": parseNumber(aValue,offset)
				default : throw new DefaultsProviderException(
					String.format("Unknown $set directive: '%s'",aKey))
			}
			return parsed;
		}
		
		private def parseInterval(String str, int offset) {
			checkThereIsArg(str);
			val node = getNodeAt(offset);
			try {
				//try single number first
				val numVal = numConv.toValue(str,node);
				val intv = GhostFactory.eINSTANCE.createInterval();
				intv.lbub=GhostFactory.eINSTANCE.createNumAndUnit();
				intv.lbub.value = numVal;
				return intv;
			}
			catch (ValueConverterException e) {}
			//else try proper interval
			expected('[',""+str.charAt(0));
			var sep = str.indexOf(',');
			if (sep == -1) sep = str.indexOf(';');
			if (sep == -1)
				throw new DefaultsProviderException("Invalid format for interval constant");

			try {
				val lb = numConv.toValue(str.substring(1,sep),node);
				val lastPos = if (str.endsWith("]")) str.length-1 else str.length;
				var ub = numConv.toValue(str.substring(sep+1,lastPos),node);
				expected(']',""+str.charAt(str.length-1));
			
				val intv = GhostFactory.eINSTANCE.createInterval();
				intv.lb=GhostFactory.eINSTANCE.createNumAndUnit();
				intv.ub=GhostFactory.eINSTANCE.createNumAndUnit();
				intv.lb.value = lb;
				intv.ub.value = ub;
				return intv;
			}
			catch (ValueConverterException e) {
				throw new DefaultsProviderException(e.message);
			}
		}

		private def parseExtPlanned(String value,String extra) {
			checkThereIsArg(value);
			val retval = Externality.get(value);
			if (retval === null || retval.ordinal < Externality.PLANNED.ordinal)
				throw new DefaultsProviderException(
				String.format("Expected 'external' or 'planned' but '%s' found",value));
			if (!Strings.isEmpty(extra?.trim))
				throw new DefaultsProviderException("Extraneous input at the end of the directive");
			return retval;
		}
		
		private def parseControllability(String aValue) {
			checkThereIsArg(aValue);
			val value = aValue.trim;
			if ("unknown".equals(value))
				return Controllability.UNKNOWN;
			val retval = Controllability.get(value);
			if (retval === null || retval.ordinal<Controllability.CONTROLLABLE.ordinal)
				throw new DefaultsProviderException(
				String.format("Invalid controllability specifier: '%s'",value));
			return retval;
		}
		
		private def parseNumber(String value, int offset) {
			checkThereIsArg(value);
			try {
				return numConv.toValue(value,getNodeAt(offset));
			}
			catch (ValueConverterException e) {
				throw new DefaultsProviderException(e.message);
			}
		}
		
		private def getNodeAt(int offset) {
			if (resource === null)
				return null;
			val root = NodeModelUtils.getNode(resource.contents.get(0));
			if (root === null)
				return null;
			return NodeModelUtils.findLeafNodeAtOffset(root,offset);
		}
		
		private def checkThereIsArg(String value) {
			if (Strings.isEmpty(value?.trim))
				throw new DefaultsProviderException("Missing required argument in default definition");
		}
		
		public def Interval getDuration(int offset) {
			getValue("duration",offset) as Interval;
		}

		public def boolean isExternal(int offset) {
			(getValue("planned",offset) as Externality) == Externality.EXTERNAL;
		}

		public def Controllability getControllability(int offset) {
			getValue("contr",offset) as Controllability;
		}

		public def long getStart(int offset) {
			getValue("start",offset) as Long;
		}

		public def long getHorizon(int offset) {
			getValue("horizon",offset) as Long;
		}
	}
	
	static class DefaultsProviderException extends Exception{
		new (String message) {
			super(message);
		}
		
	}
	
}