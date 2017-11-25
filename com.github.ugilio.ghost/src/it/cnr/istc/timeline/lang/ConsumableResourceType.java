package it.cnr.istc.timeline.lang;

public interface ConsumableResourceType extends ResourceType {
	public ConsumableResourceType getParent();
	public long getMin();
	public long getMax();
}
