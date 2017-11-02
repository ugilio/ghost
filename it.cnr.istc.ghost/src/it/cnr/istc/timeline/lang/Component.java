package it.cnr.istc.timeline.lang;

import java.util.List;
import java.util.Map;

public interface Component {
	public String getName();
	public CompType getType();
	public List<ComponentReference> getVariableBindings();
	public Map<ComponentVariable, Component> getVariableMapping();
}
