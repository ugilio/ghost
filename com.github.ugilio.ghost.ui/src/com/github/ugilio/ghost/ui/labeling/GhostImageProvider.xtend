/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.ui.labeling

import java.util.concurrent.ConcurrentHashMap
import org.eclipse.emf.ecore.EClass
import com.github.ugilio.ghost.ghost.GhostPackage
import org.eclipse.emf.ecore.EObject

class GhostImageProvider {
	private ConcurrentHashMap<EClass,String> icons;
	
	def image(EObject obj) {
		return image(obj.eClass);
	}
	
	def image(EClass cls) {
		var icon = icons.get(cls);
		if (icon===null)
			icon=handleSuperType(cls);
		if ("".equals(icon))
			icon=null;
		return icon;
	}
	
	private def handleSuperType(EClass cls) {
		val sup = cls.getESuperTypes();
		for (st : sup)
			if (icons.containsKey(st))
			{
				val ic = icons.get(st);
				icons.put(cls,ic);
				return ic;
			}
		//Avoid looking up superclasses each time if this icon does not exist
		icons.put(cls,"");
		return null;
	}
	
	new() {
		icons=new ConcurrentHashMap(30);
		icons.put(GhostPackage.Literals.GHOST,"ghost_file.png");
		icons.put(GhostPackage.Literals.DOMAIN_DECL,"domain.png");
		icons.put(GhostPackage.Literals.PROBLEM_DECL,"problem.png");
		
		icons.put(GhostPackage.Literals.IMPORT_DECL,"imp_obj.png");
		
		icons.put(GhostPackage.Literals.INT_DECL,"interval.png");
		icons.put(GhostPackage.Literals.ENUM_DECL,"enum_obj.png");
		icons.put(GhostPackage.Literals.SV_DECL,"statevariable.png");
		icons.put(GhostPackage.Literals.RESOURCE_DECL,"resource.png");

		icons.put(GhostPackage.Literals.CONST_DECL,"constant.png");
		
		icons.put(GhostPackage.Literals.COMP_DECL,"class_obj.png");
		
		icons.put(GhostPackage.Literals.ENUM_LITERAL,"enumliteral.png");
		icons.put(GhostPackage.Literals.TRANS_CONSTRAINT,"transconstr.png");
		icons.put(GhostPackage.Literals.SYNCHRONIZATION,"synchro.png");
		icons.put(GhostPackage.Literals.OBJ_VAR_DECL,"compvar.png");
		
		icons.put(GhostPackage.Literals.INIT_SECTION,"init.png");
		
		icons.put(GhostPackage.Literals.VALUE_DECL,"transconstr.png");
		icons.put(GhostPackage.Literals.LOC_VAR_DECL,"localvariable_obj.png");
		icons.put(GhostPackage.Literals.FORMAL_PAR,"localvariable_obj.png");
		icons.put(GhostPackage.Literals.NAMED_PAR,"localvariable_obj.png");
		
	}	
}