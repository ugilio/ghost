/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * generated by Xtext 2.12.0
 */
package com.github.ugilio.ghost

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.IResourceServiceProvider

/**
 * Initialization support for running Xtext languages without Equinox extension registry.
 */
class GhostStandaloneSetup extends GhostStandaloneSetupGenerated {

	def static void doSetup() {
		new GhostStandaloneSetup().createInjectorAndDoEMFRegistration()
	}
	
	override createInjectorAndDoEMFRegistration() {
		val injector = super.createInjectorAndDoEMFRegistration();
		
		val resourceFactory = Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().get("ghost");
		val serviceProvider = IResourceServiceProvider.Registry.INSTANCE.getExtensionToFactoryMap().get("ghost");

		Resource.Factory.Registry.INSTANCE.getContentTypeToFactoryMap().put("ghost", resourceFactory);
		IResourceServiceProvider.Registry.INSTANCE.getContentTypeToFactoryMap().put("ghost", serviceProvider);
		
		return injector;
	}
}