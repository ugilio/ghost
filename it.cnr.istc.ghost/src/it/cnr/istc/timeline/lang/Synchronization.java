package it.cnr.istc.timeline.lang;

import java.util.List;

public interface Synchronization {
	public SyncTrigger getTrigger();
	public List<StatementBlock> getBodies();
}
