/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.standalonecompiler;

import java.util.Collections;
import java.util.List;

public class GhostCOptions {
	public boolean help;
	public boolean version;
	public List<String> searchPaths = Collections.emptyList();
	public String outputPath = null;
	public List<String> fnames = Collections.emptyList();
}
