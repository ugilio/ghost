/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package it.cnr.istc.ghost.preprocessor

import com.google.inject.Inject
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import java.util.Arrays
import it.cnr.istc.ghost.preprocessor.UnitProvider.UnitProviderException
import com.google.inject.Singleton
import it.cnr.istc.ghost.preprocessor.DefaultsProvider.DefaultsProviderException

@Singleton
class Preprocessor {
	
	@Inject
	UnitProvider unitProvider;
	
	@Inject
	DefaultsProvider defProvider;
	
	private def parseDefaultDef(INode node, String[] parts) {
		val res = NodeModelUtils.findActualSemanticObjectFor(node)?.eResource;
		if (parts.size<=1)
			throw new PreprocessorException("Missing argument to $set directive");
		val key = parts.get(1);
		val value = Arrays.copyOfRange(parts,2,parts.length).join(" ");
		try
		{
			defProvider.addDefinition(res,key,value,node.offset);
		}
		catch (DefaultsProviderException e) {
			throw new PreprocessorException(e.message);
		}
	}
	
	private def parseUnitDef(INode node, String[] parts) {
		val res = NodeModelUtils.findActualSemanticObjectFor(node)?.eResource;
		if (parts.size<=1)
			throw new PreprocessorException("Unit name expected");
		val unit = parts.get(1);
		val value = Arrays.copyOfRange(parts,2,parts.length).join(" ");
		try
		{
			unitProvider.addUnit(res,unit,value,node.offset);
		}
		catch (UnitProviderException e) {
			throw new PreprocessorException(e.message);
		}
	}
	
	def parse(INode node, String line) {
		val parts = line?.trim()?.split("\\s+");
		if (parts === null || parts.length == 0)
			return;
		try {
			switch (parts.get(0)) {
				case "$set" : parseDefaultDef(node,parts)
				case "$unit" : parseUnitDef(node,parts)
				default: throw new PreprocessorException(
					String.format("Unknown preprocessor directive: '%s'",parts.get(0)))
			}
		}
		catch (DefaultsProviderException e){
			throw new PreprocessorException(e.message);
		}
	}
	
	public static class PreprocessorException extends Exception {
		new(String message) {
			super(message);
		}
	}
}