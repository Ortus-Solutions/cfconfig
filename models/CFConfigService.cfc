component accessors=true singleton {
	
	property name='providerRegistry';
	
	// DI	
	property name='semanticVersion' inject='semanticVersion@semver';
	property name='wirebox' inject='wirebox';
	
	function init() {
		setProviderRegistry( [] );
		
		buildProviderRegistry( '/cfconfig-services/models/providers' );
	}
	
	/**
	* Register all the CFCs in a directory
	*/
	function buildProviderRegistry( string providerDirectory ) {
		var providerRegistry = getProviderRegistry();
		
		for( var thisFile in directoryList( path=providerDirectory, filter='*.cfc' ) ) {
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
			format = oProvider.getFormat(),
			version = oProvider.getVersion(),
			invocationPath = providerInvocationPath
		} );
	}
	
	/**
	* Find the matching config provider based on the format name and version you want to interact with
	*
	* @format Name of format such as 'adobe', 'luceeWeb', or 'luceeServer'
	* @versionName The version of the format you want to interact with. 11 is turned into 11.0.0
	*/	
	function determineProvider( required string format, required string version ) {
		for( var thisProvider in getProviderRegistry() ) {
			if( arguments.format == thisProvider.format 
				&& semanticVersion.satisfies( arguments.version, thisProvider.version ) ) {
					return wirebox.getInstance( thisProvider.invocationPath );
				}
		}
		
		// We couldn't find a match
		throw( message="Sorry, no config provider could be found for [#format#@#version#]", type="cfconfigNoProviderFound" ); 
		
	}
	
	
	/**
	* Transfer config from one location to another
	*
	* @from server home path, or CFConfig JSON file
	* @to server home path, or CFConfig JSON file
	* @fromFormat The format to read from, or "JSON"
	* @toFormat The format to write to, or "JSON"
	* @fromVersion The version of the fromFormat to target
	* @toVersion The version of the toFormat to target
	*/	
	function transfer( 
		required string from,
		required string to,
		required string fromFormat,
		required string toFormat,
		string fromVersion='0',
		string toVersion='0'
	) {
		 var oFrom = determineProvider( fromFormat, fromVersion ).read( from );
		 
		 var oTo = determineProvider( toFormat, toVersion )
		 	.setMemento( oFrom.getMemento() )
		 	.write( to );
		 
	}
	
}