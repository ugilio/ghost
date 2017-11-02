package it.cnr.istc.ghost.generator.internal

import it.cnr.istc.ghost.ghost.Expression
import it.cnr.istc.timeline.lang.Interval
import it.cnr.istc.timeline.lang.TemporalOperator

class TemporalExpressionImpl extends ProxyObject implements InternalTemporalExpression {
	Object left;
	Object right;
	TemporalOperator operator;
	Interval int1;
	Interval int2;

	private def internalGetInterval(Expression real, Object i) {
		val ri = if (i === null) {
				switch (operator) {
					case BEFORE,
					case AFTER: Utils.OneInfInterval
					case CONTAINS,
					case DURING: Utils.ZeroInfInterval
					default: if(real !== null) getDefaultInterval(real.op) else null
				}
			} else
				getProxy(i) as Interval;
		return ri;
	}

	new(Expression real, Register register) {
		super(register);
		left = getProxy(real?.left);
		right = getProxy(real?.right?.get(0));
		operator = getTemporalOperator(real?.op?.name);
		int1 = internalGetInterval(real, real?.op?.l);
		int2 = internalGetInterval(real, real?.op?.r);
	}

	new(Object left, TemporalOperator op, Object right, Register register) {
		this(left, op, null, null, right, register);
	}

	new(Object left, TemporalOperator op, Interval int1, Object right, Register register) {
		this(left, op, int1, null, right, register);
	}

	new(Object left, TemporalOperator op, Interval int1, Interval int2, Object right, Register register) {
		super(register);
		this.left = left;
		this.operator = op;
		this.int1 = if(int1 !== null) int1 else internalGetInterval(null, null);
		this.int2 = if(int2 !== null) int2 else internalGetInterval(null, null);
		this.right = right;
	}

	override getOperator() {
		return operator;
	}

	override getIntv1() {
		return int1;
	}

	override getIntv2() {
		return int2;
	}

	override getRight() {
		return right;
	}

	override getLeft() {
		return left;
	}

	override setLeft(Object left) {
		this.left = left;
	}

	override setRight(Object right) {
		this.right = right;
	}

	override getOperators() {
		return null;
	}

	override getOperands() {
		return null;
	}
}
