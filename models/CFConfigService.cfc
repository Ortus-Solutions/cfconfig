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
	* @format Name of format such as 'adobe', 'luceeWeb', or 'luceeServer', or 'boxlang'
	* @versionName The version of the format you want to interact with. 11 is turned into 11.0.0
	*
	* @returns A concerete Config class such as JSONConfig, Adobe11, or Lucee5Server, or BoxLang1.
	* @throws cfconfigNoProviderFound if a provider isn't found that matches the format and version provided
	*/
	function determineProvider( required string format, required string version ) {

		// If there is no version, just grab the latest for this format.
		if( trim( format ).len() &&  ( !trim( version ).len() || version == '0' ) ) {
			return getLastestProvider( format );
		}

		// Otherwise, loop over all providers and find the first match.
		for( var thisProvider in getProviderRegistry() ) {
			// Remove prerelease id so non-stable engines can still match our provider ranges.
			var cleanedVersionStruct = semanticVersion.parseVersion( arguments.version );
			cleanedVersionStruct.delete( 'preReleaseID' );
			var cleanedVersion = semanticVersion.getVersionAsString( cleanedVersionStruct );

			if( arguments.format == thisProvider.format
				&& semanticVersion.satisfies( cleanedVersion, thisProvider.version  ) ) {
					return wirebox.getInstance( thisProvider.invocationPath );
				}
		}

		// We couldn't find a match
		throw( message="Sorry, no config provider could be found for [#format#@#version#].  Please be more specific or check your spelling.", type="cfconfigNoProviderFound" );

	}

	/**
	* Find the config provider for the given format with the highest version.
	*
	* @format Name of format such as 'adobe', 'luceeWeb', or 'luceeServer', or 'boxlang'
	*
	* @returns A concerete Config class such as JSONConfig, Adobe11, or Lucee5Server.
	* @throws cfconfigNoProviderFound if a provider isn't found that matches the format and version provided
	*/
	function getLastestProvider( required string format ) {
		var maxVersion = '0';
		var matchedProviderPath = '';
		// Loop over all providers
		for( var thisProvider in getProviderRegistry() ) {
			// If this provider matches the format AND is newer than any previously-found provider, then it's our man.... for now.
			if( arguments.format == thisProvider.format
				&& ( thisProvider.version == '*' ||
				 semanticVersion.isNew( maxVersion, thisProvider.version  ) ) ) {
					matchedProviderPath = thisProvider.invocationPath;
					maxVersion = thisProvider.version;
				}
		}

		// We couldn't find a match
		if( !len( matchedProviderPath ) ) {
			throw( message="Sorry, no config provider could be found for [#format#].  Please be more specific or check your spelling.", type="cfconfigNoProviderFound" );
		}

		return wirebox.getInstance( matchedProviderPath );
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
		// Check a JSON file ext as well as an existing file that contains valid JSON.
		if( right( CFHomePath, 5 ) == '.json' ||
			( fileExists( CFHomePath ) && isJSON( fileRead( CFHomePath ) ) ) ) {
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

			// Check for BoxLang Server
			if( fileExists( CFHomePath & '/boxlang.json' ) ) {
				result.format = 'boxlang';
				result.version = 1;
				// look for a version.properties files up one directory and read the `version` property from it
				var boxlangVersionFile = expandPath( CFHomePath & '/../version.properties' )
				if( fileExists( boxlangVersionFile ) ) {					
					var pf = wirebox.getInstance( 'propertyFile@propertyFile' );
					pf.load( dotenvFile );
					result.version = pf.get( 'version', 1 );
				}
				return result;
			}

			// Check for Adobe server
			if( fileExists( CFHomePath & '/lib/cfusion.jar' ) OR fileExists( CFHomePath & '/lib/neo-runtime.xml' ) ) {
				result.format = 'adobe';

				// Now that we know it's Adobe, try and detect version
				if( fileExists( CFHomePath & '/bin/cf-init.sh' ) || fileExists( CFHomePath & '/bin/cf-init-run.sh' ) ) {
					var initContents = fileExists( CFHomePath & '/bin/cf-init.sh' ) ? fileRead( CFHomePath & '/bin/cf-init.sh' ) : fileRead( CFHomePath & '/bin/cf-init-run.sh' );
					var findVersion = initContents.reFind( '.*VERSION="([0-9]*)".*', 1, true );
					if( findVersion.pos.len() > 1 && findVersion.pos[ 2 ] ) {
						result.version = initContents.mid( findVersion.pos[ 2 ], findVersion.len[ 2 ] );
						return result;
					}
				}

				// Fallback approach-- guess the version from the path
				// See if the path looks like C:/coldfusion11/cfusion
				// Or C:/CF2016
				// Or C:/adobe11
				var findresults = CFHomePath.reFindNoCase( '[\\/](coldfusion|adobe|cf)([0-9]{1,4})[\\/]', 1, true );
				if( findresults.len.len() == 3 ) {
					// Strip the version number out
					result.version = CFHomePath.mid( findresults.pos[ 3 ], findresults.len[ 3 ] );
					return result;
				}

				// Try it for commandbox installations such as:
				// /server/8E5DBEA3AEE9FFF981F5C9A927DE02B7-adobeiistest/adobe-2016.0.05.303689/WEB-INF/cfusion
				var findresults = CFHomePath.reFindNoCase( '[\\/]server[\\/].*[\\/]adobe-([0-9]{1,4})\.', 1, true );
				if( findresults.len.len() == 2 ) {
				// Strip the version number out
					result.version = CFHomePath.mid( findresults.pos[ 2 ], findresults.len[ 2 ] );
					return result;
				}

				// Give up on Adobe version. Just return 0
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
	* @pauseTasks Set to try to pause all scheduled tasks on import
	* @includeList List of properties to include in transfer
	* @excludeList List of properties to exclude from transfer
	* @replace A struct of regex/replacement matches to swap data with env var expansions
	* @dotenvFile Absolute path to .env file for replace feature. Empty string turns off feature.
	* @append Append config to destination instead of overwriting
	*/
	function transfer(
		required string from,
		required string to,
		required string fromFormat,
		required string toFormat,
		string fromVersion='0',
		string toVersion='0',
		boolean pauseTasks=false,
		string includeList='',
		string excludeList='',
		struct replace={},
		string dotenvFile='',
		boolean append=false
	) {
		 var oFrom = determineProvider( fromFormat, fromVersion ).read( from );
		 var oTo = determineProvider( toFormat, toVersion );

		 if( oTo.getFormat() != 'JSON' && replace.count() ) {
		 	throw( message='You can only use "replace" when your "to" destination is JSON.', type='cfconfigException' );
		 }

		 var memento = oFrom.getMemento();

		 // Skip this logic if we're not using it
		 if( len( includeList ) || len( excludeList ) || replace.count() ) {
		 	var includes = includeList.listToArray().map( (e)=>'^' & escapeRegex( toBracketNotation( e ) ).replace( '**', '__deep_match__', 'all' ).replace( '*', '[^\[]*', 'all' ).replace( '__deep_match__', '.*', 'all' ) );
		 	// excludes must be full match, so we include $ at the end of the regex
		 	var excludes = excludeList.listToArray().map( (e)=>'^' & escapeRegex( toBracketNotation( e ) ).replace( '**', '__deep_match__', 'all' ).replace( '*', '[^\[]*', 'all' ).replace( '__deep_match__', '.*', 'all' ) & '$' );
		 	var JSONExpansions = replace;
		 	var envVars = {};
		 	// Do a single recursive traversal of data, and pricess includes, excludes and env var replacements all at once.
		 	memento = processFilters( memento, includes, excludes, JSONExpansions, envVars );
		 	// If we have env vars, write them out to the .env file (appending if it exists)
		 	if( envVars.count() && len( dotenvFile ) ) {
		 		var pf = wirebox.getInstance( 'propertyFile@propertyFile' );
				if( fileExists( dotenvFile ) ){
					pf.load( dotenvFile );
				}
		 		structAppend( pf, envVars, true );
		 		pf.store( dotenvFile );
		 	}

		 }
		 // Append loads config on top of existing config (if it exists)
		 if( append && oTo.CFHomePathExists( to ) ) {
		 	oTo
		 	.read( to )
		 	.mergeMemento( memento );
		 // non-append does a full overwrite
		 } else {
		 	oTo.setMemento( memento );
		 }

		 oTo.write( to, pauseTasks );
	}

	/**
	* Apply includes and excludes to a memento struct.
	*
	* @memento struct of config
	* @includes list of properties to include
	* @excludes list of properties to exclude
	*
	* @returns query
	*/
	function processFilters(
		required memento,
		includes=[],
		excludes=[],
		JSONExpansions={},
		envVars={},
		safeProp='',
		prop=''
	) {
		// If this is a struct, loop over each key
		if( isStruct( memento ) ) {
			var newMemento={};
			for( var theProp in memento ) {
				// Build up a recursive property like ['foo']['bar']
				var thisSafeProp = "#safeProp#['#theProp#']";
				var thisProp = prop.listAppend( theProp, '.' );
				// Check to see if this propery should be included, and if so find it's inner value.
				if( var includeFlag = includeProp( thisSafeProp, memento[ theProp ], includes, excludes ) ) {
					newMemento[ theProp ] = processFilters( memento[ theProp ], includes, excludes, JSONExpansions, envVars, thisSafeProp, thisProp );
				}
				// If this key was included presumptuously, but all inner keys were excluded, remove this propery
				if( includeFlag == 2 && ( isStruct( newMemento[ theProp ] ) || isArray( newMemento[ theProp ] ) ) && isEmpty( newMemento[ theProp ] ) ) {
					newMemento.delete( theProp );
				}
			}
			return newMemento;
		}
		// If this is an array, loop over each element
		if( isArray( memento ) ) {
			var newMemento=[];
			var i = 0;
			while( ++i <= memento.len() ) {
				// Build up a recursive property like ['foo']['1']
				var thisSafeProp = "#safeProp#['#i#']";
				var thisProp = "#prop#[#i#]";
				// Check to see if this propery should be included, and if so find it's inner value.
				if( var includeFlag = includeProp( thisSafeProp, memento[ i ], includes, excludes ) ) {
					newMemento.append( processFilters( memento[ i ], includes, excludes, JSONExpansions, envVars, thisSafeProp, thisProp ) );
				}
				// If this key was included presumptuously, but all inner keys were excluded, remove this propery
				if( includeFlag == 2 && ( isStruct( newMemento.last() ) || isArray( newMemento.last() ) ) && isEmpty( newMemento.last() ) ) {
					newMemento.deleteAt( newMemento.len() );
				}
			}
			return newMemento;
		}

		// Simple values-- not an array or a struct
		return replaceProp( prop, memento, JSONExpansions, envVars );
	}

	/**
	* Decide whether to include a propery based on include and excludes.
	* @returns 0 if excluded, 1 if explicitly included, 2 if presumptuously included due to matching a leading portion of an include rule
	*/
	private function includeProp( safeProp, value, includes, excludes ) {

		// If we match an exclude rule, stop here.
		if( excludes.len() ) {
			for( var exclude in excludes ) {
				if( reFindNoCase( exclude, safeProp ) ) {
					return 0;
				}
			}
		}
		// If we have includes, let's check them
		if( includes.len() ) {
			safeProp = lcase( safeProp );
			for( var include in includes ) {
				// An explicit match for a full rule
				if( reFindNoCase( include, safeProp ) ) {
					return 1;
				}
				// Look for partial matches to presumptuously include. This key will be deleted later if it doesn't produce any nested data.
				while( !isSimpleValue( value ) && findNoCase( "']\['", include ) ) {
					var pos = include.reverse().findNoCase( "'[\]'" );
					// Strip off the last match group and try again.
					include = include.reverse().right( -(pos+2) ).reverse() & '$';
					if( reFindNoCase( include, safeProp ) ) {
						return 2;
					}
				}
			}
			// If we have include rules and we didn't match anything, then don't use
			return 0;
		}
		// If there were no explicit includes, then allow
		return 1;

	}

	/**
	* Replace value with an env var expansion based on regex mappings
	*/
	private function replaceProp( prop, memento, JSONExpansions, envVars ) {
		if( !JSONExpansions.count() ) {
			return memento;
		}
		for( var expansion in JSONExpansions ) {
			var replacement = JSONExpansions[ expansion ];
			expansion = '^' & expansion & '$';
			if( reFindNoCase( expansion, prop ) ) {
				// If the user didn't supply an env var name, make up a convincing one
				if( !len( replacement ) ) {
					var newValue = prop
						// turn foo.bar into FOO_BAR
						.replace( '.', '_', 'all' )
						// Turn foo[1].bar into FOO_BAR
						.reReplace( '\[([0-9]+)]', '_\1', 'all' )
						// turn fooBar into FOO_BAR
						.reReplace( '([a-z])([A-Z])', '\1_\2', 'all' )
						// Shorten some common use cases
						.replaceNoCase( 'datasources_', 'DB_', 'all' )
						.replaceNoCase( 'mailservers_', 'mail_', 'all' )
						.replaceNoCase( 'caches_', 'cache_', 'all' )
						.replaceNoCase( 'customTagPaths_', 'customTag_', 'all' )
						.replaceNoCase( 'eventGatewaysLucee_', 'eventGateway_', 'all' )
						.replaceNoCase( 'PDFServiceManagers_', 'PDFService_', 'all' )
						// Upper case it all!
						.uCase();
					envVars[ newValue ] = memento;
					return '${' & newValue & '}';
				// Otherwise, use what the user gave us
				} else {
					var newValue = reReplaceNoCase( prop, expansion, replacement ).ucase();
					envVars[ newValue.listFirst( ':' ) ] = memento;
					return '${' & newValue & '}';
				}

			}

		}
		return memento;
	}

	/**
	* Escape regex metacharacters in a string so it's safe
	* We're note esacping "*" since that means something special and we'll handle it later
	*/
	function escapeRegex( required string str ) {
		// Escape any regex metacharacters in the pattern
		str = replace( str, '\', '\\', 'all' );
		str = replace( str, '.', '\.', 'all' );
		str = replace( str, '(', '\(', 'all' );
		str = replace( str, ')', '\)', 'all' );
		str = replace( str, '^', '\^', 'all' );
		str = replace( str, '$', '\$', 'all' );
		str = replace( str, '|', '\|', 'all' );
		str = replace( str, '+', '\+', 'all' );
		str = replace( str, '{', '\{', 'all' );
		str = replace( str, '[', '\[', 'all' );
		return replace( str, '}', '\}', 'all' );
	}

	// Convert foo.bar-baz['1'] to ['foo']['bar-baz']['1']
	private function toBracketNotation( required string property ) {
		var tmpProperty = replace( arguments.property, '[', '.[', 'all' );
		tmpProperty = replace( tmpProperty, ']', '].', 'all' );
		var fullPropertyName = '';
		for( var item in listToArray( tmpProperty, '.' ) ) {
			if( item.startsWith( '[' ) && item.endsWith( ']' ) ) {
				var innerItem = item.right(-1).left(-1);
				// ensure foo[bar] becomes foo["bar"] and foo["bar"] stays that way
				innerItem = unwrapQuotes( trim( innerItem ) );
				fullPropertyName &= "['#innerItem#']";
			} else {
				fullPropertyName &= "['#item#']";
			}
		}
		return fullPropertyName;
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
		string toVersion='0',
		boolean emptyIsUndefined=false
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
		var qryResult = queryNew( 'propertyName,fromValue,toValue,fromOnly,toOnly,bothPopulated,bothEmpty,valuesMatch,valuesDiffer,complex' );

		compareStructs( qryResult, fromData, toData, configProps, [], '', emptyIsUndefined );

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
		string prefix='',
		boolean emptyIsUndefined=false ) {
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
					isSimpleValue( toData[ prop ] ?: '' ) ? toData[ prop ] ?: '' : prop,
					emptyIsUndefined
				);
				somethingWasDirty = somethingWasDirty || tmp;

		 	}

		 	// If this was a struct, compare its sub-members
		 	if(  (!isNull( toData[ prop ] ) && isStruct( toData[ prop ] ) )
		 		|| (!isNull( fromData[ prop ] ) && isStruct( fromData[ prop ] ) ) ) {

				row.complex = 1;

		 		// Prepare the new from and to structs
				var fromValue = fromData[ prop ] ?: {};
				var toValue = toData[ prop ] ?: {};
				// Get combined list of properties between both structs.
				// Yes, we're ignoring some mapping/datasource properties if they're not defined in both locations
				var combinedProps = {}.append( fromValue ).append( toValue ).keyArray();

				// Call back to myself.  This will add another record to the query for each key in these nested structs
				var tmp = compareStructs( qryResult, fromValue, toValue, combinedProps, [], prefix & prop & '-', emptyIsUndefined );
				somethingWasDirty = somethingWasDirty || tmp;

				if( tmp ) {
					row.valuesMatch = 0;
					// If to doesn't exist, it's from only
					if( isNull( toData[ prop ] ) ) {
						row.fromOnly = 1;
					// If from doesn't exist, it's to only
					} else if( isNull( fromData[ prop ] ) ) {
						row.toOnly = 1;
					// Otherwise, it's just different!
					} else {
						row.valuesDiffer = 1;
					}
				}
		 		if( !ignoredKeys.findNoCase( prop ) ) {
		 			qryResult.addRow( row );
		 		}

		 	// If this was an array (datasource), compare its sub-members
	 		} else if(  (!isNull( toData[ prop ] ) && isArray( toData[ prop ] ) )
		 		|| (!isNull( fromData[ prop ] ) && isArray( fromData[ prop ] ) ) ) {

		 		var arrayRow = row;

		 		// Prepare the new from and to structs
				var fromArr = fromData[ prop ] ?: [];
				var toArr = toData[ prop ] ?: [];

				var arrayWasDirty=false;

				// Loop as many times as the longest arrary
				var i=0;
				while( ++i <= max( fromArr.len(), toArr.len() ) ) {
					// At least one of the arrays has an element, so test the first one for a type.
					var defaultValue = isSimpleValue( fromArr[ 1 ] ?: toArr[ 1 ] ) ? '' : {};
					var fromValue = fromArr[ i ] ?: defaultValue;
					var toValue = toArr[ i ] ?: defaultValue;

					// If this type is complex
					if( isStruct( toValue ) && isStruct( fromValue ) ) {

						var row = getDefaultRow( '#prefix##prop#-#numberFormat( i, "09" )#' );

						// Add a record for the entire mail server
						somethingWasDirty = compareValues(
							row,
							fromArr,
							toArr,
							i,
							generateDefaultStructName( fromValue, prop ),
							generateDefaultStructName( toValue, prop ),
							emptyIsUndefined
						);

						qryResult.addRow( row );

						// Get combined list of properties between both structs.
						// Yes, we're ignoring some mapping/datasource properties if they're not defined in both locations
						var combinedProps = {}.append( fromValue ).append( toValue ).keyArray();

						// Call back to myself.  This will add another record to the query for each key in these nested structs
						var tmp = compareStructs( qryResult, fromValue, toValue, combinedProps, [], '#prefix##prop#-#numberFormat( i, "09" )#-', emptyIsUndefined );
						somethingWasDirty = somethingWasDirty || tmp;

					} else if( isSimpleValue( toValue ) && isSimpleValue( fromValue ) ) {
						var row = getDefaultRow( '#prefix##prop#-#numberFormat( i, "09" )#' );

						// Compare a simple value in the array
						var tmp = compareValues(
							row,
							fromArr,
							toArr,
							i,
							fromValue,
							toValue,
							emptyIsUndefined
						);
						arrayWasDirty = arrayWasDirty || tmp;
						qryResult.addRow( row );
					}

				} // End loop over array

		 		if( !ignoredKeys.findNoCase( prop ) ) {
					if( isNull( toData[ prop ] ) ) {
						arrayRow.valuesMatch = 0;
						arrayRow.fromOnly = 1;
					} else if( isNull( fromData[ prop ] ) ) {
						arrayRow.valuesMatch = 0;
						arrayRow.toOnly = 1;
					} else if( arrayWasDirty ) {
						arrayRow.valuesMatch = 0;
						arrayRow.valuesDiffer = 1;
					}
					arrayRow.complex = 1;
		 			qryResult.addRow( arrayRow );
		 		}

	 		} else if( !ignoredKeys.findNoCase( prop ) ) {
				qryResult.addRow( row );
			} // end is array check

		 } // end while loop over properties
		 return somethingWasDirty;
	} // end function

	// Breaking this out for re-use and to keep function size down
	private function compareValues(
		required struct row,
		required any fromData,
		required any toData,
		required string prop,
		required string fromName,
		required string toName,
		boolean emptyIsUndefined=false
	 ) {
	 	var somethingWasDirty = true;

	 	// Doesn't exist in either.
	 	if( isNull( fromData[ prop ] ) && isNull( toData[ prop ] ) ) {
	 		row.bothEmpty = 1;
	 		somethingWasDirty = false;
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

	 		if( emptyIsUndefined && isSimpleValue( fromData[ prop ] ) && trim( fromData[ prop ] ) == '' ) {
		 		row.valuesMatch = 1;
				somethingWasDirty = false;
	 		} else {
		 		// if the value isn't simple, just add the property name instead ( mapping or datasource names)
			 	row.fromValue = fromName;
		 		row.fromOnly = 1;
	 		}

		// To only
	 	} else if( !isNull( toData[ prop ] ) ) {

	 		if( emptyIsUndefined && isSimpleValue( toData[ prop ] ) && trim( toData[ prop ] ) == '' ) {
		 		row.valuesMatch = 1;
				somethingWasDirty = false;
	 		} else {
		 		// if the value isn't simple, just add the property name instead ( mapping or datasource names)
			 	row.toValue = toName;
		 		row.toOnly = 1;
	 		}

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
		 	valuesDiffer = 0,
		 	complex = 0
		};
	}

	private function generateDefaultStructName( struct data, string type ) {
		if( type == 'mailServers' ) {
			return ( data.smtp ?: '' ) & ( !isNull( data.port ) ? ':' : '' ) & ( data.port ?: '' );
		} else if( type == 'eventGatewayConfigurations' ) {
			return ( data.class ?: '' ).listLast( '.' );
		} else if( type == 'eventGatewayInstances' ) {
			return data.gatewayId ?: '';
		} else if( type == 'cfcPaths' ) {
			return '';
		} else {
			return 'N/A';
		}
	}

	function unwrapQuotes( theString ) {
		// If the value is wrapped with backticks, leave them be.  That is a signal to the CommandService
		// that the string is special and needs to be evaluated as an expression.

		// If the string begins with a matching single or double quote, strip it.
		var startChar = left( theString, 1 );
		if(  startChar == '"' || startChar == "'" ) {
			theString =  mid( theString, 2, len( theString ) - 1 );
			// Strip any matching single or double ending quote
			// Missing ending quotes are invalid but will be ignored
			if( right( theString, 1 ) == startChar ) {
				return mid( theString, 1, len( theString ) - 1 );
			}
		}
		return theString;
	}

}
