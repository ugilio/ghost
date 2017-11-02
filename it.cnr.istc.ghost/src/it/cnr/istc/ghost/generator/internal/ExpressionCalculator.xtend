package it.cnr.istc.ghost.generator.internal

import com.google.common.collect.Lists
import it.cnr.istc.ghost.utils.ArithUtils
import it.cnr.istc.timeline.lang.TimePointOperation
import it.cnr.istc.timeline.lang.Variable
import java.util.ArrayList
import java.util.HashMap
import it.cnr.istc.timeline.lang.Parameter
import it.cnr.istc.timeline.lang.EnumLiteral

public class ExpressionCalculator {
	BlockImpl block;
	Register register;
	ExpressionCopier copier = null;
	boolean divisionsAllowed = false;
	
	new(BlockImpl block) {
		this.block = block;
	}
	
	private def void evalSubExps(ExpressionImpl exp) {
		val subs = exp.operands;
		for (var i = 0; i < subs.size(); i++) {
			val r = evaluate(subs.get(i));
			subs.set(i,r);
		}
	}
	
	private def boolean canApply(String lOp, long left, String rOp, long right) {
		if (divisionsAllowed)
			return true;
		// Be careful about division.
		// Special cases:
		//   /x/y = /(x*y) (no worries) 
		//   x/y and /x*y = /(x/y) be careful
		//if divisor == 0 let it fail later
		if ((lOp == '/' && rOp == '*') || (lOp != '/' && rOp == '/'))
			return (right == 0) || left % right == 0;
		return true;
	}

	private def long b2l(boolean b) {
		return if (b) 1L else 0L;
	}
	
	private def long compute(String lOp, long left, String rOp, long right) {
		if (lOp == '/')
			switch (rOp) {
				//  /x/y = /(x*y)
				case '/': return ArithUtils.mul(left,right)
				// /x*y = /(x/y)
				case '*': return ArithUtils.div(left,right)
			}
		if (lOp == '-')
			switch (rOp) {
				//  -x -y = -(x+y)
				case '-': return ArithUtils.add(left,right)
				// -x+y = -(x-y)
				case '+': return ArithUtils.sub(left,right)
			}
		
		return
		switch (rOp) {
			case '*' : ArithUtils.mul(left,right)
			case '/' : ArithUtils.div(left,right)
			case '%' : ArithUtils.mod(left,right)
			case '+' : ArithUtils.add(left,right)
			case '-' : ArithUtils.sub(left,right)
			case '<' : b2l(left < right)
			case '<=' : b2l(left <= right)
			case '>' : b2l(left > right)
			case '>=' : b2l(left >= right)
			case '=' : b2l(left == right)
			case '!=' : b2l(left != right)
			default: throw new IllegalArgumentException("Unknown operator: "+rOp)
		}
	}
	
	private def long calcRightOp(ExpressionImpl exp, int i, String leftOp, long left) {
		var lOp = leftOp;
		var l = left;
		val ops = exp.getOperators;
		val operands = exp.operands;
		var j = i+1;
		while ( j < ops.size()) {
			val tmp = operands.get(j+1);
			val op = ops.get(j);
			var applied = false; 
			if (tmp instanceof Long) {
				val r = tmp.longValue();
				if (canApply(lOp,l,op,r)) {
					l = compute(lOp,l,op,r);
					applied=true;
				} else if (i != -1 && canApply(op,r,lOp,l)) {
					l = compute(op,r,lOp,l);
					ops.set(i,op);
					lOp = op;
					applied=true;
				}
				if (applied) {
					ops.remove(j);
					operands.remove(j+1);
					j--;
				}
			}
			if (!applied && op=='%') //stop on modulo, on this level
				return l;
			j++;
		}
		return l;
	}
	
	private def int doCalculateFromLeaves(ExpressionImpl exp) {
		val ops = exp.getOperators;
		val operands = exp.operands;
		if (exp.operands.get(0) instanceof Long)
			exp.operands.set(0,calcRightOp(exp,-1,"",exp.operands.get(0) as Long));
		for (var i = 0; i < ops.size()-1; i++) {
			val tmp = operands.get(i+1);
			var op = ops.get(i);
			if (tmp instanceof Long && op != '%') {
				var l = (tmp as Long).longValue();
				l = calcRightOp(exp,i,op,l);
				op = ops.get(i); //calcRightOp might have changed it, if reversed
				if (l<0) switch (op) {
					case '+': {op='-'; l=-l;}
					case '-': {op='+'; l=-l;}
				}
				ops.set(i,op);
				operands.set(i+1,l);
			}
		}
		handleMultByZero(exp);
		return operands.size();
	}
	
	private def calculateFromLeaves(ExpressionImpl exp) {
		var leaves = exp.getOperands.size();
		var oldLeaves = Integer.MAX_VALUE;
		//e.g. divisions might become appliable later
		while (leaves < oldLeaves) {
			oldLeaves = leaves;
			leaves = doCalculateFromLeaves(exp);
		}
	}
	
	private def ExpressionImpl createSubExp(Object left, String op, Object newRight) {
		val newExp = new ExpressionImpl(null,register);
		val ops = Lists.newArrayList(op);
		val operands = Lists.newArrayList(left,newRight);
		newExp.operators=ops;
		newExp.operands=operands;
		return newExp;
	}
	
	private def void apply(Object left, String op, ExpressionImpl right) {
		val operands = right.operands;
		for (var i = 0; i < operands.size(); i++)
			operands.set(i,createSubExp(left,op,operands.get(i)))
	}
	
	private def ExpressionCopier getExpressionCopier() {
		if (copier === null) {
			val varMap = new HashMap<String, Variable>();
			block.variables.forEach[v|varMap.put(v.name, v)];
			copier = new ExpressionCopier(varMap);
		}
		return copier;
	}
	
	private def void changeSigns(ExpressionImpl exp) {
		val ops = exp.getOperators;
		for (var i = 0; i < ops.size(); i++)
			switch (ops.get(i)) {
				case '+' : ops.set(i,'-')
				case '-' : ops.set(i,'+')
			}
	}
	
	private def void applyExp(ExpressionImpl left, String op, ExpressionImpl right) {
		val count=left.getOperands.size();
		val copier = getExpressionCopier();
		val arr = new ArrayList<ExpressionImpl>(count);
		for (var i = 1; i < count; i++)
			arr.add(copier.copyOf(right) as ExpressionImpl);
			
		apply(left.operands.get(0),op,right);
		for (var i = 0; i < count-1; i++) {
			val rexp = arr.get(i);
			apply(left.operands.get(i+1),op,rexp);
			if (left.getOperators.get(i)=='-')
				changeSigns(rexp);
			right.operators.add(left.getOperators.get(i));
			right.operators.addAll(rexp.operators);
			right.operands.addAll(rexp.operands);
		}
	}
	
	private def boolean isSumExp(ExpressionImpl exp) {
		return
		exp.getOperators.size()>0 && switch (exp.getOperators.get(0)) {
			case '+', case '-' : true
			default : false
		}
	}
	
	private def boolean isMultExp(ExpressionImpl exp) {
		return
		exp.getOperators.size()>0 && switch (exp.getOperators.get(0)) {
			case '*', case '/', case '%' : true
			default : false
		}
	}
	
	private def boolean tryToRedistribute(Object left, String op, Object right) {
		if (op != '*')
			return false;
		val lOk = (left instanceof ExpressionImpl) && isSumExp(left as ExpressionImpl);
		val rOk = (right instanceof ExpressionImpl) && isSumExp(right as ExpressionImpl);
		if (lOk && rOk) {
			applyExp(left as ExpressionImpl,op,right as ExpressionImpl);
			return true;
		}
		if (rOk && (! (left instanceof ExpressionImpl))) {
			apply(left,op,right as ExpressionImpl);
			return true;
		}
		if (lOk && (! (right instanceof ExpressionImpl))) {
			apply(right,op,left as ExpressionImpl);
			return true;
		}
		return false;
	}
	
	private def void tryToRedistribute(ExpressionImpl exp) {
		var i = 0;
		while (i<exp.operators.size()) {
			var j = i+1;
			while (j < exp.operands.size()) {
				var l = exp.operands.get(i);
				var op = exp.operators.get(j-1);
				var r = exp.operands.get(j);
				if (op == '%')
					return
				else if (tryToRedistribute(l,op,r)) {
					if (r instanceof ExpressionImpl)
						exp.operands.set(i,r);
					exp.operators.remove(j-1);
					exp.operands.remove(j);
					exp.operands.set(i,evaluate(exp.operands.get(i)));
				}
				else j++;
			}
			i++;
		}
	}
	
	private def int removeOperandAndOperator(ExpressionImpl exp, int operatorIndex, int operandIndex) {
		exp.operands.remove(operandIndex);
		exp.operators.remove(operatorIndex);
		return operatorIndex-1;
	}

	private def dispatch Object handleMultByZero(ExpressionImpl exp) {
		val ops = exp.operators;
		val operands = exp.operands;
		for (var i = 0; i < operands.size(); i++)
			operands.set(i,handleMultByZero(operands.get(i)));
			
		for (var i = 0; i < ops.size(); i++) {
			if (ops.get(i) == '*')
				if (operands.get(i) == 0L || operands.get(i+1) == 0L)
					return 0L;
		}
		return exp;
	}
	
	private def dispatch Object handleMultByZero(Object obj) { return obj; }
	private def dispatch Object handleMultByZero(Void obj) { return null; }
	
	
	private def void removeNeutrals(ExpressionImpl exp) {
		val ops = exp.operators;
		val operands = exp.operands;
		for (var i = 0; i < ops.size(); i++) {
			switch (ops.get(i)) {
				case '*':  {
					if (operands.get(i) == 1L) // 1*
						i=removeOperandAndOperator(exp,i,i)
					else if (operands.get(i+1) == 1L) // *1
						i=removeOperandAndOperator(exp,i,i+1)
				}
				case '/': if (operands.get(i+1) == 1L) // /1
						i=removeOperandAndOperator(exp,i,i+1)
				case '+':  {
					if (operands.get(i) == 0L) // 0+
						i=removeOperandAndOperator(exp,i,i)
					else if (operands.get(i+1) == 0L) // +0
						i=removeOperandAndOperator(exp,i,i+1)
				}
				case '-': if (operands.get(i+1) == 0L) // -0
						i=removeOperandAndOperator(exp,i,i+1)
			}
		}
		for (o : operands)
			if (o instanceof ExpressionImpl)
				removeNeutrals(o);
	}
	
	private def boolean sameLevel(String op1, String op2) {
		return
		switch (op1) {
			case '+', case '-' : (op2 == '+' || op2 == '-')
			case '*', case '/': (op2 == '*' || op2 == '/')
			default: false
		}
	}
	
	private def void doMerge(ExpressionImpl exp, int i) {
		val mustReverse = i > 0 &&
			switch (exp.operators.get(i-1)) {
				case '-', case '/': true
				default: false
			}
		val sub = exp.operands.get(i) as ExpressionImpl;
		exp.operands.set(i,sub.operands.get(0));
		for (var j = 1; j < sub.operands.size(); j++) {
			var op = sub.operators.get(j-1);
			if (mustReverse) op = switch (op) {
				case '+' : '-'
				case '-' : '+'
				case '*' : '/'
				case '/' : '*'
				default: op
			} 
			exp.operands.add(i+j,sub.operands.get(j));
			exp.operators.add(i+j-1,op);
		}
	}
	
	private def void mergeSameLevel(ExpressionImpl exp) {
		if (exp.operators.size() == 0)
			return;
		val levelOp = exp.operators.get(0);
		switch (levelOp) {
			case '+', case '-', case '*', case '/' : {}
			default: return
		}
		var merged = false;
		for (var i = 0; i < exp.operands.size(); i++) {
			var s = exp.operands.get(i);
			switch (s) {
				ExpressionImpl : {
					if (s.operators.size()>0) {
						val subOp = s.operators.get(0);
						if (sameLevel(levelOp,subOp)) {
							doMerge(exp,i);
							merged = true;
						}
					}
				} 
			} 
		}
		if (merged)
			evaluate(exp);
	}
	
	
	private def boolean hasVariableInNumerator(Object obj) {
		if (obj instanceof Variable || obj instanceof Parameter)
			return true;
		if (! (obj instanceof ExpressionImpl))
			return false;
		val exp = obj as ExpressionImpl; 
		var i = 0;
		while (i < exp.operands.size()) {
			val sub = exp.operands.get(i);
			if (i>0 && switch(exp.operators.get(i-1)) {
				case '/', case '%': true
				default: false
			})
				i++
			else if (hasVariableInNumerator(sub))
				return true;
			i++;
		}
		return false;
	}
	
	private def dispatch Long findVariableDivisor(ExpressionImpl exp) {
		for (var i = 0; i < exp.operands.size(); i++) {
			var j = i;
			while (j < exp.operators.size() && exp.operators.get(j) == '/') {
				val divisor = exp.operands.get(j+1) 
				if (divisor instanceof Long) {
					if (hasVariableInNumerator(exp.operands.get(i)))
						return divisor;
				}
				j++;
			}
			if (j>0 && exp.operators.get(j-1) == '/')
				j++;
			i = j;
			if (i < exp.operands.size())
			{
				val tmp = findVariableDivisor(exp.operands.get(i));
				if (tmp !== null)
					return tmp;
			}
		}
		return null;
	}
	
	private def dispatch Long findVariableDivisor(Object exp) { return null; }
	private def dispatch Long findVariableDivisor(Void exp) { return null; }
	
	def dispatch Object evaluate(ExpressionImpl exp) {
		//evaluate operands, possibly creating leaves
		evalSubExps(exp);
		//do operations between constant values
		calculateFromLeaves(exp);
		
		if (exp.getOperators.size()==0)
			return exp.operands.get(0);

		//Try to redistribute
		tryToRedistribute(exp);

		removeNeutrals(exp);
		 
		mergeSameLevel(exp);
		
		return exp;
	}
	
	def dispatch Object evaluate(TimePointOperation exp) {
		//evaluate(exp.instValue);
		return exp;
	}
	
	def dispatch Object evaluate(Variable v) {
		if (BlockImpl.OPTIMIZE) {
			//don't evaluate now, we might end up in an infinite loop 
			//val value = evaluate(v.value);
			val value = v.value;
			//just to simplify further...
			if (value instanceof Long || value instanceof EnumLiteral)
				return value;
		}
		return v;
	}
	
	//Long, EnumLiteral, InstantiatedValue
	def dispatch Object evaluate(Object obj) {
		return obj;
	}
	
	def dispatch Object evaluate(Void obj) { return null; }
	
	private def void multBy(long left, ExpressionImpl exp) {
		if (isMultExp(exp)) {
			exp.operands.add(0,left);
			exp.operators.add(0,'*');
		}
		else
			apply(left,'*',exp);
	}
	
	private def void handleDivision(ExpressionImpl e) {
		while (true) {
			var div = findVariableDivisor(e);
			if (div !== null) {
				multBy(Math.abs(div),e);
				evaluate(e);
			}
			else return;
		}
	}
	
	def void handleDivisions() {
		for (e: block.expressions)
			handleDivision(e as ExpressionImpl);
			
		for (v : block.variables) {
			if (findVariableDivisor(v.value) !== null) {
				//Turn variables into equations
				val origExp = v.value as ExpressionImpl;
				val e = new ExpressionImpl(null,origExp.register);
				e.operands.set(0,v);
				e.operators.add("=");
				e.operands.add(origExp);
				block.expressions.add(e);
				(v as VariableProxy).setValue(null);
				//and evaluate
				handleDivision(e);
			}
		}
		
		divisionsAllowed = true;
		try
		{
			for (e: block.expressions)
				evaluate(e);
			for (v: block.variables)
				(v as VariableProxy).value=evaluate(v.value);				
		}
		finally {
			divisionsAllowed = false;
		}
	}
	
}