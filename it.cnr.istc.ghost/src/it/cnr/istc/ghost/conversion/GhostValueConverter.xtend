package it.cnr.istc.ghost.conversion

import org.eclipse.xtext.conversion.ValueConverter
import org.eclipse.xtext.conversion.IValueConverter
import com.google.inject.Inject
import org.eclipse.xtext.common.services.DefaultTerminalConverters

class GhostValueConverter extends DefaultTerminalConverters {
	
//	@Inject
//	private NumberValueConverter numConverter;
//	
//	@ValueConverter(rule = "it.cnr.istc.ghost.Ghost.PosNumber")
//    def IValueConverter<Long> getPosNumberValueConverter() {
//        return numConverter;
//    }
//    
//	@ValueConverter(rule = "it.cnr.istc.ghost.Ghost.NegNumber")
//    def IValueConverter<Long> getNegNumberValueConverter() {
//        return numConverter;
//    }
    
	@Inject
	private NumAndUnitValueConverter numAndUnitConverter;
	
	@ValueConverter(rule = "it.cnr.istc.ghost.Ghost.NumAndUnit")
    def IValueConverter<Long> getNumAndUnitValueConverter() {
        return numAndUnitConverter;
    }
}
