/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package it.cnr.istc.ghost.conversion

import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.conversion.ValueConverterException
import org.eclipse.xtext.util.Strings
import org.eclipse.xtext.conversion.impl.AbstractValueConverter
import org.eclipse.xtext.conversion.IValueConverter
import org.eclipse.xtext.AbstractRule

class NumberValueConverter extends AbstractValueConverter<Long> implements IValueConverter.RuleSpecific {
	
	public static long MAX_VALUE = Long.MAX_VALUE;
	public static long MIN_VALUE = Long.MIN_VALUE;
	
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
