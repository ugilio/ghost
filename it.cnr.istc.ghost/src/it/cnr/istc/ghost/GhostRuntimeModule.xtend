/*
 * generated by Xtext 2.10.0
 */
package it.cnr.istc.ghost

import it.cnr.istc.ghost.naming.GhostQualifiedNameProvider
import com.google.inject.Binder
import org.eclipse.xtext.scoping.IScopeProvider
import com.google.inject.name.Names
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import it.cnr.istc.ghost.scoping.GhostImportScopeProvider
import it.cnr.istc.ghost.scoping.GhostResourceDescriptionStrategy
import org.eclipse.xtext.resource.IDefaultResourceDescriptionStrategy
import it.cnr.istc.ghost.conversion.GhostValueConverter

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
class GhostRuntimeModule extends AbstractGhostRuntimeModule {

	override bindIQualifiedNameProvider() {
		return GhostQualifiedNameProvider;
	}

	override configureIScopeProviderDelegate(Binder binder) {
		binder.bind(IScopeProvider).annotatedWith(Names.named(AbstractDeclarativeScopeProvider.NAMED_DELEGATE)).to(GhostImportScopeProvider);
	}

	def Class<? extends IDefaultResourceDescriptionStrategy> bindIDefaultResourceDescriptionStrategy() {
		return GhostResourceDescriptionStrategy;
	}

	override bindIValueConverterService() {
		return GhostValueConverter;
	}
}
