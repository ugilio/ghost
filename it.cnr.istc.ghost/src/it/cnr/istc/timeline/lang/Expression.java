package it.cnr.istc.timeline.lang;

import java.util.List;

public interface Expression {
	public List<String> getOperators();
	public List<Object> getOperands();
}

