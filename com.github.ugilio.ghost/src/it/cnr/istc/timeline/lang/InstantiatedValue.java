package it.cnr.istc.timeline.lang;

import java.util.List;

public interface InstantiatedValue {
	public Object getComponent();
	public Object getValue();
	public List<Object> getArguments();
	public boolean isThisSync();
}

