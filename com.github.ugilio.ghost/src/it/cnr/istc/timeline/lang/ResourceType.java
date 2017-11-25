package it.cnr.istc.timeline.lang;

public interface ResourceType extends CompType {
	public ResourceType getParent();
	public boolean isConsumable();
	public boolean isRenewable();
}
