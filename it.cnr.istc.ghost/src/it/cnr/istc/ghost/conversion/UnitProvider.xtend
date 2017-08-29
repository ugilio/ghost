package it.cnr.istc.ghost.conversion

import static it.cnr.istc.ghost.utils.ArithUtils.*;

import org.eclipse.xtext.util.Tuples
import org.eclipse.xtext.util.Triple
import java.util.List
import java.util.ArrayList
import org.eclipse.xtext.util.Strings
import java.util.Set
import java.util.HashSet
import org.eclipse.xtext.util.IResourceScopeCache
import com.google.inject.Inject
import org.eclipse.emf.ecore.resource.Resource
import com.google.inject.Provider
import com.google.inject.Singleton
import org.eclipse.xtext.conversion.ValueConverterException

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
	
	public static class ResourceSpecificProvider {
		
		private List<Triple<Integer, String, String>> units;
		
		NumberValueConverter numConv;

		@Inject
		new(NumberValueConverter numConv) {
			this.numConv = numConv;
			units = new ArrayList(256);

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
			val unit = aUnit?.trim;
			val value = aValue?.trim;
			if (Strings.isEmpty(unit))
				throw new UnitProviderException("Unit cannot be empty");
			if (offset < 0)
				throw new UnitProviderException("Negative offset: " + offset);
			val element = Tuples.create(offset, unit, value);
			// Typical case when parsing top to bottom: always add at the end 
			if (units.size == 0 || units.last.first <= offset) {
				units.add(element);
				return;
			}
			var pos = indexOf(offset, unit);
			if (pos >= 0) {
				units.set(pos, element);
				return;
			}
			pos = -pos - 1;
			units.add(pos, element);
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
		}

		private def String internalGetValue(String unit, int offset) {
			if (units.size>0) {
				var pos = indexOf(offset, unit);
				if (pos < 0)
					pos = -pos - 1 - 1;
				while (pos >= 0) {
					if (unit.equals(units.get(pos).second)) {
						val value = units.get(pos).third;
						if (Strings.isEmpty(value))
							//explicitly undefined 
							throw new UnitProviderException(String.format("Undefined unit: '%s'", unit));
						return value;
					}
					pos--;
				}
			}
			throw new UnitProviderException(String.format("Undefined unit: '%s'", unit));
		}

		private def int indexOf(int offset, String unit) {
			var l = 0;
			var r = units.size;
			while (l < r) {
				var m = (l + r) / 2;
				val mOfs = units.get(m).first;
				if (mOfs < offset)
					l = m + 1
				else if (mOfs > offset)
					r = m
				else {
					while (m > 0 && units.get(m - 1).first == offset)
						m--;
					while (m < units.size && units.get(m).first == offset) {
						if (unit.equals(units.get(m).second))
							return m;
						m++;
					}
					// else insert here
					return -m - 1;
				}
			}
			// insert here
			return -l - 1;
		}
	}
	
	static class UnitProviderException extends Exception{
		new (String message) {
			super(message);
		}
		
	}
	
}