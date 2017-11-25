package it.cnr.istc.timeline.lang;

import java.util.List;

public interface SVType extends CompType {
	public SVType getParent();
	public List<Value> getDeclaredValues();
	public List<TransitionConstraint> getDeclaredTransitionConstraints();
	public List<Value> getValues();
	public List<TransitionConstraint> getTransitionConstraints();
}
