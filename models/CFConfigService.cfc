component accessors=true singleton {
	
	property name='providerRegistry';
	
	// DI	
	property name='semanticVersion' inject='semanticVersion@semver';
	
	function init() {
		setProviderRegistry( [] );
		
		buildProviderRegistry( '/cfconfig-services/models/providers' );
	}
	
	/**
	* Register all the CFCs in a directory
	*/
	function buildProviderRegistry( string providerDirectory ) {
		var providerRegistry = getProviderRegistry();
		
		for( var thisFile in directoryList( providerDirectory ) ) {
			registerProvider( providerDirectory.listChangeDelims( '.', '/\' ) & '.' & thisFile.listLast( '/\' ).listFirst( '.' ) );
		}
	}
	
	/**
	* Register a specific CFC by invocation path
	*/
	function registerProvider( string providerInvocationPath ) {
		var providerRegistry = getProviderRegistry();
		var oProvider = createObject( 'component', providerInvocationPath ).init();
		
		// Add to start of array so providers registered later will take precendence
		providerRegistry.prepend( {
			engine = oProvider.getEngine(),
			version = oProvider.getVersion(),
			invocationPath = providerInvocationPath
		} );
	}
	
	/**
	* Find the matching config provider based on the engine name and version you want to interact with
	*
	* @engine Name of engine such as 'adobe', 'luceeWeb', or 'luceeServer'
	* @versionName The version of the engine you want to interact with. 11 is turned into 11.0.0
	*/	
	function determineProvider( required string engine, required string version ) {
		for( var thisProvider in getProviderRegistry() ) {
			if( arguments.engine == thisProvider.engine 
				&& semanticVersion.satisfies( arguments.version, thisProvider.version ) ) {
					return createObject( 'component', thisProvider.invocationPath ).init();
				}
		}
		
		// We couldn't find a match
		throw( message="Sorry, no config provider could be found for [#engine#@#version#]", type="cfconfigNoProviderFound" ); 
		
	}
	
}