/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
*
* I represent the behavior of reading and writing CF engine config in the format compatible with a Lucee 6.x server context
* I extend the BaseConfig class, which represents the data itself.
*/
component accessors=true extends='cfconfig-services.models.BaseConfig' {

	property name='configRelativePathWithinServerHome' type='string';
	property name='luceePasswordManager' inject='PasswordManager@lucee-password-util';

	/**
	* Constructor
	*/
	function init() {
		super.init();

		// This is where said config file is stored inside the server home
		setConfigRelativePathWithinServerHome( '/context/' );

		setFormat( 'luceeServer' );
		setVersion( '6' );

		return this;
	}

	/**
	* I read in config
	*
	* @CFHomePath The JSON file to read from
	*/
	function read( string CFHomePath ){
		var passwordManager = getLuceePasswordManager();
		// Override what's set if a path is passed in
		setCFHomePath( arguments.CFHomePath ?: getCFHomePath() );

		if( !len( getCFHomePath() ) ) {
			throw 'No CF home specified to read from';
		}

		var configFilePath = calculateConfigFilePath();
		// Lucee WARs don't ship with a config file
		if( !fileExists( configFilePath ) ) {
			return this;
		}
		configData = readJSONC( configFilePath );

		// Escape any BoxLang system settings like ${user-dir} that CommandBox shouldn't bother with
		configData = escapeDeepSystemSettings( configData );

		// Transformations for any place Lucee doesn't directly follow the CFConfig spec
		
		// Convert mappings to CFMappings and each mapping becomes a struct of data
		if( configData.keyExists( 'mappings' ) ) {
			configData.CFMappings = configData.mappings;
			configData.delete( 'mappings' );
		}
		// Convert componentMappings to componentPaths
		if( configData.keyExists( 'componentMappings' ) ) {
			var componentPaths = {};
			for (var mapping in configData.componentMappings) {
				if (structKeyExists(mapping, 'virtual')) {
					mapping[ 'name' ] = mapping.virtual;
					componentPaths[mapping.virtual] = mapping;
				}
			}
			configData.componentPaths = componentPaths;
			configData.delete( 'componentMappings' );
		}

		// Convert customTagPaths to customTagMappings, both are arrays, leave structs untouched
		if( configData.keyExists( 'customTagMappings' ) ) {
			configData.customTagPaths = configData.customTagMappings;
			configData.delete( 'customTagMappings' );
		}

		// convert customTagDeepSearch to customTagSearchSubdirectories
		if( configData.keyExists( 'customTagDeepSearch' ) ) {
			configData[ 'customTagSearchSubdirectories' ] = configData.customTagDeepSearch;
			configData.delete( 'customTagDeepSearch' );
		}

		// Convert whitespaceManagement to cfmlWriter using translate functions
		if( configData.keyExists( 'cfmlWriter' ) ) {
			configData[ 'whitespaceManagement' ] = translateWhitespaceFromLucee( configData.cfmlWriter );
			configData.delete( 'cfmlWriter' );
		}

		// Convert salt to adminSalt
		if( configData.keyExists( 'salt' ) ) {
			configData[ 'adminSalt' ] = configData.salt;
			configData.delete( 'salt' );
		}

		// Convert timezone to thisTimezone
		if( configData.keyExists( 'timezone' ) ) {
			configData[ 'thisTimezone' ] = configData.timezone;
			configData.delete( 'timezone' );
		}

		// Convert locale to thisLocale
		if( configData.keyExists( 'locale' ) ) {
			configData[ 'thisLocale' ] = configData.locale;
			configData.delete( 'locale' );
		}

		// Convert preserveSingleQuote to datasourcePreserveSingleQuotes
		if( configData.keyExists( 'datasources' ) && configData.datasources.keyExists( 'preserveSingleQuote' ) ) {
			configData[ 'datasourcePreserveSingleQuotes' ] = configData.datasources.preserveSingleQuote;
			configData.datasources.delete( 'preserveSingleQuote' );
		}

		// again, but psq this time
		if( configData.keyExists( 'datasources' ) && configData.datasources.keyExists( 'psq' ) ) {
			configData[ 'datasourcePreserveSingleQuotes' ] = configData.datasources.psq;
			configData.datasources.delete( 'psq' );
		}

		// loop over datasources, is password exists, decrypt it
		if( configData.keyExists( 'datasources' ) ) {
			for( var datasourceName in configData.datasources ) {
				var datasource = configData.datasources[ datasourceName ];
				// delete any non-struct values
				if( !isStruct( datasource ) ) {
					systemOutput( 'Deleting datasource ' & datasourceName & ' because it is not a struct', 1 );
					configData.datasources.delete( datasourceName );
				}
				if( datasource.keyExists( 'type' ) ) {
					datasource[ 'dbdriver' ] = datasource.type;
				}
				if( datasource.keyExists( 'password' ) && left( datasource.password, 10 ) == 'encrypted:' ) {
					datasource[ 'password' ] = passwordManager.decryptDataSource( replaceNoCase( datasource.password, 'encrypted:', '' ) );
				}
			}
		}

		// cacheDefaults, Lucee 6 moved them under cache
		if( configData.keyExists( 'cache' ) ) {
			arrayEach( getCacheTypes(),
				function( cacheType ){
					var cacheKey = "default" & arguments.cacheType;
					if( configData.cache.keyExists( cacheKey ) ) {
						configData[ "cacheDefault" & arguments.cacheType ] = configData.cache[ cacheKey ];
						configData.delete( cacheKey );
					}
				}
			);
			configData.delete( 'cache' );
		}

		// if caches exist, loop over and turn custom (if it exists as a string) to a struct
		if( configData.keyExists( 'caches' ) ) {
			for( var cacheName in configData.caches ) {
				var cache = configData.caches[ cacheName ];
				if( cache.keyExists( 'custom' ) && isSimpleValue( cache.custom ) ) {
					cache.custom = translateURLCodedPairsToStruct( cache.custom );
				}
				
				// If we have a class and we recognize it, generate the human-readable type
				if( !isNull( cache.class ) && translateCacheClassToType( cache.class ).len() ) {
					cache.type = translateCacheClassToType( cache.class );
				}
			}
		}
		
		// loop over mailServers array and if idle or life exist, rename them to idleTimeout and lifeTimeout
		if( configData.keyExists( 'mailServers' ) ) {
			for( var mailServer in configData.mailServers ) {
				if( mailServer.keyExists( 'idle' ) ) {
					mailServer[ 'idleTimeout' ] = mailServer.idle;
					mailServer.delete( 'idle' );
				}
				if( mailServer.keyExists( 'life' ) ) {
					mailServer[ 'lifeTimeout' ] = mailServer.life;
					mailServer.delete( 'life' );
				}
				// if there is a password, decrypt it
				if( mailServer.keyExists( 'password' ) && left( mailServer.password, 10 ) == 'encrypted:' ) {
					mailServer[ 'password' ] = passwordManager.decryptDataSource( replaceNoCase( mailServer.password, 'encrypted:', '' ) );
				}
			}
		}
		
		
		setMemento( configData );

		// Ensure we always have an admin salt
		if( isNull( getAdminSalt() ) ){
			setAdminSalt( createUUID() );
		}

		return this;
	}

	/**
	* I write out config from a base JSON format
	*
	* @CFHomePath The JSON file to write to
	*/
	function write( string CFHomePath, pauseTasks=false ){
		var passwordManager = getLuceePasswordManager();
		setCFHomePath( arguments.CFHomePath ?: getCFHomePath() );
		var thisCFHomePath = getCFHomePath();

		// Check to see if this mapping exists so we are compat with older versions of CommandBox
		if( wirebox.getBinder().mappingExists( 'SystemSettings' ) ) {
			var systemSettings = wirebox.getInstance( 'SystemSettings' );
			// Swap out stuff like ${foo}
			setMemento( systemSettings.expandDeepSystemSettings( getMemento() ) );
		}

		if( !len( thisCFHomePath ) ) {
			throw 'No CF home specified to write to';
		}

		var configFilePath = calculateConfigFilePath();
		var configData = getMemento();


		// We have plain text password and a salt
		if( configData.keyExists( 'adminPassword' ) && configData.keyExists( 'adminSalt' ) ) {
			configData[ 'hspw' ] = passwordManager.hashAdministrator( configData.adminPassword, configData.adminSalt );
			structDelete( configData, 'pw' );
			structDelete( configData, 'password' );
			structDelete( configData, 'adminPassword' );
		}

		// Transformations for any place BoxLang doesn't directly follow the CFConfig spec

		// Convert CFMappings to mappings and each mapping struct becomes a string
		if( configData.keyExists( 'CFMappings' ) ) {
			configData[ 'mappings' ] = configData.CFMappings;
			configData.delete( 'CFMappings' );
		}

		// convert cfmlWriter to whitespaceManagement using translate functions
		if( configData.keyExists( 'whitespaceManagement' ) ) {
			configData[ 'cfmlWriter' ] = translateWhitespaceToLucee( configData.whitespaceManagement );
			configData.delete( 'whitespaceManagement' );
		}

		// convert ComponentPaths to componentMappings
		if( configData.keyExists( 'componentPaths' ) ) {
			var componentMappings = [];
			for (var key in configData.componentPaths) {
				var mapping = configData.componentPaths[key];
				var mapping[ 'virtual' ] = key;
				mapping.delete( 'name' );
				componentMappings.append(mapping);
			}
			configData[ 'componentMappings' ] = componentMappings;
			configData.delete( 'componentPaths' );
		}

		// convert customTagPaths to customTagMappings, both are arrays, leave structs untouched
		if( configData.keyExists( 'customTagPaths' ) ) {
			configData[ 'customTagMappings' ] = configData.customTagPaths;
			configData.delete( 'customTagPaths' );
		}

		// convert customTagSearchSubdirectories to customTagDeepSearch
		if( configData.keyExists( 'customTagSearchSubdirectories' ) ) {
			configData[ 'customTagDeepSearch' ] = configData.customTagSearchSubdirectories;
			configData.delete( 'customTagSearchSubdirectories' );
		}

		// Convert adminSalt to salt
		if( configData.keyExists( 'adminSalt' ) ) {
			configData[ 'salt' ] = configData.adminSalt;
			configData.delete( 'adminSalt' );
		}
	
		// Convert thisTimezone to timezone
		if( configData.keyExists( 'thisTimezone' ) ) {
			configData[ 'timezone' ] = configData.thisTimezone;
			configData.delete( 'thisTimezone' );
		}

		// Convert thisLocale to locale
		if( configData.keyExists( 'thisLocale' ) ) {
			configData[ 'locale' ] = configData.thisLocale;
			configData.delete( 'thisLocale' );
		}

		// loop over datasources, is password exists, encrypt it
		if( configData.keyExists( 'datasources' ) ) {
			for( var datasourceName in configData.datasources ) {
				var datasource = configData.datasources[ datasourceName ];
				if( datasource.keyExists( 'password' ) ) {
					datasource[ 'password' ] = 'encrypted:' & passwordManager.encryptDataSource( datasource.password );
				}
				if( datasource.keyExists( 'dbdriver' ) ) {
					datasource[ 'type' ] = datasource.dbdriver;
				}
			}
		}

		// datasourcePreserveSingleQuotes
		if( configData.keyExists( 'datasourcePreserveSingleQuotes' ) ) {
			configData[ 'datasources' ] = configData.datasources ?: {};
			configData.datasources[ 'preserveSingleQuote' ] = configData.datasourcePreserveSingleQuotes;
			configData.delete( 'datasourcePreserveSingleQuotes' );
		}

		// cacheDefaults, Lucee 6 moved them under cache
		arrayEach( getCacheTypes(),
			function( cacheType ){
				var cacheKey = 'cacheDefault' & arguments.cacheType;
				if( configData.keyExists( cacheKey ) ) {
					if( !configData.keyExists( 'cache' ) ){
						configData[ 'cache' ] = {};
					}
					configData.cache[ "default" & arguments.cacheType ] = configData[ cacheKey ];
					configData.delete( cacheKey );
				}
			}
		);

		// if caches exist, loop over and turn custom (if it exists as a struct) to a string
		if( configData.keyExists( 'caches' ) ) {
			for( var cacheName in configData.caches ) {
				var cache = configData.caches[ cacheName ];
				if( cache.keyExists( 'custom' ) && isStruct( cache.custom ) ) {
					cache.custom = translateStructToURLCodedPairs( cache.custom );
				}
				// if there is a type and no class, generate the class
				if( !isNull( cache.type ) && !isNull( translateCacheTypeToClass( cache.type ) ) ) {
					cache.class = translateCacheTypeToClass( cache.type );
				}
			}			
		}

		// loop over mailServers array and if idleTimeout or lifeTimeout exist, rename them to idle and life
		if( configData.keyExists( 'mailServers' ) ) {
			for( var mailServer in configData.mailServers ) {
				if( mailServer.keyExists( 'idleTimeout' ) ) {
					mailServer[ 'idle' ] = mailServer.idleTimeout;
					mailServer.delete( 'idleTimeout' );
				}
				if( mailServer.keyExists( 'lifeTimeout' ) ) {
					mailServer[ 'life' ] = mailServer.lifeTimeout;
					mailServer.delete( 'lifeTimeout' );
				}
				// if there is a password, encrypt it
				if( mailServer.keyExists( 'password' ) ) {
					mailServer[ 'password' ] = 'encrypted:' & passwordManager.encryptDataSource( mailServer.password );
				}	
			}
		}

		// Ensure the parent directories exist
		directoryCreate( path=getDirectoryFromPath( configFilePath ), createPath=true, ignoreExists=true );
		var existingData = {};
		// merge with existing data
		if( fileExists( configFilePath ) ) {
			existingData = readJSONC( configFilePath );
		} else {
			// Load template data
			existingData = readJSONC( expandPath( '/cfconfig-services/resources/lucee6/CFConfig-base.json' ) );
		}
		mergeMemento( configData, existingData )
		// Make sure this never makes it to the hard drive
		structDelete( existingData, 'adminPassword' );

		fileWrite( configFilePath, JSONPrettyPrint.formatJson( serializeJSON( existingData ) ) );

		return this;
	}

	function calculateConfigFilePath() {
		return getCFHomePath() & getConfigRelativePathWithinServerHome() & '.CFConfig.json';
	}

	// Turn custom values into struct
	private function translateURLCodedPairsToStruct( required string custom ) {
		var thisStruct = [:];
		for( var item in arguments.custom.listToArray( '&' ) ) {
			// Turn foo=bar&baz=bum&poof= into { foo : 'bar', baz : 'bum', poof : '' }
			// Any "=" or "&" in the key values will be URL encoded.
			thisStruct[ URLDecode( listFirst( item, '=' ) ) ] = ( listLen( item, '=' ) ?  URLDecode( listRest( item, '=' ) ) : '' );
		}
		return thisStruct;
	}

	// Turn custom values into string
	private function translateStructToURLCodedPairs( required struct custom ) {
		var customAsString = '';
		// turn { foo : 'bar', baz : 'bum' } into foo=bar&baz=bum
		for( var key in arguments.custom ) {
			customAsString = customAsString.listAppend( '#URLEncode( key )#=#URLEncode( arguments.custom[ key ] )#', '&' );
		}
		return customAsString;
	}

	private function translateCacheTypeToClass( required string type ) {

		switch( type ) {
			case 'ram' :
				return 'lucee.runtime.cache.ram.RamCache';
			case 'ehcache' :
				return 'org.lucee.extension.cache.eh.EHCache';
			default :
				return '';
		}

	}

	private function translateCacheClassToType( required string class ) {

		switch( class ) {
			case 'lucee.runtime.cache.ram.RamCache' :
				return 'RAM';
			case 'org.lucee.extension.cache.eh.EHCache' :
				return 'EHCache';
			default :
				return '';
		}

	}

	private function translateWhitespaceToLucee( required string whitespaceManagement ) {

		switch( whitespaceManagement ) {
			case 'off' :
			case 'regular' :
				return 'regular';
			case 'simple' :
			case 'white-space' :
				return 'white-space';
			case 'smart' :
			case 'white-space-pref' :
				return 'white-space-pref';
			default :
				return 'regular';
		}

	}

	private function translateWhitespaceFromLucee( required string whitespaceManagement ) {

		switch( whitespaceManagement ) {
			case 'regular' :
				return 'off';
			case 'white-space' :
				return 'simple';
			case 'white-space-pref' :
				return 'smart';
			default :
				return 'off';
		}

	}

	private function getCacheTypes (){
		return [ "Template", "Object", "Query", "Resource", "Function", "Include", "Http", "File", "Webservice" ];
	}

}