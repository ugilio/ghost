/*
 * Copyright (c) 2017 PST (http://istc.cnr.it/group/pst).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *   Giulio Bernardi
 */
package it.cnr.istc.timeline.lang;

public interface TemporalExpression extends Expression {
	public Object getLeft();
	public TemporalOperator getOperator();
	public Interval getIntv1();
	public Interval getIntv2();
	public Object getRight();
}
