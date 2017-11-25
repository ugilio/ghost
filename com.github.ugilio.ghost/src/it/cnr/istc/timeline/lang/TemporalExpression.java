package it.cnr.istc.timeline.lang;

public interface TemporalExpression extends Expression {
	public Object getLeft();
	public TemporalOperator getOperator();
	public Interval getIntv1();
	public Interval getIntv2();
	public Object getRight();
}
