package it.cnr.istc.ghost.validation;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

public class AbstractExpressionValidator {
	
	public static enum ResultType {
		UNKNOWN("unknown"),
		NUMERIC("numeric"),
		ENUM("enum"),
		BOOLEAN("boolean"),
		//"complex types"
		INSTVAL("instantiated value"),
		TEMPORALEXP("temporal expression");
		
		private String desc;
		
		private ResultType(String desc) {
			this.desc = desc;
		}
		
		public String getDescription() {
			return desc;
		}
	}
	
	@FunctionalInterface
	public interface ErrMsgFunction {
		public void error(String message, EObject source, EStructuralFeature feature, int index, String code,
				String... issueData);
	}
	
	@FunctionalInterface
	public interface WarnMsgFunction {
		public void warning(String message, EObject source, EStructuralFeature feature, int index, String code,
				String... issueData);
	}
}
