package it.cnr.istc.timeline.lang;

import java.util.List;

public interface SVSyncTrigger extends SyncTrigger {
	public Value getValue();
	public List<Parameter> getArguments();
}
