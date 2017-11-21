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
import it.cnr.istc.ghost.ghost.TransConstrBody
import org.eclipse.xtext.EcoreUtil2
import it.cnr.istc.ghost.ghost.InitSection
import it.cnr.istc.ghost.ghost.GhostPackage
import it.cnr.istc.ghost.ghost.ConstLiteral
import it.cnr.istc.ghost.ghost.FactGoal
import java.util.List

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
		unusedVars.addAll(body.eContents.filter(LocVarDecl).filter[!isSpecialInitVariable]);
		//now check everything with proper error messages
		val inTC = body instanceof TransConstrBody;
		for (exp : body.eContents)
			evalTopLevel(exp,inTC);
		reportUnusedVars();
	}
	
	private def boolean isSpecialInitVariable(LocVarDecl varDecl) {
		switch (varDecl?.name) {
			case 'start', case 'horizon', case 'resolution': {}
			default: return false
		}
		return (EcoreUtil2.getContainerOfType(varDecl,InitSection) !== null);
	} 
	
	private def void checkSpecialInitValues(LocVarDecl varDecl, ResultType type) {
		if (!isSpecialInitVariable(varDecl))
			return;
		if (EcoreUtil2.getContainerOfType(varDecl,InitSection) === null)
			return;
		if (type != ResultType.NUMERIC)
			error(String.format(
			"Variable '%s' must be of type '%s'",
			varDecl.name,formatType(ResultType.NUMERIC)
			),varDecl,GhostPackage.Literals.LOC_VAR_DECL__VALUE,
			-1,GhostValidator.INIT_VAR_NOT_NUMBER);
		val nonConst = 
		EcoreUtil2.eAllOfType(varDecl.value,QualifInstVal).
			filter[i|!(i.value instanceof ConstLiteral)].
			filter[i|i.value !== null].head;
		if (nonConst !== null)
			error(String.format("Varible '%s' must evaluate to a constant value",
				varDecl.name),nonConst,GhostPackage.Literals.QUALIF_INST_VAL__VALUE,
				-1,GhostValidator.INIT_VAR_NOT_CONSTANT);
	}
	
	public def determineLocVarTypes(EObject body) {
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
		return locVarTypes;
	}
	
	private def checkInvalidVarType(ResultType type, LocVarDecl locVar) {
		if (type == ResultType.TEMPORALEXP)
			error(String.format("Cannot create a local variable of type '%s'",
				formatType(type)),locVar,
				GhostPackage.Literals.LOC_VAR_DECL__VALUE,-1,
				GhostValidator.LOCVAR_TEMPORAL_EXP);
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
	
	private def getIndex(EObject cont, EStructuralFeature feat, EObject obj) {
		if (!feat.isMany) return -1;
		val list = cont.eGet(feat) as List<? extends EObject>;
		return list.indexOf(obj);
	}
	
	protected def warning(String message, EObject source, String code) {
		val cont = source.eContainer;
		val feat = source.eContainingFeature;
		warning(message,cont,feat,getIndex(cont,feat,source),code);
	}
	
	protected def error(String message, EObject source, String code) {
		val cont = source.eContainer;
		val feat = source.eContainingFeature;
		error(message,cont,feat,getIndex(cont,feat,source),code);
	}
	
	private def String formatType(ResultType type) {
		return type.getDescription();
	}
	
	private def expected(ResultType expected, ResultType got, Expression exp) {
		expected(expected,got,exp,formatType(expected));
	}
	
	private def expected(ResultType expected, ResultType got, Expression exp, String expStr) {
			error(String.format(
				"Expected operand of type '%s' but got '%s'",expStr,formatType(got)),
				exp,GhostValidator.EXPECTED_TYPE);
	}
	
	private def checkType(ResultType expected, ResultType got, Expression exp) {
		if (expected != got && !isUnknown(got))
			expected(expected,got,exp);
	}
	
	private def checkType(ResultType expected, ResultType got, Expression exp, String expStr) {
		if (expected != got && !isUnknown(got))
			expected(expected,got,exp,expStr);
	}
	
	private def checkNumOpCompat(ResultType type, Expression exp) {
		if (type === ResultType.BOOLEAN)
			warning("Boolean operand treated as numeric",exp,GhostValidator.BOOLEAN_TO_NUMERIC)
		else checkType(ResultType.NUMERIC,type,exp);
		return ResultType.NUMERIC;
	}

	private def boolean shouldBeInTemporalExpression(ResultType rt) {
		return
		switch (rt) {
			case INSTVAL, case TIMEPOINT : true
			default : false
		}
	}
	
	private def checkCompCompat(ResultType left, Expression leftExp, ResultType right, Expression rightExp) {
		if (shouldBeInTemporalExpression(left) || shouldBeInTemporalExpression(right))
			return ResultType.TEMPORALEXP;

		checkCompCompatNoTempExp(left,leftExp,right,rightExp);
	}
	
	private def checkCompCompatNoTempExp(ResultType left, Expression leftExp, ResultType right, Expression rightExp) {
		if (left == right || isUnknown(left)|| isUnknown(right))
			return ResultType.BOOLEAN;
		warning(String.format(
			"Comparison between different types ('%s' and '%s')",
			formatType(left),formatType(right)),
			rightExp,GhostValidator.COMPARISON_DIFFERENT_TYPES);
		return ResultType.BOOLEAN;
	}
	
	private def checkNumCompCompat(ResultType left, Expression leftExp, ResultType right, Expression rightExp) {
		//any combination of instval and timepoint is valid for < and >
		if (right == ResultType.INSTVAL || right == ResultType.TIMEPOINT)
			if (left === null || left == ResultType.INSTVAL || left == ResultType.TIMEPOINT)
				return ResultType.TEMPORALEXP;
		checkNumOpCompat(left,leftExp);
		checkNumOpCompat(right,rightExp);
		return ResultType.BOOLEAN;
	}
	
	private def void checkFactGoalValue(FactGoal fact, ResultType type) {
		if (type != ResultType.INSTVAL)
			error(String.format("Expected operand of type '%s' but got '%s'",
				formatType(ResultType.INSTVAL),formatType(type)),
				fact,GhostPackage.Literals.FACT_GOAL__VALUE,-1,GhostValidator.EXPECTED_TYPE);
	}
	
	private def isUnknown(ResultType type) {
		return (type === null || type == ResultType.UNKNOWN);
	}
	
	private def ResultType getType(EObject exp) {
		switch (exp) {
			ResConstr,
			TimePointOp: return ResultType.TIMEPOINT
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
	
	protected def evalTopLevel(EObject exp, boolean inTransConstr) {
		val result = eval(exp);
		if (! (exp instanceof LocVarDecl) ) {
			val ok = 
			switch (result) {
				case UNKNOWN,
				case BOOLEAN,
				case TEMPORALEXP : true
				case INSTVAL: inTransConstr || (exp instanceof ResConstr) || (exp instanceof FactGoal)
				default: false
			}
			if (!ok)
				warning("Expression has no effect since it is not a constraint",exp,GhostValidator.USELESS_EXPRESSION)
		}
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
			return doTempOperator(exp.op, left, right, leftExp, rightExp);
		}
		val oplen = if(exp.right === null) 0 else exp.right.size;
		for (var i = 0; i < oplen; i++) {
			val rightExp = exp.right.get(i);
			val right = eval(rightExp);
			if (shouldBeInTemporalExpression(left) || shouldBeInTemporalExpression(right))
				left = doTempOperator(exp.ops.get(i), left, right, leftExp, rightExp, rightExp)
			else
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
				case '=' : return checkCompCompat(left,leftExp,right,rightExp)
				case '!=' : return checkCompCompatNoTempExp(left,leftExp,right,rightExp)
			}
			return ResultType.UNKNOWN;
	}
	
	private def doTempOperator(TemporalRelation op, ResultType l, ResultType right,
		Expression leftExp, Expression rightExp) {
		return doTempOperator(op.name,l,right,leftExp,rightExp, op);
	}
		
	private def doTempOperator(String opname, ResultType l, ResultType right,
		Expression leftExp, Expression rightExp, EObject context) {
			
		val left = if (leftExp === null) ResultType.INSTVAL else l; 
			
		var ok = 
		if (left == ResultType.TIMEPOINT && right == ResultType.TIMEPOINT)
			switch(opname) {
				case '=', case 'equals',
				case '<', case 'before',
				case '>', case 'after' : true
				default: false
			}
		else if (left == ResultType.INSTVAL && right == ResultType.TIMEPOINT)
			switch(opname) {
				case '<', case 'before',
				case '>', case 'after',
				case 'starts',
				case 'finishes',
				case 'contains' : true
				default: false
			}
		else if (left == ResultType.TIMEPOINT && right == ResultType.INSTVAL)
			switch(opname) {
				case '<', case 'before',
				case '>', case 'after',
				case 'starts',
				case 'finishes',
				case 'during' : true
				default: false
			}
		else {
			val msg = 'instantiated value or temporal point'
			checkType(ResultType.INSTVAL,left,leftExp,msg);
			checkType(ResultType.INSTVAL,right,rightExp,msg);
			true;
		}
		if (!ok)
			error(String.format("Incompatible operator '%s' between '%s' and '%s'",
				opname,formatType(left),formatType(right)),context,
				GhostValidator.TEMPOP_INCOMPATIBLE);
		return ResultType.TEMPORALEXP;
	}	

	protected def dispatch ResultType eval(TimePointOp exp) {
		val value = eval(exp?.value);
		checkType(ResultType.INSTVAL,value,exp);
		return ResultType.TIMEPOINT;
	}

	protected def dispatch ResultType eval(QualifInstVal exp) {
		if (exp.arglist !== null)
			exp.arglist.values.forEach[eval];
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
		checkInvalidVarType(type,decl);
		checkSpecialInitValues(decl,type);
		return type;
	}
	
	protected def dispatch ResultType eval(FactGoal fact) {
		val type = eval(fact.value);
		checkFactGoalValue(fact,type);
		return type;
	}
	
	protected def dispatch ResultType eval(InheritedKwd kwd) {
		return ResultType.UNKNOWN;
	}
	
	protected def dispatch ResultType eval(PlaceHolder exp) {
		return ResultType.UNKNOWN;
	}
	
	protected def dispatch ResultType evalRef(SimpleType type) {
		if (type instanceof IntDecl)
			return ResultType.NUMERIC;
		if (type instanceof EnumDecl)
			return ResultType.ENUM;
		if (type.eIsProxy)
			return ResultType.UNKNOWN;
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
