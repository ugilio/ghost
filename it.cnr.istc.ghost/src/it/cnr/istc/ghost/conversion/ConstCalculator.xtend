package it.cnr.istc.ghost.conversion

import it.cnr.istc.ghost.ghost.ConstExpr
import it.cnr.istc.ghost.ghost.ConstSumExp
import it.cnr.istc.ghost.ghost.ConstTerm
import it.cnr.istc.ghost.ghost.ConstSubExp
import it.cnr.istc.ghost.ghost.ConstLiteralUsage
import it.cnr.istc.ghost.ghost.ConstIntv
import com.google.inject.Singleton
import java.util.Set
import java.util.HashSet
import it.cnr.istc.ghost.ghost.ConstLiteral
import it.cnr.istc.ghost.ghost.EnumLiteral
import it.cnr.istc.ghost.ghost.ConstDecl
import it.cnr.istc.ghost.ghost.ConstNumber
import it.cnr.istc.ghost.ghost.Interval
import it.cnr.istc.ghost.utils.ArithUtils
import com.google.inject.Inject
import it.cnr.istc.ghost.ghost.ConstPlaceHolder
import it.cnr.istc.ghost.ghost.impl.ConstPlaceHolderImpl

@Singleton
class ConstCalculator {
	
	@Inject extension IntervalHelper intvHelper;
	@Inject extension NumAndUnitHelper numHelper;
	
	private static class FinalConstPlaceHolder extends ConstPlaceHolderImpl {
		override getComputed() { return null;}
		override setComputed(Object value) {}
	}
	public static final ConstPlaceHolder CONST_PLACEHOLDER = new FinalConstPlaceHolder();
	
	private Set<String> constInProgress = new HashSet<String>();
	
	def Object compute(ConstExpr expr) {
		if (expr.computed!==null)
			return expr.computed;
		val result = 
		if (expr instanceof ConstSumExp)
			calcSumExp(expr as ConstSumExp)
		else if (expr instanceof ConstPlaceHolder)
			CONST_PLACEHOLDER
		else 		
			throw new ConstCalculatorException("Unknown constant expression type: "+expr.class);
		expr.computed = result;
		return result;
	}
	
	private def Object calcSumExp(ConstSumExp expr) {
		val left = calcTerm(expr.left);
		if (expr.ops.size==0)
			return left;
		checkOperatorCompat(left,expr.ops.get(0));
		var value = left as Object;
		for (var i = 0; i < expr.ops.size; i++) {
			val op = expr.ops.get(i);
			val right = calcTerm(expr.right.get(i));
			checkOperandsCompat(value,right);
			switch (op) {
				case '+' : value = add(value,right)
				case '-' : value = sub(value,right)
			}
		}
		return value;
	}
	
	private def calcTerm(ConstTerm term) {
		val left = calcFactor(term.left);
		if (term.ops.size==0)
			return left;
		checkOperatorCompat(left,term.ops.get(0));
		var value = left;
		try
		{
			for (var i = 0; i < term.ops.size; i++) {
				val op = term.ops.get(i);
				val right = calcFactor(term.right.get(i));
				checkOperandsCompat(value,right);
				switch (op) {
					case '*' : value = mul(value,right)
					case '/' : value = div(value,right)
					case '%' : value = mod(value,right)
				}
			}
		}
		catch (ArithmeticException e) {
			throw new ConstCalculatorException("Division by zero while evaluating constant expression");
		}
		return value;
	}
	
	private def dispatch calcFactor(ConstSubExp factor) {
		return calcSumExp(factor.value);
	}
	
	private def dispatch calcFactor(ConstLiteralUsage factor) {
		return getValueOf(factor.value);
	}
	
	private def dispatch calcFactor(ConstNumber factor) {
		return factor.value.get();
	}
	
	private def dispatch calcFactor(ConstIntv factor) {
		return factor.value;
	}
	
	private def dispatch getValueOf(EnumLiteral literal) {
		return literal;
	}
			
	private def dispatch getValueOf(ConstDecl literal) {
		if (literal.value?.computed!==null)
			return literal.value.computed;
		if (constInProgress.contains(literal.name))
			throw new ConstCalculatorException(
				String.format("Recursive constant definition '%s'",literal.name));
		constInProgress.add(literal.name);
		try
		{
			val result = compute(literal.value);
			return result;
		}
		finally
		{
			constInProgress.remove(literal.name);
		}
	}
//The linker already signals this	
	private def dispatch getValueOf(ConstLiteral literal) {
//		throw new ConstCalculatorException("Unknown ConstLiteral type: "+literal.class);
		throw new ConstCalculatorException("");
	}	
	
	private def String getTypeName(Object o) {
		return
		switch o.class {
			case Long: "Number"
			case EnumLiteral: "Enumeration Literal"
			case Interval: "Interval"
			case ConstPlaceHolder: "_"
			default: "<unknown type "+o.class.simpleName+">" 
		}
	}
	
	private def checkOperatorCompat(Object value, String op) {
		if (! (value instanceof Long) && !(value instanceof Interval))
			throw new ConstCalculatorException(
			String.format("Cannot apply operator '%s' to a value of type '%s'",
				op,getTypeName(value)));
	}
	
	private def checkOperandsCompat (Object left, Object right) {
		val ok =
			(left instanceof Long && right instanceof Long) ||
			(left instanceof Long && right instanceof Interval) ||
			(left instanceof Interval && right instanceof Long) ||
			(left instanceof Interval && right instanceof Interval);
		if (!ok)
			throw new ConstCalculatorException(
				String.format("Incompatible operands: '%s' and '%s'",
					getTypeName(left),getTypeName(right)));
	}
	
//	private def expectType(Object o, String type) {
//		val realType = getTypeName(o);
//		if (!type.equals(realType))
//			throw new ConstCalculatorException(
//				String.format("Expected '%s' but '%s' found",type,realType));
//		return o;
//	}
//	
//	private def expectNumber(Object o) {
//		return expectType(o,"Number");
//	}


	//Arithmetic Operations
	
	private def dispatch add(long left, long right) {
		return ArithUtils.add(left,right);
	}
	
	private def dispatch add(long left, Interval right) {
		val result = intvHelper.create(0,0);
		result.lb=ArithUtils.add(left,right.lb());
		result.ub=ArithUtils.add(left,right.ub());
		return result;
	}
	
	private def dispatch Object add(Interval left, long right) {
		return add(right,left);
	}
	
	private def dispatch add(Interval left, Interval right) {
		val result = intvHelper.create(0,0);
		result.lb=ArithUtils.add(left.lb(),right.lb());
		result.ub=ArithUtils.add(left.ub(),right.ub());
		return result;
	}
	
	private def dispatch sub(long left, long right) {
		return ArithUtils.sub(left,right);
	}
	
	private def dispatch sub(long left, Interval right) {
		val result = intvHelper.create(0,0);
		result.lb=ArithUtils.sub(left,right.lb());
		result.ub=ArithUtils.sub(left,right.ub());
		return result;
	}
	
	private def dispatch sub(Interval left, long right) {
		val result = intvHelper.create(0,0);
		result.lb=ArithUtils.sub(left.lb(),right);
		result.ub=ArithUtils.sub(left.ub(),right);
		return result;
	}
	
	private def dispatch sub(Interval left, Interval right) {
		val result = intvHelper.create(0,0);
		result.lb=ArithUtils.sub(left.lb(),right.lb());
		result.ub=ArithUtils.sub(left.ub(),right.ub());
		return result;
	}

	private def dispatch mul(long left, long right) {
		return ArithUtils.mul(left,right);
	}
	
	private def dispatch mul(long left, Interval right) {
		val result = intvHelper.create(0,0);
		result.lb=ArithUtils.mul(left,right.lb());
		result.ub=ArithUtils.mul(left,right.ub());
		return result;
	}
	
	private def dispatch Object mul(Interval left, long right) {
		return mul(right,left);
	}
	
	private def dispatch mul(Interval left, Interval right) {
		val result = intvHelper.create(0,0);
		result.lb=ArithUtils.mul(left.lb(),right.lb());
		result.ub=ArithUtils.mul(left.ub(),right.ub());
		return result;
	}
	
	private def dispatch div(long left, long right) {
		return ArithUtils.div(left,right);
	}
	
	private def dispatch div(long left, Interval right) {
		val result = intvHelper.create(0,0);
		result.lb=ArithUtils.div(left,right.lb());
		result.ub=ArithUtils.div(left,right.ub());
		return result;
	}
	
	private def dispatch Object div(Interval left, long right) {
		val result = intvHelper.create(0,0);
		result.lb=ArithUtils.div(left.lb(),right);
		result.ub=ArithUtils.div(left.ub(),right);
		return result;
	}
	
	private def dispatch div(Interval left, Interval right) {
		val result = intvHelper.create(0,0);
		result.lb=ArithUtils.div(left.lb(),right.lb());
		result.ub=ArithUtils.div(left.ub(),right.ub());
		return result;
	}
	
	private def dispatch mod(long left, long right) {
		return ArithUtils.mod(left,right);
	}
	
	private def dispatch mod(long left, Interval right) {
		val result = intvHelper.create(0l,0l);
		result.lb=ArithUtils.mod(left,right.lb());
		result.ub=ArithUtils.mod(left,right.ub());
		return result;
	}
	
	private def dispatch Object mod(Interval left, long right) {
		val result = intvHelper.create(0,0);
		result.lb=ArithUtils.mod(left.lb(),right);
		result.ub=ArithUtils.mod(left.ub(),right);
		return result;
	}
	
	private def dispatch mod(Interval left, Interval right) {
		val result = intvHelper.create(0,0);
		result.lb=ArithUtils.mod(left.lb(),right.lb());
		result.ub=ArithUtils.mod(left.ub(),right.ub());
		return result;
	}
	
	public static class ConstCalculatorException extends Exception {
		new(String message) {
			super(message);
		}
	}	
}