package it.cnr.istc.ghost.conversion

import com.google.inject.Inject
import it.cnr.istc.ghost.conversion.NumAndUnitValueConverter
import it.cnr.istc.ghost.ghost.NumAndUnit
import org.eclipse.xtext.nodemodel.util.NodeModelUtils

class NumAndUnitHelper {
	
	@Inject
	NumAndUnitValueConverter conv;
	
	def get(NumAndUnit num) {
		if (num === null)
			return 0l;
		if (num.value === null) {
			val node = NodeModelUtils.getNode(num);
			num.value = conv.toValue(node.text,node);
		}
		return num.value;
	}
}