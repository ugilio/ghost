package it.cnr.istc.timeline.lang;

import java.util.List;

public interface EnumType extends SimpleType {
	public List<EnumLiteral> getValues();
}
