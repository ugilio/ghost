package it.cnr.istc.timeline.lang;

import java.util.List;

public interface CompType extends Type {
	public CompType getParent();
	public boolean isExternal();
	public List<Synchronization> getDeclaredSynchronizations();
	public List<ComponentVariable> getDeclaredVariables();
	public List<Synchronization> getSynchronizations();
	public List<ComponentVariable> getVariables();
}
	
