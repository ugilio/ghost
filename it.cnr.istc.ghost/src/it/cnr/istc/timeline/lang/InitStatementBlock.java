package it.cnr.istc.timeline.lang;

import java.util.List;

public interface InitStatementBlock {
	public List<Variable> getVariables();
	public List<Expression> getExpressions();
	public List<Fact> getFacts();
}

