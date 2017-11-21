/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
*/
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
		// Get data for from server
		var fromData = determineProvider( fromFormat, fromVersion )
			.read( from )
			.getMemento();
			
		// Get data for to server
		var toData = determineProvider( toFormat, toVersion )
			.read( to )
			.getMemento();
		 
		// List of all top level config props to inspect
		var configProps = wireBox.getInstance( 'BaseConfig@cfconfig-services' ).getConfigProperties();
		// An empty query object to hold our results
		var qryResult = queryNew( 'propertyName,fromValue,toValue,fromOnly,toOnly,bothPopulated,bothEmpty,valuesMatch,valuesDiffer' );
		// Recurse into these complex properties, but don't add them directly to the query+
		var specialColumns = [ 'RESTMappings', 'CFMappings', 'datasources', 'mailServers', 'caches', 'customTags', 'clientStorageLocations', 'loggers' ];
		
		compareStructs( qryResult, fromData, toData, configProps, specialColumns );
		
		return qryResult;
		 
	}
	
	/**
	* This is used internally by the diff() method to check two structs against each other 
	* with a specific set of keys. (Some keys might not exist in either struct).  It modifies
	* The qryResult object by reference and will climb down into nested structs.
	*
	* @qryResult A query object to add rows to
	* @fromData One of the structs to compare
	* @toData The other struct to compare
	* @configProps An array of all the struct keys to compare between both structs. Doesn't have to existin either struct
	* @ignoredKeys A list of keys to recurse into, but not to add to the main query result
	* @prefix A bit of text to prefix to the key name as we nest.
	*/	
	private function compareStructs( 
		required query qryResult,
		required struct fromData,
		required struct toData,
		required array configProps,
		required array ignoredKeys,
		string prefix='' ) {
		 var somethingWasDirty = false;
		 
		 for( var prop in configProps ) {
		 	var row = getDefaultRow( prefix & prop );
		 	
		 	// All keys are processed (and potentialy recursed into), but ignored ones aren't added to the query
		 	if( !ignoredKeys.findNoCase( prop ) ) {
		 		
				var tmp = compareValues(
					row,
					fromData,
					toData,
					prop,
					isSimpleValue( fromData[ prop ] ?: '' ) ? fromData[ prop ] ?: '' : prop,
					isSimpleValue( toData[ prop ] ?: '' ) ? toData[ prop ] ?: '' : prop
				);
				somethingWasDirty = somethingWasDirty || tmp;
			 	
		 	}
		 	
		 	// If this was a struct, compare its sub-members
		 	if(  (!isNull( toData[ prop ] ) && isStruct( toData[ prop ] ) )
		 		|| (!isNull( fromData[ prop ] ) && isStruct( fromData[ prop ] ) ) ) {
		 			 		
		 		// Prepare the new from and to structs
				var fromValue = fromData[ prop ] ?: {};
				var toValue = toData[ prop ] ?: {};
				// Get combined list of properties between both structs.
				// Yes, we're ignoring some mapping/datasource properties if they're not defined in both locations
				var combinedProps = {}.append( fromValue ).append( toValue ).keyArray();
				
				// Call back to myself.  This will add another record to the query for each key in these nested structs
				var tmp = compareStructs( qryResult, fromValue, toValue, combinedProps, [], prefix & prop & '-' );
				somethingWasDirty = somethingWasDirty || tmp;
				
				if( somethingWasDirty ) {
					row.valuesMatch = 0;
					row.valuesDiffer = 1;
				}
		 		if( !ignoredKeys.findNoCase( prop ) ) {
		 			qryResult.addRow( row );
		 		}
			
		 	// If this was an array (datasource), compare its sub-members		
	 		} else if(  (!isNull( toData[ prop ] ) && isArray( toData[ prop ] ) )
		 		|| (!isNull( fromData[ prop ] ) && isArray( fromData[ prop ] ) ) ) {
		 		
		 		if( !ignoredKeys.findNoCase( prop ) ) {
		 			qryResult.addRow( row );
		 		}
		 	
		 		// Prepare the new from and to structs
				var fromArr = fromData[ prop ] ?: [];
				var toArr = toData[ prop ] ?: [];
				
				// Loop as many times as the longest arrary
				var i=0;
				while( ++i <= max( fromArr.len(), toArr.len() ) ) {
					var fromStruct = fromArr[ i ] ?: {};
					var toStruct = toArr[ i ] ?: {};
					
					// Add a record for the entire mail server
				 	var row = getDefaultRow( '#prop#-#i#' );
					somethingWasDirty = compareValues(
						row,
						fromArr,
						toArr,
						i,
						( fromStruct.smtp ?: '' ) & ( !isNull( fromStruct.port ) ? ':' : '' ) & ( fromStruct.port ?: '' ),
						( toStruct.smtp ?: '' ) & ( !isNull( toStruct.port ) ? ':' : '' ) & ( toStruct.port ?: '' )
					);
					qryResult.addRow( row );
					
										
					// Get combined list of properties between both structs.
					// Yes, we're ignoring some mapping/datasource properties if they're not defined in both locations
					var combinedProps = {}.append( fromStruct ).append( toStruct ).keyArray();
					
					// Call back to myself.  This will add another record to the query for each key in these nested structs
					var tmp = compareStructs( qryResult, fromStruct, toStruct, combinedProps, [], '#prop#-#i#-' );
					somethingWasDirty = somethingWasDirty || tmp;
					
				}
					
	 		} else if( !ignoredKeys.findNoCase( prop ) ) {					
				qryResult.addRow( row );					
			} // end is array check
		 	
		 } // end while loop over properties
		 return somethingWasDirty;
	} // end function
	
	// Breaking this our for re-use and to keep function size down
	private function compareValues( 
		required struct row,
		required any fromData,
		required any toData,
		required string prop,
		required string fromName,
		required string toName
	 ) {
	 	var somethingWasDirty = true;
		 	
	 	// Doesn't exist in either.
	 	if( isNull( fromData[ prop ] ) && isNull( toData[ prop ] ) ) {
	 		row.bothEmpty = 1;
	 		somethingWasDirty = true;
	 	// Exists in both
	 	} else if( !isNull( fromData[ prop ] ) && !isNull( toData[ prop ] ) ) {
	 		row.bothPopulated = 1;
	 		// if the value isn't simple, just add the property name instead ( mapping or datasource names)
		 	row.fromValue = fromName;
		 	row.toValue = toName;
		 	
			if( isSimpleValue( fromData[ prop ] ) && isSimpleValue( toData[ prop ] ) ) {
			 	if( fromData[ prop ] == toData[ prop ] ) {
			 		row.valuesMatch = 1;
	 				somethingWasDirty = false;
			 	} else {
			 		row.valuesDiffer = 1;
			 	}
			 } else {
			 	// For complex values, this will be set "for real" after we've recursed into them
			 	row.valuesMatch = 1;
 				somethingWasDirty = false;
			 }
		// From only
	 	} else if( !isNull( fromData[ prop ] ) ) {
	 		// if the value isn't simple, just add the property name instead ( mapping or datasource names)
		 	row.fromValue = fromName;
	 		row.fromOnly = 1;
		// To only
	 	} else if( !isNull( toData[ prop ] ) ) {
	 		// if the value isn't simple, just add the property name instead ( mapping or datasource names)
		 	row.toValue = toName;
	 		row.toOnly = 1;	
	 	}
	 	return somethingWasDirty;
	}

	// A quick closure to return a fresh struct when we need it.
	private function getDefaultRow( prop ) {
		return {
			propertyName = prop,
		 	fromValue = '',
			toValue = '',
		 	fromOnly = 0,
		 	toOnly = 0,
		 	bothPopulated = 0,
		 	bothEmpty = 0,
		 	valuesMatch = 0,
		 	valuesDiffer = 0
		};
	}
	
}
