package it.cnr.istc.ghost.conversion

import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.conversion.ValueConverterException
import org.eclipse.xtext.conversion.impl.AbstractValueConverter
import org.eclipse.xtext.conversion.IValueConverter
import org.eclipse.xtext.AbstractRule
import com.google.inject.Inject
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import it.cnr.istc.ghost.conversion.UnitProvider.UnitProviderException

class NumAndUnitValueConverter extends AbstractValueConverter<Long> implements IValueConverter.RuleSpecific {
	
	@Inject
	UnitProvider unitProvider;
	@Inject
	NumberValueConverter numberConverter;
	
	
	override toValue(String string, INode node) throws ValueConverterException {
		try
		{
			val res = NodeModelUtils.findActualSemanticObjectFor(node).eResource;
			val offset = if (node!==null) node.offset else 0;
			unitProvider.getValue(res,string,offset);
		}
		catch (UnitProviderException e)
		{
			throw new ValueConverterException(e.message, node, e);
		}
	}
	
	override toString(Long value) {
		return numberConverter.toString(value);
	}
	
	override setRule(AbstractRule rule) throws IllegalArgumentException {
		
	}
	
}
