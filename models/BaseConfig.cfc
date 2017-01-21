/**
* I represent the configuration of a CF engine.  I am agnostic and don't contain any particular
* behavior for a specific engine.  Not all the data I store applies to every engine though.  
* I am capable of reading and writing to a standard JSON format, but if you want to read or write
* to/from a specific engine's format, you'll need to create one of my subclasses
*/
component accessors=true {
	// One of the strings "never", "once", "always"
	property name='inspectTemplate' type='string' _isCFConfig=true;
	// Number of templates to cache
	property name='templateCacheSize' type='numeric' _isCFConfig=true;
	// True/false
	property name='componentCacheEnabled' type='boolean' _isCFConfig=true;
	// True/false
	property name='saveClassFiles' type='boolean' _isCFConfig=true;	
	// True/false
	property name='UDFTypeChecking' type='boolean' _isCFConfig=true;
	// true/false
	property name='nullSupport' type='boolean' _isCFConfig=true;
	// true/false
	property name='dotNotationUpperCase' type='boolean' _isCFConfig=true;
	// true/false
	property name='suppressWhitespaceBeforecfargument' type='string' _isCFConfig=true;
	// One of the strings "standard", "small", "strict"
	property name='scopeCascading' type='string' _isCFConfig=true;
	// True/false
	property name='searchResultsets' type='boolean' _isCFConfig=true;
	
	// Ex: en_US
	property name='thisLocale' type='string' _isCFConfig=true;
	// Ex: 	America/Chicago
	property name='thisTimeZone' type='string' _isCFConfig=true;
	// Ex: 	pool.ntp.org
	property name='timeServer' type='string' _isCFConfig=true;
	// true/false
	property name='useTimeServer' type='boolean' _isCFConfig=true;
	
	// Ex: windows-1252 (Lucee: Default character used to read templates (*.cfm and *.cfc files))
	property name='templateCharset' type='string' _isCFConfig=true;
	// Ex: UTF-8 (Lucee: Default character set for output streams, form-, url-, and cgi scope variables and reading/writing the header)
	property name='webCharset' type='string' _isCFConfig=true;
	// Ex: windows-1252 (Default character set for reading from/writing to various resources)
	property name='resourceCharset' type='string' _isCFConfig=true;
	
	// One of the strings "cfml", "j2ee"
	property name='sessionType' type='string' _isCFConfig=true;
	// True/false
	property name='mergeURLAndForm' type='boolean' _isCFConfig=true;
	// True/false
	property name='sessionMangement' type='boolean' _isCFConfig=true;
	// True/false
	property name='clientManagement' type='boolean' _isCFConfig=true;
	// True/false
	property name='domainCookies' type='boolean' _isCFConfig=true;
	// True/false
	property name='clientCookies' type='boolean' _isCFConfig=true;
	// One of the strings "classic", "modern"
	property name='localScopeMode' type='string' _isCFConfig=true;
	// True/false
	property name='CGIReadOnly' type='string' _isCFConfig=true;
	// Timespan Ex: 0,5,30,0
	property name='sessionTimeout' type='string' _isCFConfig=true;
	// Timespan Ex: 0,5,30,0
	property name='applicationTimeout' type='string' _isCFConfig=true;
	
	// One of the strings "none", "mixed", "modern", "classic"
	property name='applicationListener' type='string' _isCFConfig=true;
	/* One of the strings 
	* "curr2root" - Current dir to web root (Lucee and Adobe [option 2])
	* "curr" - Current dir only (Lucee only)
	* "root" - Only in web root (Lucee only)
	* "currorroot" -  Current dir or web root (Lucee and Adobe [option 3])
	* "curr2driveroot" - Current dir to drive root (Adobe only [option 1])
	*/
	property name='applicationMode' type='string' _isCFConfig=true;
	
	// Timespan Ex: 0,5,30,0
	property name='clientTimeout' type='string' _isCFConfig=true;
	// One of the strings "memory", "file", "cookie", <cache-name>, <datasource-name>
	property name='sessionStorage' type='string' _isCFConfig=true;
	// One of the strings "memory", "file", "cookie", <cache-name>, <datasource-name>
	property name='clientStorage' type='string' _isCFConfig=true;
	// Timespan Ex: 0,5,30,0
	property name='requestTimeout' type='string' _isCFConfig=true;
	// True/false
	property name='requestTimeoutEnabled' type='boolean' _isCFConfig=true;
	
	// "none", "all" or a comma-delimited list with some combination of "cgi", "cookie", "form", "url".
	property name='scriptProtect' type='string' _isCFConfig=true;
	// True/false
	property name='perAppSettingsEnabled' type='boolean' _isCFConfig=true;
	// True/false
	property name='useUUIDForCFToken' type='boolean' _isCFConfig=true;
	// True/false	
	property name='requestTimeoutInURL' type='boolean' _isCFConfig=true;
	// One of the strings "regular", "white-space", "white-space-pref"
	property name='whitespaceManagement' type='string' _isCFConfig=true;
	// True/false
	property name='compression' type='boolean' _isCFConfig=true;
	// True/false
	property name='supressContentForCFCRemoting' type='boolean' _isCFConfig=true;
	// True/false
	property name='bufferTagBodyOutput' type='boolean' _isCFConfig=true;		
	// Key is datasource name, value is struct of properties
	property name='datasources' type='struct' _isCFConfig=true;
	// Array of structs of properties.  Mail servers are uniquely identified by host
	property name='mailServers' type='array' _isCFConfig=true;
	// Key is virtual path, value is struct of properties
	property name='CFMappings' type='struct' _isCFConfig=true;
	// True/false
	property name='errorStatusCode' type='boolean' _isCFConfig=true;
	// True/false
	property name='disableInternalCFJavaComponents' type='boolean' _isCFConfig=true;
	
	// True/false
	property name='secureJSON' type='boolean' _isCFConfig=true;
	// A string representing the JSON prefx like "//"
	property name='secureJSONPrefix' type='string' _isCFConfig=true;
	
	// Number of KB for buffer size (1024)
	property name='maxOutputBufferSize' type='numeric' _isCFConfig=true;
	
	// True/false
	property name='inMemoryFileSystemEnabled' type='boolean' _isCFConfig=true;
	// Number of MB for in memory file system
	property name='inMemoryFileSystemLimit' type='numeric' _isCFConfig=true;
	// Number of MB for in memory application file system
	property name='inMemoryFileSystemAppLimit' type='numeric' _isCFConfig=true;
	
	// True/false
	property name='watchConfigFilesForChangesEnabled' type='boolean' _isCFConfig=true;
	// Number of seconds
	property name='watchConfigFilesForChangesInterval' type='numeric' _isCFConfig=true;
	// List of file extensions. Ex: "xml,properties"
	property name='watchConfigFilesForChangesExtensions' type='string' _isCFConfig=true;
	
	// True/false
	property name='allowExtraAttributesInAttrColl' type='boolean' _isCFConfig=true;
	// True/false
	property name='disallowUnamedAppScope' type='boolean' _isCFConfig=true;
	// True/false
	property name='allowApplicationVarsInServletContext' type='boolean' _isCFConfig=true;
	// Number of minutes
	property name='CFaaSGeneratedFilesExpiryTime' type='numeric' _isCFConfig=true;
	// Absolute path to store index files for ORM search.
	property name='ORMSearchIndexDirectory' type='string' _isCFConfig=true;
	// default path (relative to the web root) to the directory containing the cfform.js file. 
	property name='CFFormScriptDirectory' type='string' _isCFConfig=true;
	// Your Google maps API key
	property name='googleMapKey' type='string' _isCFConfig=true;
	
	// True/false
	property name='serverCFCEenabled' type='boolean' _isCFConfig=true;
	// Specify the absolute path to a CFC having onServerStart() method, like "c:\server.cfc". Or specify a dot delimited CFC path under webroot, like "a.b.server". By default, ColdFusion will look for server.cfc under webroot.
	property name='serverCFC' type='string' _isCFConfig=true;

	// file extensions as a comma separated list which gets compiled when used in the CFInclude tag * for all.
	property name='compileExtForCFInclude' type='string' _isCFConfig=true;
	
	property name='generalErrorTemplate' type='string' _isCFConfig=true;
	property name='missingErrorTemplate' type='string' _isCFConfig=true;
	
	// Maximum number of parameters in a POST request sent to the server.
	property name='postParametersLimit' type='numeric' _isCFConfig=true;
	// Limits the amount of data in MB that can be posted to the server in a single request.
	property name='postSizeLimit' type='numeric' _isCFConfig=true;
	// Requests smaller than the specified limit in MB are not handled by the throttle.
	property name='throttleThreshold' type='numeric' _isCFConfig=true;
	// Limits total memory size in MB for the throttle
	property name='totalThrottleMemory' type='numeric' _isCFConfig=true;
	
	// TODO:
	//property name='externalizeStrings' type='string' _isCFConfig=true;
	//property name='caches' type='array' _isCFConfig=true;
	//property name='restMappings' type='array' _isCFConfig=true;
	//property name='componentBase' type='string' _isCFConfig=true;
	//property name='componentAutoImport' type='string' _isCFConfig=true;
	//property name='componentSearchLocal' type='boolean' _isCFConfig=true;
	//property name='componentImplicitNotation' type='boolean' _isCFConfig=true;
	//property name='customTagSearchSubdirectories' type='boolean' _isCFConfig=true;
	//property name='customTagSearchLocal' type='boolean' _isCFConfig=true;
	//property name='customTagExtensions' type='string' _isCFConfig=true;
	//property name='customTagPaths' type='array' _isCFConfig=true;
	//property name='cfxTags' type='string' _isCFConfig=true;
	//property name='debuggingEnabled' type='boolean' _isCFConfig=true;
	//property name='debuggingDBEnabled' type='string' _isCFConfig=true;
	//property name='debuggingExceptionsEnabled' type='boolean' _isCFConfig=true;
	//property name='debuggingDBActivityEnabled' type='boolean' _isCFConfig=true;
	//property name='debuggingQueryUsageEnabled' type='boolean' _isCFConfig=true;
	//property name='debuggingTracingEnabled' type='boolean' _isCFConfig=true;
	//property name='debuggingDumpEnabled' type='boolean' _isCFConfig=true;
	//property name='debuggingTimerEnabled' type='boolean' _isCFConfig=true;
	//property name='debuggingImplicitVariableAccessEnabled' type='boolean' _isCFConfig=true;
	
	// Plain text admin password
	property name='adminPassword' type='string' _isCFConfig=true;
	// Plain text default password for new Lucee web context
	property name='adminPasswordDefault' type='string' _isCFConfig=true;
	// hashed salted password for Lucee
	property name='hspw' type='string' _isCFConfig=true;
	// hashed password for Lucee/Railo
	property name='pw' type='string' _isCFConfig=true;
	// Salt for admin password in Lucee
	property name='adminSalt' type='string' _isCFConfig=true;
	// hashed salted default password for new Lucee web context
	property name='defaultHspw' type='string' _isCFConfig=true;
	// hashed default password for new Lucee/Railo web context
	property name='defaultPw' type='string' _isCFConfig=true;
	
	// Not a setting-- this is the config file to read/write from/to
	// For adobe, it's <installDir>/cfusion
	// For Railo/Lucee, it's the server context or web context folder
	// For generic JSON config, it's just the folder you want to read/write from
	property name='CFHomePath' type='string';
	
	/**
	* Constructor
	*/
	function init() {
		// This will need to be set before you can read/write
		setCFHomePath( '' );
	}
		
	/**
	* Custom setter to clean up paths
	*/	
	function setCFHomePath( required string CFHomePath ) {
		variables.CFHomePath = arguments.CFHomePath.replace( '\', '/', 'all' );
		return this;
	}
	
	////////////////////////////////////////
	// Custom Setters for complex types
	////////////////////////////////////////
	
	/**
	* Add a single cache to the config
	*/
	function addCache() { throw 'addCache() not implemented'; }
  
	/**
	* Add a single datasource to the config
	*/
	function addDatasource(
			required string name,
			allow,
			blob,	
			class,
			clob,
			connectionLimit,
			connectionTimeout,
			custom,
			database,
			dbdriver,
			dsn,
			host,
			metaCacheTimeout,
			password, // Unencrypted
			port,
			storage,
			username,
			validate
		) {
			
		var ds = {};
		if( !isNull( database ) ) { ds.database = database; };
		if( !isNull( allow ) ) { ds.allow = allow; };
		if( !isNull( blob ) ) { ds.blob = blob; };
		if( !isNull( class ) ) { ds.class = class; };
		if( !isNull( dbdriver ) ) { ds.dbdriver = dbdriver; };
		if( !isNull( clob ) ) { ds.clob = clob; };
		if( !isNull( connectionLimit ) ) { ds.connectionLimit = connectionLimit; };
		if( !isNull( connectionTimeout ) ) { ds.connectionTimeout = connectionTimeout; };
		if( !isNull( custom ) ) { ds.custom = custom; };
		if( !isNull( dsn ) ) { ds.dsn = dsn; };
		if( !isNull( password ) ) { ds.password = password; };
		if( !isNull( host ) ) { ds.host = host; };
		if( !isNull( metaCacheTimeout ) ) { ds.metaCacheTimeout = metaCacheTimeout; };
		if( !isNull( port ) ) { ds.port = port; };
		if( !isNull( storage ) ) { ds.storage = storage; };
		if( !isNull( username ) ) { ds.username = username; };
		if( !isNull( validate ) ) { ds.validate = validate; };
		
		var thisDatasources = getDataSources() ?: {};
		thisDatasources[ arguments.name ] = ds; 
		setDatasources( thisDatasources );
		return this;
	}
	
	/**
	* Add a single mail server to the config
	*/
	function addMailServer(
		idle,
		life,
		password, // Unencrypted
		port,
		smtp,
		ssl,
		tls,
		username
	) {
			
		var mailServer = {};
		if( !isNull( idle ) ) { mailServer.idle = idle; };
		if( !isNull( life ) ) { mailServer.life = life; };
		if( !isNull( password ) ) { mailServer.password = password; };
		if( !isNull( port ) ) { mailServer.port = port; };
		if( !isNull( smtp ) ) { mailServer.smtp = smtp; };
		if( !isNull( ssl ) ) { mailServer.ssl = ssl; };
		if( !isNull( tls ) ) { mailServer.tls = tls; };
		if( !isNull( username ) ) { mailServer.username = username; };
		
		var thisMailServers = getMailServers() ?: [];
		thisMailServers.append( mailServer ); 
		setMailServers( thisMailServers );
		return this;
	}
	
	/**
	* Add a single CF mapping to the config
	*/
	function addCFMapping(
			required string virtual,
			physical,
			archive,
			inspectTemplate,
			listenerMode,
			listenerType,
			primary,
			readOnly
		) {
		
		var mapping = {};
		if( !isNull( physical ) ) { mapping.physical = physical; };
		if( !isNull( archive ) ) { mapping.archive = archive; };
		if( !isNull( inspectTemplate ) ) { mapping.inspectTemplate = inspectTemplate; };
		if( !isNull( listenerMode ) ) { mapping.listenerMode = listenerMode; };
		if( !isNull( database ) ) { mapping.listenerType = listenerType; };
		if( !isNull( primary ) ) { mapping.primary = primary; };
		if( !isNull( readOnly ) ) { mapping.readOnly = readOnly; };
		
		var thisCFMappings = getCFMappings() ?: {};
		thisCFMappings[ arguments.virtual ] = mapping; 
		setCFMappings( thisCFMappings );
		return this;		
	}
	
	/**
	* Add a single rest mapping to the config
	*/
	function addRestMapping() { throw 'addRestMapping() not implemented'; }
	
	/**
	* Add a single custom tag to the config
	*/
	function addCustomTagPath() { throw 'addCustomTagPath() not implemented'; }
	
	
	/**
	* I read in config from a base JSON format
	*
	* @CFHomePath The JSON file to read from
	*/
	function read( string CFHomePath ){
		// Override what's set if a path is passed in
		setCFHomePath( arguments.CFHomePath ?: getCFHomePath() );
		var thisCFHomePath = getCFHomePath();
		
		if( !len( thisCFHomePath ) ) {
			throw 'No CF home specified to read from';
		}
		
		// If the path doesn't end with .json, assume it's just the directory
		if( right( thisCFHomePath, 5 ) != '.json' ) {
			thisCFHomePath = thisCFHomePath.listAppend( '.CFConfig.json', '/' );
		}		
		
		if( !fileExists( thisCFHomePath ) ) {
			throw "CF home doesn't exist [#thisCFHomePath#]";
		}
		
		var thisConfigRaw = fileRead( thisCFHomePath );
		
		if( !isJSON( thisConfigRaw ) ) {
			throw "Config file doesn't contain JSON [#thisCFHomePath#]";
		}
		
		var thisConfig = deserializeJSON( thisConfigRaw );
		setMemento( thisConfig );
		return this;
	}

	/**
	* I write out config from a base JSON format
	*
	* @CFHomePath The JSON file to write to
	*/
	function write( string CFHomePath ){
		// Override what's set if a path is passed in
		setCFHomePath( arguments.CFHomePath ?: getCFHomePath() );
		var thisCFHomePath = getCFHomePath();
		
		if( !len( thisCFHomePath ) ) {
			throw 'No CF home specified to write to';
		}
		
		// If the path doesn't end with .json, assume it's just the directory
		if( right( thisCFHomePath, 5 ) != '.json' ) {
			thisCFHomePath = thisCFHomePath.listAppend( '.CFConfig.json', '/' );
		}
		
		var thisConfigRaw = serializeJSON( getMemento() );
		// Ensure the parent directories exist
		directoryCreate( path=getDirectoryFromPath( thisCFHomePath ), createPath=true, ignoreExists=true )
		fileWrite( thisCFHomePath, formatJson( thisConfigRaw ) );
		return this;
	}

	/**
	* Get a struct representation of the config settings
	*/
	function getMemento(){
		var memento = {};
		for( var propName in getConfigProperties() ) {
			var thisValue = this[ 'get' & propName ]();
			if( !isNull( thisValue ) ) {
				memento[ propName ] = thisValue;				
			}
		}
		// This could be an empty struct if nothing has been set.
		return memento;
	}

	/**
	* Get a formatted string JSON representation of the config settings
	*/
	function toString(){
		return formatJson( getMemento() );
	}

	/**
	* Set a struct representation of the config settings
	* @memento The config data to set
	*/
	function setMemento( required struct memento ){
		variables.append( memento, true );
		return this;
	}

	/**
	* Return cached array of config property names
	*/
	function getConfigProperties(){
		variables.configProperties = variables.configProperties ?: generateConfigProperties();
		return variables.configProperties;
	}

	/**
	* Gnerate array of config property names
	*/
	private function generateConfigProperties(){
		variables.md = variables.md ?: getInheritedMetaData( this );
		var configProperties = [];
		for( var prop in md.properties ) {
			if( prop._isCFConfig ?: false ) {
				configProperties.append( prop.name );				
			}
		}
		return configProperties;
	}

	/**
	 * Pretty JSON
	 * @json.hint A string containing JSON, or a complex value that can be serialized to JSON
 	 **/
	public function formatJson( json ) {
		
		// Overload this method to accept a struct or array
		if( !isSimpleValue( arguments.json ) ) {
			arguments.json = serializeJSON( arguments.json );
		}
		
		var retval = createObject('java','java.lang.StringBuilder').init('');
		var str = json;
	    var pos = 0;
	    var strLen = str.length();
		var indentStr = '    ';
	    var newLine = chr( 13 ) & chr( 10 );
		var char = '';
		var inQuote = false;
		var isEscaped = false;

		for (var i=0; i<strLen; i++) {
			char = str.substring(i,i+1);
			
			if( isEscaped ) {
				isEscaped = false;
				retval.append( char );
				continue;
			}
			
			if( char == '\' ) {
				isEscaped = true;
				retval.append( char );
				continue;
			}
			
			if( char == '"' ) {
				if( inQuote ) {
					inQuote = false;
				} else {
					inQuote = true;					
				}
				retval.append( char );
				continue;
			}
			
			if( inQuote ) {
				retval.append( char );
				continue;
			}	
			
			
			if (char == '}' || char == ']') {
				retval.append( newLine );
				pos = pos - 1;
				for (var j=0; j<pos; j++) {
					retval.append( indentStr );
				}
			}
			retval.append( char );
			if (char == '{' || char == '[' || char == ',') {
				retval.append( newLine );
				if (char == '{' || char == '[') {
					pos = pos + 1;
				}
				for (var k=0; k<pos; k++) {
					retval.append( indentStr );
				}
			}
		}
		return retval.toString();
	}

	/**
	* Returns a single-level metadata struct that includes all items inhereited from extending classes.
	*/
	function getInheritedMetaData( thisComponent, md={} ) {

		// First time through, get metaData of thisComponent.
		if( structIsEmpty( md ) ) {
			if( isObject( thisComponent ) ) {
				md = getMetaData(thisComponent);
			} else {
				md = getComponentMetaData(thisComponent);
			}
		}

		// If it has a parent, stop and calculate it first

		if( structKeyExists( md, 'extends' ) AND md.type eq 'component' ) {
			local.parent = getInheritedMetaData( thisComponent=thisComponent, md=md.extends );
		// If we're at the end of the line, it's time to start working backwards so start with an empty struct to hold our condensesd metadata.
		} else {
			local.parent = {};
			local.parent.inheritancetrail = [];
		}

		// Override ourselves into parent
		for( local.key in md ) {
			// Functions and properties are an array of structs keyed on name, so I can treat them the same
			if( listFindNoCase("functions,properties",local.key) ) {
				if( !structKeyExists(local.parent, local.key) ) {
					local.parent[local.key] = [];
				}
				// For each function/property in me...
				for( local.item in md[local.key] ) {
					local.parentItemCounter = 0;
					local.foundInParent = false;
					// ...Look for an item of the same name in my parent...
					for( local.parentItem in local.parent[local.key] ) {
						local.parentItemCounter++;
						// ...And override it
						if( compareNoCase(local.item.name,local.parentItem.name) eq 0 ) {
							local.parent[local.key][local.parentItemCounter] = local.item;
							local.foundInParent = true;
							break;
						}
					}
					// ...Or add it
					if( not local.foundInParent ) {
						arrayAppend(local.parent[local.key], local.item);
					}
				}
			} else if( !listFindNoCase("extends,implements", local.key) ) {
				local.parent[local.key] = md[local.key];
			}
		}
		arrayPrePend(local.parent.inheritanceTrail, local.parent.name);
		return local.parent;
	}


}