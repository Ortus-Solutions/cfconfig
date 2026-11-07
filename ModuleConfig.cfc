/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
* 
*/
component {
	
	this.title 				= "CFConfig Services";
	this.modelNamespace		= "cfconfig-services";
	this.cfmapping			= "cfconfig-services";
	// Models are mapped lazily in configure() instead.  autoMapModels makes WireBox read the full
	// inherited metadata of every model (including all providers, which extend the very large
	// BaseConfig) as soon as the module loads, which costs ~500ms on every CommandBox start.
	this.autoMapModels		= false;
	// Need these loaded up first so I can do my job.
	this.dependencies 		= [ 'PropertyFile','lucee-password-util','adobe-password-util' ];

	function configure() {
		settings = {
			"redisCachePasswordAlwaysPlainText" : false
		};

		// Register the same names autoMapModels would (Foo@cfconfig-services) as DSL aliases to the CFC path.
		// DSL mappings need no metadata inspection, so the CFC is only inspected the first time it's actually requested.
		var packages = {
			'cfconfig-services.models' : modulePath & '/models',
			'cfconfig-services.models.providers' : modulePath & '/models/providers'
		};
		for( var packagePath in packages ) {
			for( var fileName in directoryList( packages[ packagePath ], false, 'name', '*.cfc' ) ) {
				var modelName = fileName.listFirst( '.' );
				binder.map( '#modelName#@cfconfig-services' ).toDSL( 'model:#packagePath#.#modelName#' );
			}
		}
	}
}