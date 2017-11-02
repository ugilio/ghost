package it.cnr.istc.ghost.generator.internal

import static extension it.cnr.istc.ghost.generator.internal.Utils.*;
import it.cnr.istc.timeline.lang.Expression
import java.util.List
import java.util.ArrayList

class ExpressionImpl extends ProxyObject implements Expression {
	it.cnr.istc.ghost.ghost.Expression real = null;
	List<String> operators = null;
	List<Object> operands = null;

	new(it.cnr.istc.ghost.ghost.Expression real, Register register) {
		super(register);
		this.real = real;
	}

	private def getData() {
		val count = if(real?.ops === null) 0 else real.ops.size();
		operands = new ArrayList(count+1);
		operands.add(getProxy(real?.left));
		if (count == 0)
			operators = new ArrayList()
		else
			operators = real?.ops?.map[s|s].toRegularList;
		operands.addAll(real?.right?.map[e|getProxy(e)].toRegularList);
	}

	override getOperands() {
		if (operands === null)
			getData();
		return operands;
	}
	
	override getOperators() {
		if (operators === null)
			getData();
		return operators;
	}
	
	
	
	package def	setLeft(Object left) {
		if (operands === null)
			getData();
		this.operands.set(0,left);
	}
	
	package def	setOperators(List<String> operators) {
		this.operators = operators;
	}
	
	package def	setOperands(List<Object> operands) {
		this.operands = operands;
	}
	package def Object getReal() {
		return real;
	}
}