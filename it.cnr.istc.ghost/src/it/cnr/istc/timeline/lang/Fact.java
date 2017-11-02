package it.cnr.istc.timeline.lang;

public interface Fact {
	public boolean isGoal();
	public InstantiatedValue getValue();
	public Interval getStart();
	public Interval getDuration();
	public Interval getEnd();
}
