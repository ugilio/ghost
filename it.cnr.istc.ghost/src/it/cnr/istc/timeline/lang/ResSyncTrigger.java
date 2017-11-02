package it.cnr.istc.timeline.lang;

public interface ResSyncTrigger extends SyncTrigger {
	public ResourceAction getAction();
	public Parameter getArgument();
}
