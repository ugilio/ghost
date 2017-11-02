package it.cnr.istc.timeline.lang;

import java.util.List;

public interface StatementBlock {
	public boolean inheritsFromParent();
	public List<Variable> getVariables();
	public List<Expression> getExpressions();
	public List<TemporalExpression> getTemporalExpressions();
}
