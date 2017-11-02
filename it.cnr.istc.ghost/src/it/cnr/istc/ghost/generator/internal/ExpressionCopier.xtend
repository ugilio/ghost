package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.timeline.lang.Expression
import it.cnr.istc.timeline.lang.InstantiatedValue
import it.cnr.istc.timeline.lang.TemporalExpression
import it.cnr.istc.timeline.lang.TimePointOperation
import it.cnr.istc.timeline.lang.Variable
import java.util.ArrayList
import java.util.HashMap
import java.util.List

class ExpressionCopier {
	HashMap<String, Variable> variables;

	new(HashMap<String, Variable> variables) {
		this.variables = variables;
	}

	package def dispatch Variable copyOf(Variable src) {
		return variables.get(src.name);
	}

	package def dispatch TemporalExpression copyOf(TemporalExpression src) {
		return new TemporalExpressionImpl(copyOf(src.left), src.operator,
			src.intv1, src.intv2, copyOf(src.right),
			(src as TemporalExpressionImpl).register);
	}

	package def dispatch Expression copyOf(Expression src) {
		val operands = new ArrayList<Object>(src.operands.map[o|copyOf(o)]);
		val op = new ArrayList<String>(src.operators);
		val e = new ExpressionImpl(null,null);
		e.operators = op;
		e.operands = operands; 
		return e;
	}

	package def dispatch TimePointOperation copyOf(TimePointOperation src) {
		return new TimePointOperationImpl(copyOf(src.instValue) as InstantiatedValue, src.selector);
	}

	package def dispatch InstantiatedValue copyOf(InstantiatedValue src) {
		return new InstantiatedValueImpl(copyOf(src.component), copyOf(src.value),
			copyOf(src.arguments) as List<Object>);
	}

	package def dispatch List<Object> copyOf(List<Object> src) {
		return new ArrayList(src.map[o|copyOf(o)]);
	}

	package def dispatch Object copyOf(Void src) {
		return null;
	}

	package def dispatch Object copyOf(Object src) {
		return src;
	}
}
