/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator.internal

import static extension com.github.ugilio.ghost.generator.internal.Utils.*;
import com.google.common.collect.Iterables
import com.github.ugilio.ghost.ghost.CompDecl
import com.github.ugilio.ghost.ghost.ComponentType
import com.github.ugilio.ghost.ghost.InheritedKwd
import it.cnr.istc.timeline.lang.CompType
import it.cnr.istc.timeline.lang.Component
import it.cnr.istc.timeline.lang.Expression
import it.cnr.istc.timeline.lang.Fact
import it.cnr.istc.timeline.lang.InitStatementBlock
import it.cnr.istc.timeline.lang.InstantiatedValue
import it.cnr.istc.timeline.lang.Parameter
import it.cnr.istc.timeline.lang.ResSyncTrigger
import it.cnr.istc.timeline.lang.ResourceAction
import it.cnr.istc.timeline.lang.SVSyncTrigger
import it.cnr.istc.timeline.lang.SVType
import it.cnr.istc.timeline.lang.StatementBlock
import it.cnr.istc.timeline.lang.Synchronization
import it.cnr.istc.timeline.lang.TemporalExpression
import it.cnr.istc.timeline.lang.TemporalOperator
import it.cnr.istc.timeline.lang.TimePointOperation
import it.cnr.istc.timeline.lang.TransitionConstraint
import it.cnr.istc.timeline.lang.Value
import it.cnr.istc.timeline.lang.Variable
import java.lang.reflect.Array
import java.util.ArrayList
import java.util.Collection
import java.util.Collections
import java.util.HashMap
import java.util.HashSet
import java.util.List

class BlockImpl extends ProxyObject implements StatementBlock, InitStatementBlock {
	
	//FIXME: factor this out
	public static boolean OPTIMIZE = true;
	
	private BlockAdapter block = null;
	private ExpressionCalculator calc = null;
	private boolean inherits = false;
	private LexicalScope scope;
	private List<Variable> vars;
	private List<Expression> exps;
	private List<TemporalExpression> tempExps;
	private List<Fact> facts;

	new(BlockAdapter theBlock, LexicalScope parentScope, Register register) {
		super(register);
		this.block = theBlock;
		this.scope = new LexicalScope(parentScope);
		this.calc = new ExpressionCalculator(this);
	}

	private def <T> void removeDuplicates(List<T> list) {
		for (var i = 0; i < list.size(); i++) {
			var left = list.get(i);
			for (var j = i+1; j < list.size(); j++)
				if (list.get(j) === left) {
					list.remove(j);
					j--;
				}
		}
	}
	
	private def build() {
		val size = block.getContents().size();
		vars = new ArrayList(size);
		exps = new ArrayList(size * 2);
		tempExps = new ArrayList(size * 2);
		facts = new ArrayList();

		for (e : block.getContents()) {
			val p = getProxy(e);
			switch (p) {
				Variable: vars.add(p)
				TemporalExpression: tempExps.add(p)
				Expression: exps.add(p)
				InstantiatedValue: wrapInstValueInExp(p)
				InheritedKwd: inherits = true
				Fact: facts.add(p)
				default: {} //ignore
			}
		}
	}

	private def wrapInstValueInExp(InstantiatedValue v) {
		val exp = switch (v.value) {
			ResourceAction: new TemporalExpressionImpl(null, TemporalOperator.EQUALS, v, register)
			default: {
				val tmp = new ExpressionImpl(null,register);
				tmp.left = v;
				tmp
			}
		}
		switch (exp) {
			TemporalExpression: tempExps.add(exp)
			Expression: exps.add(exp)
		}
		return exp;
	}

	private def toTempExp(Expression e) {
		val theOp = getTemporalOperator(e.operators.get(0));
		if (theOp === null)
			throw new IllegalArgumentException("Invalid operator: " + e.operators.get(0))
		return new TemporalExpressionImpl(e.operands.get(0), theOp, e.operands.get(1),register);
	}

	private def shouldBeTemporalExpression(Object o) {
		if (!(o instanceof Expression))
			return false;
		val e = (o as Expression);
		if (e?.operators !== null && e.operators.size == 1) {
			val r = e.operands.get(1);
			if (r instanceof Variable)
				if (r.getValue instanceof InstantiatedValue)
					return true;
			return ((r instanceof InstantiatedValue) || (r instanceof TimePointOperation));
		}
		return false;
	}

	private def convertExpsToTemporalExpressions() {
		val it = exps.iterator();
		while (it.hasNext()) {
			val e = it.next();
			if (shouldBeTemporalExpression(e)) {
				val tmpE = toTempExp(e);
				replaceProxy((e as ExpressionImpl).real, tmpE);
				tempExps.add(tmpE);
				it.remove();
			}
		}
	}

	private def removeUnusedVariables() {
	}

	private def addVariableNames() {
		for (v : vars) {
			if (scope.get(v.name) !== null) {
				// e.g name clash with an autogenerated sync trigger parameter name 
				val name = genName(v.name, scope);
				(v as VariableProxy).name = name;
			}
			scope.add(v.name, v);
		}
	}

	protected def getArgList() {
		val cont = getProxy(block.getContainer());
		return switch (cont) {
			TransitionConstraint:
				cont.head.formalParameters
			Synchronization:
				switch (cont.trigger) {
					SVSyncTrigger: (cont.trigger as SVSyncTrigger).getArguments()
					ResSyncTrigger: Collections.singletonList((cont.trigger as ResSyncTrigger).argument)
					default: Collections.emptyList
				}
		}
	}

	private def CompType getType() {
		val ct = block.getContainerOfType(ComponentType);
		if (ct !== null)
			return getProxy(ct) as CompType;
		val c = block.getContainerOfType(CompDecl);
		if (c !== null)
			return (getProxy(c) as Component).type;
		throw new IllegalArgumentException("Block not contained in a component or type: " + block);
	}

	private def StatementBlock getParentSync(CompType parentType, Synchronization cont) {
		return Utils.getParentSync(parentType,cont.trigger)?.bodies?.get(0);
	}

	private def StatementBlock getParentTC(SVType parentType, TransitionConstraint cont) {
		return Utils.getParentTC(parentType, cont)?.body;
	}

	private def StatementBlock getParentBlock() {
		val cont = getProxy(block.getContainer());
		val t = getType().parent;
		if (t === null)
			throw new IllegalArgumentException("Usage of 'inherited' without a parent type");
		return switch (cont) {
			TransitionConstraint: getParentTC(t as SVType, cont)
			Synchronization: getParentSync(t, cont)
			default: throw new IllegalArgumentException("Invalid container for a statement block: " + cont)
		}
	}

	private def void replaceArgsInArray(HashMap<Parameter, Parameter> paramMap, HashSet<Object> processed, Object o) {
		if (o === null || processed.contains(o))
			return;
		processed.add(o);
		val len = Array.getLength(o);
		for (var i = 0; i < len; i++) {
			val value = Array.get(o, i);
			if (value === null) {
			} else if (value instanceof Parameter) {
				val repl = paramMap.get(value);
				if (repl !== null)
					Array.set(o, i, repl);
			} else if (value.getClass().isArray()) {
				replaceArgsInArray(paramMap, processed, value);
			} else
				replaceArgs(paramMap, processed, value);
		}
	}
	
	private def void replaceArgs(HashMap<Parameter, Parameter> paramMap, HashSet<Object> processed, Object o) {
		if (o === null || processed.contains(o))
			return;
		// don't open this can of worms
		if (!(o instanceof Collection<?>) && !o.class.getName().startsWith(BlockImpl.package.name))
			return;
		processed.add(o);
		for (f : o.class.declaredFields) {
			f.setAccessible(true);
			val value = f.get(o);
			if (value === null) {
			} else if (value instanceof Parameter) {
				val repl = paramMap.get(value);
				if (repl !== null)
					f.set(o, repl);
			} else if (value.getClass().isArray()) {
				replaceArgsInArray(paramMap,processed,value);
			} else
				replaceArgs(paramMap, processed, value);
		}
	}

	private def void handleInherited() {
		if (!inherits)
			return;
		val pb = getParentBlock() as BlockImpl;

		// translate parent arguments to child ones: create parameter mapping
		val pl = pb.getArgList();
		val l = getArgList();
		val paramMap = new HashMap<Parameter, Parameter>(l.size());
		for (var i = 0; i < pl.size(); i++)
			paramMap.put(pl.get(i), l.get(i));

		// copy expressions
		val newVars = pb.variables.map[v|new VariableProxy(v.name, v.value)].toRegularList;
		val processed = new HashSet<Object>();
		val varMap = new HashMap<String, Variable>();
		newVars.forEach[v|varMap.put(v.name, v)];
		val copier = new ExpressionCopier(varMap);
		val newExps = pb.expressions.map[e|copier.copyOf(e) as Expression].toRegularList;
		val newTempExps = pb.temporalExpressions.map[e|copier.copyOf(e) as TemporalExpression].toRegularList;
		newVars.forEach[v|v.value = copier.copyOf(v.value)];

		// replace parameters with child ones
		for (e : Iterables.concat(newExps, newTempExps, newVars))
			replaceArgs(paramMap, processed, e);

		// add to this block, taking care of scopes and renaming if needed
		for (v : newVars) {
			if (scope.get(v.name) !== null) {
				v.name = genName(v.name, scope);
			}
			scope.add(v.name, v);
		}
		exps.addAll(newExps);
		tempExps.addAll(newTempExps);
		vars.addAll(newVars);
	}

	def process() {
		build();
		convertExpsToTemporalExpressions();
		removeUnusedVariables();
		addVariableNames();
		for (e : exps) {
			visit(e);
			simplify(e);
		}
		for (e : tempExps)
			visit(e);
		for (f : facts)
			visit(f);
		// new items might be added on tail...
		for (var i = 0; i < vars.length(); i++) {
			val theVar = vars.get(i); 
			visit(theVar.value);
			if (OPTIMIZE)
				(theVar as VariableProxy).value=simplify(theVar.value);
		}
		removeDuplicates(vars);
		
		if (OPTIMIZE)
			calc.handleDivisions();

		handleInherited();
	}

	protected def dispatch void visit(Expression e) {
		for (r : e.operands)
			visit(r);
	}

	protected def dispatch void visit(TemporalExpression e) {
		visit(e.left);
		visit(e.right);
		replaceOperands(e);
	}

	protected def dispatch void visit(InstantiatedValue iv) {
		addMissingArguments(iv);
		replaceArguments(iv);
	}

	protected def dispatch void visit(TimePointOperation op) {
		visit(op.instValue);
	}

	protected def dispatch void visit(Fact fact) {
		visit(fact.value);
	}

	protected def dispatch void visit(Object o) {}

	protected def dispatch void visit(Void o) {}

	def Object simplify(Object e) {
		if (OPTIMIZE)
			return calc.evaluate(e)
		else
			e;
	}

	private def newUnboundVariable(String baseName, Object value) {
		val tmpName = genName(baseName, scope);
		val v = new VariableProxy(tmpName, value);
		scope.add(tmpName, v);
		return v;
	}

	private def newVariable(String baseName, Object value) {
		val v = newUnboundVariable(baseName, value);
		vars.add(v);
		return v;
	}

	private def addMissingArguments(InstantiatedValue iv) {
		if (iv.isThisSync() && iv.arguments === null)
			(iv as InstantiatedValueImpl).arguments = new ArrayList(getArgList())
		else if (iv.value instanceof Value) {
			val value = iv.value as Value;
			val count = if(value?.formalParameters === null) 0 else value.formalParameters.size();
			if (iv.arguments === null || iv.arguments.size() < count)
				(iv as InstantiatedValueImpl).arguments = new ArrayList();

			for (var i = iv.arguments.size(); i < count; i++)
				iv.arguments.add(null);

			for (var i = 0; i < count; i++) {
				if (isUnnamed(iv.arguments.get(i))) {
					val origName = value?.formalParameters?.get(i)?.name;
					val v = newUnboundVariable(origName, null);
					iv.arguments.set(i, v);
				}
			}
		} else if (iv.value instanceof ResourceAction) {
			if (iv.arguments === null || iv.arguments.isEmpty()) {
				//cannot happen according to grammar?
				(iv as InstantiatedValueImpl).arguments = new ArrayList();
				iv.arguments.add(null);
			}
			if (isUnnamed(iv.arguments.get(0)))
				iv.arguments.set(0, newUnboundVariable("amount", null));
		}
	}

	private def replaceArguments(InstantiatedValue iv) {
		if (iv.arguments === null)
			return;
		for (var i = 0; i < iv.arguments.size(); i++) {
			val p = iv.arguments.get(i);
			val v = iv.value;
			val baseName = switch (v) {
				Value: v.formalParameters.get(i).name
				default: "amount"
			};
			switch (p) {
				Variable: {
				}
				default:
					iv.arguments.set(i, newVariable(baseName, p))
			}
		}
	}

	private def replaceOperands(TemporalExpression exp) {
		if (exp.left !== null && !(exp.left instanceof Variable))
			(exp as InternalTemporalExpression).left = newVariable("instval", exp.left);
		if (exp.right !== null && !(exp.right instanceof Variable))
			(exp as InternalTemporalExpression).right = newVariable("instval", exp.right);
	}

	override getVariables() {
		if (vars === null)
			process();
		return vars;
	}

	override getExpressions() {
		if (exps === null)
			process();
		return exps;
	}

	override getTemporalExpressions() {
		if (tempExps === null)
			process();
		return tempExps;
	}

	override getFacts() {
		if (facts === null)
			process();
		return facts;
	}

	override inheritsFromParent() {
		return inherits;
	}

}
