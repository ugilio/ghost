/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.validation;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

public class AbstractExpressionValidator {
	
	public static enum ResultType {
		UNKNOWN("unknown"),
		NUMERIC("numeric"),
		ENUM("enum"),
		BOOLEAN("boolean"),
		//"complex types"
		INSTVAL("instantiated value"),
		TIMEPOINT("temporal point"),
		TEMPORALEXP("temporal expression");
		
		private String desc;
		
		private ResultType(String desc) {
			this.desc = desc;
		}
		
		public String getDescription() {
			return desc;
		}
	}
	
	@FunctionalInterface
	public interface ErrMsgFunction {
		public void error(String message, EObject source, EStructuralFeature feature, int index, String code,
				String... issueData);
	}
	
	@FunctionalInterface
	public interface WarnMsgFunction {
		public void warning(String message, EObject source, EStructuralFeature feature, int index, String code,
				String... issueData);
	}
}
