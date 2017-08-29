package it.cnr.istc.ghost.conversion

import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.conversion.ValueConverterException
import org.eclipse.xtext.util.Strings
import org.eclipse.xtext.conversion.impl.AbstractValueConverter
import org.eclipse.xtext.conversion.IValueConverter
import org.eclipse.xtext.AbstractRule

class NumberValueConverter extends AbstractValueConverter<Long> implements IValueConverter.RuleSpecific {
	
	private long MAX_VALUE = Long.MAX_VALUE;
	private long MIN_VALUE = Long.MIN_VALUE;
	
	override toValue(String string, INode node) throws ValueConverterException {
		if (Strings.isEmpty(string))
			throw new ValueConverterException("Couldn't convert empty string to a long value.", node, null);
		val clean = string.replace(" ","").replace("_","");
		if ("INF".equals(clean))
			return MAX_VALUE
		else if ("+INF".equals(clean))
			return MAX_VALUE
		else if ("-INF".equals(clean))
			return MIN_VALUE;
		try {
			val value = Long.parseLong(clean);
			return Long.valueOf(value);
		}
		catch (NumberFormatException e) {
			throw new ValueConverterException("Couldn't convert '" + string + "' to a long value.", node, e);
		}
	}
	
	override toString(Long value) {
		return
		switch (value) {
			case MAX_VALUE: "+INF"
			case MIN_VALUE: "-INF"
			default: value.toString()
		}
	}
	
	override setRule(AbstractRule rule) throws IllegalArgumentException {
		
	}
	
}
