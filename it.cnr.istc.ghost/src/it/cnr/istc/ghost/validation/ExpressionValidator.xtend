package it.cnr.istc.ghost.validation

import it.cnr.istc.ghost.ghost.Expression
import it.cnr.istc.ghost.ghost.TimePointOp
import it.cnr.istc.ghost.ghost.NumAndUnit
import it.cnr.istc.ghost.ghost.QualifInstVal
import it.cnr.istc.ghost.ghost.ValueDecl
import it.cnr.istc.ghost.validation.AbstractExpressionValidator.ResultType
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import it.cnr.istc.ghost.ghost.ResConstr
import it.cnr.istc.ghost.ghost.FormalPar
import it.cnr.istc.ghost.ghost.IntDecl
import it.cnr.istc.ghost.ghost.EnumDecl
import it.cnr.istc.ghost.ghost.NamedPar
import it.cnr.istc.ghost.ghost.LocVarDecl
import it.cnr.istc.ghost.ghost.SimpleType
import java.util.HashMap
import it.cnr.istc.ghost.ghost.InheritedKwd
import it.cnr.istc.ghost.validation.AbstractExpressionValidator.ErrMsgFunction
import it.cnr.istc.ghost.ghost.ConstDecl
import it.cnr.istc.ghost.ghost.EnumLiteral
import it.cnr.istc.ghost.ghost.ThisKwd
import it.cnr.istc.ghost.ghost.TemporalRelation
import it.cnr.istc.ghost.ghost.ResSimpleInstVal
import it.cnr.istc.ghost.ghost.PlaceHolder
import java.util.HashSet

class ExpressionValidator extends AbstractExpressionValidator {

/*
 * TODO:
 *  - return also the computed values, if computation is possible? Or bounds?
 */
	private HashMap<String,ResultType> locVarTypes = new HashMap();
	private HashSet<LocVarDecl> unusedVars = new HashSet();
	private ErrMsgFunction errMsgFunction;
	private WarnMsgFunction warnMsgFunction;
	
	new(ErrMsgFunction err, WarnMsgFunction warn) {
		this.errMsgFunction = err;
		this.warnMsgFunction = warn;
	}
	
	private  def addType(String name,ResultType type) {
		if (name === null)
			return;
		val t = locVarTypes.get(name);
		if (!isUnknown(t))
			return;
		locVarTypes.put(name,type);
	}
	
	//SyncBody or TransConstrBody
	def checkExpressions(EObject body) {
		determineLocVarTypes(body);
		unusedVars.addAll(body.eContents.filter(LocVarDecl));
		//now check everything with proper error messages
		for (exp : body.eContents)
			eval(exp);
		reportUnusedVars();
	}
	
	private def determineLocVarTypes(EObject body) {
		//quickly determine the types of local variables.
		//do it multiple times because after each pass we might infer more types
		val locVars = body.eContents.filter(LocVarDecl);
		var unkcount = locVars.size;
		var oldcount = 0;
		while (unkcount != oldcount && unkcount > 0) {
			oldcount = unkcount;
			unkcount = 0;
			for (locVar : locVars) {
				val type = getType(locVar.value);
				if (type == ResultType.UNKNOWN)
					unkcount++;
				addType(locVar.name,type);
			}
		}
	}
	
	private def reportUnusedVars() {
		for (v : unusedVars)
			warning(String.format(
			"Local variable '%s' declared but not used",v.name),v,GhostValidator.UNUSED_VAR);
	}
	
	protected def error(String message, EObject source, EStructuralFeature feature, int index, String code,
			String... issueData) {
		if (errMsgFunction!==null)
			errMsgFunction.error(message, source, feature, index, code, issueData);
	}
	
	protected def warning(String message, EObject source, EStructuralFeature feature, int index, String code,
			String... issueData) {
		if (warnMsgFunction!==null)
			warnMsgFunction.warning(message, source, feature, index, code, issueData);
	}
	
	protected def warning(String message, EObject source, String code) {
		val cont = source.eContainer;
		val feat = source.eContainingFeature;
		warning(message,cont,feat,-1,code);
	}
	
	protected def error(String message, EObject source, String code) {
		val cont = source.eContainer;
		val feat = source.eContainingFeature;
		error(message,cont,feat,-1,code);
	}
	
	private def String formatType(ResultType type) {
		return type.getDescription();
	}
	
	private def expected(ResultType expected, ResultType got, Expression exp) {
			error(String.format(
				"Expected operand of type '%s' but got '%s'",formatType(expected),formatType(got)),
				exp,GhostValidator.EXPECTED_TYPE);
	}
	
	private def checkType(ResultType expected, ResultType got, Expression exp) {
		if (expected != got && !isUnknown(got))
			expected(expected,got,exp);
	}
	
	private def checkNumOpCompat(ResultType type, Expression exp) {
		if (type === ResultType.BOOLEAN)
			warning("Boolean operand treated as numeric",exp,GhostValidator.BOOLEAN_TO_NUMERIC)
		else checkType(ResultType.NUMERIC,type,exp);
		return ResultType.NUMERIC;
	}
	
	private def checkCompCompat(ResultType left, Expression leftExp, ResultType right, Expression rightExp) {
		if (right == ResultType.INSTVAL)
			if (left == ResultType.INSTVAL || isUnknown(left))
				return ResultType.TEMPORALEXP;
		if (left == right || isUnknown(left)|| isUnknown(right))
			return ResultType.BOOLEAN;
		warning(String.format(
			"Comparison between different types ('%s' and '%s')",
			formatType(left),formatType(right)),
			rightExp,GhostValidator.COMPARISON_DIFFERENT_TYPES);
		return ResultType.BOOLEAN;
	}
	
	private def checkNumCompCompat(ResultType left, Expression leftExp, ResultType right, Expression rightExp) {
		if (right == ResultType.INSTVAL)
			if (left === null || left == ResultType.INSTVAL)
				return ResultType.TEMPORALEXP;
		checkNumOpCompat(left,leftExp);
		checkNumOpCompat(right,rightExp);
		return ResultType.BOOLEAN;
	}
	
	private def isUnknown(ResultType type) {
		return (type === null || type == ResultType.UNKNOWN);
	}
	
	private def ResultType getType(EObject exp) {
		switch (exp) {
			ResConstr,
			TimePointOp: return ResultType.INSTVAL
			QualifInstVal: return evalRef(exp.value)
			NumAndUnit: return ResultType.NUMERIC
			Expression: {
				if (exp.op!==null)
					return ResultType.TEMPORALEXP;
				if (exp.ops !== null && exp.ops.size>0)
					return doOperator(exp.ops.get(0),null,null,null,null);
				return getType(exp.left);
			}
		}
		return ResultType.UNKNOWN;
	}

	protected def dispatch ResultType eval(Object exp) {
		if (exp instanceof EObject && (exp as EObject).eIsProxy)
			return ResultType.UNKNOWN;
		throw new IllegalArgumentException("Unknown expression type: "+exp);
	}

	protected def dispatch ResultType eval(Void exp) {
		return null;
	}
	
	protected def dispatch ResultType eval(Expression exp) {
		var leftExp = exp.left;
		var left = eval(leftExp);
		if (exp.op !== null) {
			val rightExp = exp.right.get(0);
			val right = eval(rightExp);
			return doOperator(exp.op, left, right, leftExp, rightExp);
		}
		val oplen = if(exp.right === null) 0 else exp.right.size;
		for (var i = 0; i < oplen; i++) {
			val rightExp = exp.right.get(i);
			val right = eval(rightExp);
			left = doOperator(exp.ops.get(i), left, right, leftExp, rightExp);
			leftExp = rightExp;
		}
		return left;
	}
	
	private def doOperator(String op, ResultType left, ResultType right,
		Expression leftExp, Expression rightExp) {
			switch(op) {
				case '*',
				case '/',
				case '%',
				case '+',
				case '-' : {
						checkNumOpCompat(left,leftExp);
						checkNumOpCompat(right,rightExp);
						return ResultType.NUMERIC;
						} 
				case '<',
				case '>' : return checkNumCompCompat(left,leftExp,right,rightExp)
				case '<=',
				case '>=' : {
						checkNumOpCompat(left,leftExp);
						checkNumOpCompat(right,rightExp);
						return ResultType.BOOLEAN;
						} 
				case '=',
				case '!=' : return checkCompCompat(left,leftExp,right,rightExp)
			}
			return ResultType.UNKNOWN;
	}
	
	private def doOperator(TemporalRelation op, ResultType left, ResultType right,
		Expression leftExp, Expression rightExp) {

		checkType(ResultType.INSTVAL,left,leftExp);
		checkType(ResultType.INSTVAL,right,rightExp);
		return ResultType.TEMPORALEXP;
	}	

	protected def dispatch ResultType eval(TimePointOp exp) {
		val value = eval(exp?.value);
		checkType(ResultType.INSTVAL,value,exp);
		return ResultType.INSTVAL;
	}

	protected def dispatch ResultType eval(QualifInstVal exp) {
		if (exp.comp !== null || exp.arglist !== null || exp.value instanceof ValueDecl)
			return ResultType.INSTVAL;
		return evalRef(exp.value);
	}

	protected def dispatch ResultType eval(ResConstr exp) {
		val amnt = eval(exp?.amount);
		checkType(ResultType.NUMERIC,amnt,exp);
		return ResultType.INSTVAL;
	}
	
	protected def dispatch ResultType eval(ThisKwd kwd) {
		return ResultType.INSTVAL;
	}
	
	protected def dispatch ResultType eval(NumAndUnit exp) {
		return ResultType.NUMERIC;
	}
	
	protected def dispatch ResultType eval(LocVarDecl decl) {
		val type = eval(decl?.value);
		//this should not be necessary, shouldn't it?
		addType(decl?.name,type);
		return type;
	}
	
	protected def dispatch ResultType eval(InheritedKwd kwd) {
		return ResultType.UNKNOWN;
	}
	
	protected def dispatch ResultType eval(PlaceHolder exp) {
		return ResultType.UNKNOWN;
	}
	
	protected def dispatch ResultType evalRef(SimpleType type) {
		if (type === null)
			return ResultType.UNKNOWN;
		if (type instanceof IntDecl)
			return ResultType.NUMERIC;
		if (type instanceof EnumDecl)
			return ResultType.ENUM;
		throw new IllegalArgumentException("Unknown type: "+type);
	}
	
	protected def dispatch ResultType evalRef(ConstDecl decl) {
		return ResultType.NUMERIC;
	}	

	protected def dispatch ResultType evalRef(EnumLiteral literal) {
		return ResultType.ENUM;
	}	

	protected def dispatch ResultType evalRef(ValueDecl decl) {
		return ResultType.INSTVAL;
	}	

	protected def dispatch ResultType evalRef(FormalPar exp) {
		return evalRef(exp?.type);
	}	

	protected def dispatch ResultType evalRef(NamedPar exp) {
		if (exp?.type === null && exp?.eContainer instanceof ResSimpleInstVal)
			return ResultType.NUMERIC;
		return evalRef(exp?.type);
	}	

	protected def dispatch ResultType evalRef(LocVarDecl exp) {
		unusedVars.remove(exp);
		val t = locVarTypes.get(exp?.name);
		if (t === null)
			return ResultType.UNKNOWN;
		return t;
	}
	
	protected def dispatch ResultType evalRef(Void exp) {
		return ResultType.UNKNOWN;
	}
	
	protected def dispatch ResultType evalRef(Object exp) {
		if (exp instanceof EObject && (exp as EObject).eIsProxy)
			return ResultType.UNKNOWN;
		throw new IllegalArgumentException("Unknown reference type: "+exp);
	}
}
