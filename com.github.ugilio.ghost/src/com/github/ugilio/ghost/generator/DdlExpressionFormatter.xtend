/*
 * Copyright (c) 2017 Giulio Bernardi (https://github.com/ugilio/).
 * All rights reserved.   This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.github.ugilio.ghost.generator

import it.cnr.istc.timeline.lang.Component
import it.cnr.istc.timeline.lang.ComponentVariable
import it.cnr.istc.timeline.lang.EnumLiteral
import it.cnr.istc.timeline.lang.Expression
import it.cnr.istc.timeline.lang.Fact
import it.cnr.istc.timeline.lang.InstantiatedValue
import it.cnr.istc.timeline.lang.Interval
import it.cnr.istc.timeline.lang.Parameter
import it.cnr.istc.timeline.lang.ResourceAction
import it.cnr.istc.timeline.lang.TimePointOperation
import it.cnr.istc.timeline.lang.Value
import it.cnr.istc.timeline.lang.Variable
import com.google.inject.Inject
import com.github.ugilio.ghost.conversion.NumberValueConverter
import com.github.ugilio.ghost.generator.internal.Utils

class DdlExpressionFormatter {
	
	@Inject
	NumberValueConverter numConv;
	
	protected def formatInterval(Interval intv) {
		val i = if (intv === null) Utils.ZeroInterval else intv;
		val lb = numConv.toString(i.lb);
		val ub = numConv.toString(i.ub);
		
		return '''[«lb», «ub»]''';
	}
	
	protected def formatResourceAction(ResourceAction action) {
		return
		switch (action) {
			case REQUIRE : "REQUIREMENT"
			case PRODUCE : "PRODUCTION"
			case CONSUME : "CONSUMPTION"
		}
	}
	
	protected def boolean isInstCompVariable(Variable v) {
		return (v.getValue instanceof InstantiatedValue) || (v.getValue instanceof TimePointOperation);
	}
	
	private def int getOpDegree(String op) {
		return
		switch (op) {
			case '*', case '/', case '%': 1
			case '+', case '-': 2
			case '<', case '<=', case '>', case '>=' : 3
			case '=', case '!=' : 4
			default: 0
		}
	}
	
	private def getExpDegree(Object exp) {
		switch (exp) {
			Expression: if (exp.operators.size()>0) return getOpDegree(exp.operators.get(0))
		}
		return 0;
	}
	
	public def dispatch String formatExpression(Expression e, Component comp) {
		var str = "";
		for (var i = 0; i < e.operands.size(); i++) {
			val sub = e.operands.get(i);
			var subStr = formatExpression(sub,comp);
			if (sub instanceof Expression && e.operators.size()>0) {
				val op = e.operators.get(0);
				val needParens = getOpDegree(op) <= getExpDegree(sub);
				if (needParens) subStr = "("+subStr+")";	
			}
			str+=subStr;
			if (i < e.operators.size())
				str+= " "+e.operators.get(i)+" ";
		}
		
		return str.trim();
	}
	
	public def dispatch String formatExpression(Long l, Component comp) {
		if (l == Long.MAX_VALUE) return "INF"
		else if (l == Long.MIN_VALUE) return "-INF"
		else return ""+l; 
	}
	
	public def dispatch String formatExpression(Variable v, Component comp) {
		return if (isInstCompVariable(v)) v.name else "?"+v.name;
	}
	
	public def dispatch String formatExpression(Parameter p, Component comp) {
		return "?"+p.name;
	}
	
	public def dispatch String formatExpression(EnumLiteral l, Component comp) {
		return l.name;
	}
	
	private def Component resolveComponent(Object obj, Component context) {
		return
		switch (obj) {
			Component: obj
			ComponentVariable: if (context !== null) context.getVariableMapping.get(obj) else null
			default: null
		}
	}
	
	public def dispatch String formatExpression(InstantiatedValue iv, Component comp) {
		val c = resolveComponent(iv?.component,comp);
		var s = if (c !== null) c.name+".timeline." else "";
		var value = 
		switch (iv.value) {
			Value: (iv.value as Value).name
			ResourceAction: formatResourceAction(iv.value as ResourceAction)
			default: ""+iv.value
		}
		s+=value+"(";
		if (iv.arguments !== null)
			s+=iv.arguments.map[a|formatExpression(a,comp)].join(", ")
		s+=")";
		return s;
	}
	
	public def dispatch String formatExpression(TimePointOperation op, Component comp) {
		return formatExpression(op.getInstValue(),comp);
	}
	
	public def dispatch String formatExpression(Fact fact, Component comp) {
		val type = if (fact.isGoal()) "<goal>" else "<fact>";
		val instval = formatExpression(fact.value,comp);
		val at = String.format("AT %s %s %s",
			formatInterval(fact.start),
			formatInterval(fact.duration),
			formatInterval(fact.end));
		return String.format("%s %s %s",type,instval,at);
	}
	
	public def dispatch String formatExpression(Object e, Component comp) { "<ERROR:>"+e}
	public def dispatch String formatExpression(Void e, Component comp) { ""}

}