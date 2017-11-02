package it.cnr.istc.timeline.lang;

public interface RenewableResourceType extends ResourceType {
	public RenewableResourceType getParent();
	public long getValue();
}
