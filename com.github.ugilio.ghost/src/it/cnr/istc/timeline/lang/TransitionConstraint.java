package it.cnr.istc.timeline.lang;

public interface TransitionConstraint {
	public Interval getInterval();
	public Value getHead();
	public Controllability getControllability();
	public StatementBlock getBody();
}
