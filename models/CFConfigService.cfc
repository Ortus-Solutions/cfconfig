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
	* 
	* @returns A concerete Config class such as JSONConfig, Adobe11, or Lucee5Server.
	* @throws cfconfigNoProviderFound if a provider isn't found that matches the format and version provided
	*/	
	function determineProvider( required string format, required string version ) {
		for( var thisProvider in getProviderRegistry() ) {
			if( arguments.format == thisProvider.format 
				&& semanticVersion.satisfies( arguments.version, thisProvider.version ) ) {
					return wirebox.getInstance( thisProvider.invocationPath );
				}
		}
		
		// We couldn't find a match
		throw( message="Sorry, no config provider could be found for [#format#@#version#].  Please be more specific or check your spelling.", type="cfconfigNoProviderFound" ); 
		
	}
	
	/**
	* Guess the engine format and version based on the CFHome path provided
	*
	* @CFHomePath The canonical path to the CF Home
	* 
	* @returns a struct containing the keys "format" and "version".  Format may be an empty string and version may be 0 if they can't be determined
	*/	
	function guessFormat( required string CFHomePath ) {
		
		// If the path is a JSON file, then we're doing JSON format
		if( right( CFHomePath, 5 ) == '.json' ) {
			return {
				format : 'JSON',
				version : 0
			};
		}
		
		var result = {
			format : '',
			version : 0
		};
		
		// If this is a directory and it exists
		if( directoryExists( CFHomePath ) ) {
			
			// Check for Adobe server
			if( fileExists( CFHomePath & '/lib/cfusion.jar' ) ) {
				result.format = 'adobe';
				
				// Now that we know it's Adobe, try and detect version
				if( fileExists( CFHomePath & '/bin/cf-init.sh' ) ) {
					var initContents = fileRead( CFHomePath & '/bin/cf-init.sh' );
					var findVersion = initContents.reFind( '.*VERSION="([0-9]*)".*', 1, true );
					if( findVersion.pos.len() > 1 && findVersion.pos[ 2 ] ) {
						result.version = initContents.mid( findVersion.pos[ 2 ], findVersion.len[ 2 ] );
					}
				} else {
					// Potential backup approaches here if the file above doesn't exist.
				}
				
				return result;
			}
			
			// Check for Lucee web context
			if( fileExists( CFHomePath & '/lucee-web.xml.cfm' ) ) {
				result.format = 'luceeWeb';
				result.version = getLuceeVersionFromConfig( CFHomePath & '/lucee-web.xml.cfm' );
				return result;
			}			
			
			// Check for Lucee server context
			if( fileExists( CFHomePath & '/context/lucee-server.xml' ) ) {
				result.format = 'luceeServer';
				result.version = getLuceeVersionFromConfig( CFHomePath & '/context/lucee-server.xml' );
				return result;
			}
			
			
		}
		
		// We couldn't find a match
		return result;		
	}
	
	/**
	* Try to read the Lucee version from the config file
	*
	* @configPath Path to Lucee's XML Config file
	*/		
	private function getLuceeVersionFromConfig( required string configPath ) {
		if( fileExists( configPath ) ) {
			var rawConfig = fileRead( configPath );
			if( isXML( rawConfig ) ) {
				var XMLConfig = XMLParse( rawConfig );
				if( isDefined( 'XMLConfig.XMLRoot.XMLAttributes.version' ) ) {
					// This is the loader version, not the core version, but the "major" number will be the same.  
					return val( listFirst( XMLConfig.XMLRoot.XMLAttributes.version, '.' ) );
				}
			}
		}
		return 0;
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
	
	/**
	* Diff configs between two locations
	*
	* @from server home path, or CFConfig JSON file
	* @to server home path, or CFConfig JSON file
	* @fromFormat The format to read from, or "JSON"
	* @toFormat The format to write to, or "JSON"
	* @fromVersion The version of the fromFormat to target
	* @toVersion The version of the toFormat to target
	*
	* @returns query
	*/	
	query function diff( 
		required string from,
		required string to,
		required string fromFormat,
		required string toFormat,
		string fromVersion='0',
		string toVersion='0'
	) {
		
		var fromData = determineProvider( fromFormat, fromVersion )
			.read( from )
			.getMemento();
			
		var toData = determineProvider( toFormat, toVersion )
			.read( to )
			.getMemento();
		 
		var configProps = wireBox.getInstance( 'BaseConfig@cfconfig-services' ).getConfigProperties();		 
		var qryResult = queryNew( 'propertyName,fromValue,toValue,fromOnly,toOnly,bothPopulated,bothEmpty,valuesMatch,valuesDiffer' );
		var specialColumns = [ 'CFMappings', 'datasources', 'mailServers', 'caches', 'customTags' ];
		
		compareStructs( qryResult, fromData, toData, configProps, specialColumns );
		
		return qryResult;
		 
	}
	
	private function compareStructs( qryResult, fromData, toData, configProps, ignoredKeys, prefix='' ) {
		var getDefaultRow = function( prop ) { return {
			propertyName = prop,
		 	fromValue = '',
			toValue = '',
		 	fromOnly = 0,
		 	toOnly = 0,
		 	bothPopulated = 0,
		 	bothEmpty = 0,
		 	valuesMatch = 0,
		 	valuesDiffer = 0
		}; };
		 
		 for( var prop in configProps ) {
		 	var row = getDefaultRow( prefix & prop );
		 	
		 	// Doesn't exist in either.
		 	if( isNull( fromData[ prop ] ) && isNull( toData[ prop ] ) ) {
		 		row.bothEmpty = 1;
		 	// Exists in both
		 	} else if( !isNull( fromData[ prop ] ) && !isNull( toData[ prop ] ) ) {
		 		row.bothPopulated = 1;
			 	row.fromValue = fromData[ prop ];
			 	row.toValue = toData[ prop ];
			 	
			 	if( serializeJSON( row.fromValue ) == serializeJSON( row.toValue ) ) {
			 		row.valuesMatch = 1;
			 	} else {
			 		row.valuesDiffer = 1;
			 	}
			// From only
		 	} else if( !isNull( fromData[ prop ] ) ) {
		 		row.fromValue = fromData[ prop ];
		 		row.fromOnly = 1;
			// To only
		 	} else if( !isNull( toData[ prop ] ) ) {
		 		row.toValue = toData[ prop ];
		 		row.toOnly = 1;	
		 	}
		 	
		 	if( !ignoredKeys.findNoCase( prop ) ) {
		 		qryResult.addRow( row );
		 	}
		 	
		 	// If this was a struct, compare its sub-members
		 	if(  (!isNull( toData[ prop ] ) && isStruct( toData[ prop ] ) )
		 		|| (!isNull( fromData[ prop ] ) && isStruct( fromData[ prop ] ) ) ) {
		 	
				var fromValue = fromData[ prop ] ?: {};
				var toValue = toData[ prop ] ?: {};
				var combinedProps = {}.append( fromValue ).append( toValue ).keyArray();
				compareStructs( qryResult, fromValue, toValue, combinedProps, [], prefix & prop & '-' );		
	 		}
		 	
		 }
	}
	
}