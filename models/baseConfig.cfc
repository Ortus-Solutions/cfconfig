/**
* I represent the configuration of a CF engine.  I am agnostic and don't contain any particular
* behavior for a specific engine.  Not all the data I store applies to every engine though.  
* I am capable of reading and writing to a standard JSON format, but if you want to read or write
* to/from a specific engine's format, you'll need to create one of my subclasses
*/
component accessors="true"{
		property name="trustedCache" type="string";	property name="UDFTypes" type="string";	property name="nullSupport" type="boolean";	property name="templateCharset" type="string";	property name="dotNotation" type="string";	property name="suppressWhitespaceBeforecfargument" type="string";	property name="locale" type="string";	property name="timeZone" type="string";	property name="timeServer" type="string";	property name="useTimeServer" type="boolean";	property name="templateCharset" type="string";	property name="webCharset" type="string";	property name="resourceCharset" type="string";	property name="scopeCascading" type="string";	property name="searchResultsets" type="boolean";	property name="sessionType" type="string";	property name="mergeURLAndForm" type="boolean";	property name="sessionMangement" type="boolean";	property name="clientManagement" type="boolean";	property name="domainCookies" type="boolean";	property name="clientCookies" type="boolean";	property name="localScopeMode" type="string";	property name="CGIReadOnly" type="string";	property name="sessionTimeout" type="string";	property name="applicationTimeout" type="string";	property name="clientTimeout" type="string";	property name="sessionStorage" type="string";	property name="clientStorage" type="string";	property name="scriptProtect" type="string";	property name="requestTimeout" type="string";	property name="requestTimeoutInURL" type="string";	property name="whitespaceManagement" type="string";	property name="compression" type="boolean";	property name="supressContentForCFCRemoting" type="boolean";	property name="bufferTagBodyOutput" type="boolean";	property name="generalErrorTemplate" type="string";	property name="missingErrorTemplate" type="string";	property name="errorStatusCode" type="string";	property name="caches" type="array";	property name="datasources" type="struct";	property name="mailServers" type="array";	property name="CFMappings" type="array";	property name="restMappings" type="array";	property name="componentBase" type="string";	property name="componentAutoImport" type="string";	property name="componentSearchLocal" type="boolean";	property name="componentImplicitNotation" type="boolean";	property name="customTagSearchSubdirectories" type="boolean";	property name="customTagSearchLocal" type="boolean";	property name="customTagExtensions" type="string";	property name="customTagPaths" type="array";	property name="cfxTags" type="string";	property name="debuggingEnabled" type="boolean";	property name="debuggingDBEnabled" type="string";
	property name="debuggingExceptionsEnabled" type="boolean";
	property name="debuggingDBActivityEnabled" type="boolean";
	property name="debuggingQueryUsageEnabled" type="boolean";	property name="debuggingTracingEnabled" type="boolean";	property name="debuggingDumpEnabled" type="boolean";	property name="debuggingTimerEnabled" type="boolean";	property name="debuggingImplicitVariableAccessEnabled" type="boolean";	property name="adminUsers" type="array";
	property name="defaultPassword" type="string";
	
	// Not a setting-- this is the config file to read/write from/to
	property name="configFile" type="string";	
	function init() {
		// This will need to be set before you can read/write
		setConfigFile( '' );
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
			database,
			host,
			port,
			class,
			dsn,
			storage
		) {
			
		var ds = {};
		if( !isNull( database ) ) { ds.database = database; };
		if( !isNull( host ) ) { ds.host = host; };
		if( !isNull( port ) ) { ds.port = port; };
		if( !isNull( class ) ) { ds.class = class; };
		if( !isNull( dsn ) ) { ds.dsn = dsn; };
		if( !isNull( storage ) ) { ds.storage = storage; };
		
		var thisDatasources = getDataSources();
		thisDatasources[ arguments.name ] = ds; 
		setDatasources( thisDatasources );
		return this;
	}
	
	/**
	* Add a single mail server to the config
	*/
	function addMailServer() { throw 'addMailServer() not implemented'; }
	
	/**
	* Add a single CF mapping to the config
	*/
	function addCFMapping() { throw 'addCFMapping() not implemented'; }
	
	/**
	* Add a single rest mapping to the config
	*/
	function addRestMapping() { throw 'addRestMapping() not implemented'; }
	
	/**
	* Add a single custom tag to the config
	*/
	function addCustomTagPath() { throw 'addCustomTagPath() not implemented'; }
	
	/**
	* Add a single user to the config
	*/
	function addAdminUser() { throw 'addAdminUser() not implemented'; }
	
	
	/**
	* I read in config from a base JSON format
	*
	* @configFile The JSON file to read from
	*/
	function read( string configFile ){
		var thisConfigFile = arguments.configFile ?: getConfigFile();
		
		if( !len( thisConfigFile ) ) {
			throw "No config file specified to read from";
		}
		
		if( !fileExists( thisConfigFile ) ) {
			throw "Config file doesn't exist [#thisConfigFile#]";
		}
		
		var thisConfigRaw = fileRead( thisConfigFile );
		
		if( !isJSON( thisConfigRaw ) ) {
			throw "Config file doesn't contain JSON [#thisConfigFile#]";
		}
		
		var thisConfig = deserializeJSON( thisConfigRaw );
		setMemento( thisConfig );
		return this;
	}

	/**
	* I write out config from a base JSON format
	*
	* @configFile The JSON file to write to
	*/
	function write( string configFile ){
		var thisConfigFile = arguments.configFile ?: getConfigFile();
		
		if( !len( thisConfigFile ) ) {
			throw "No config file specified to write to";
		}
		
		var thisConfigRaw = serializeJSON( getMemento() );
		directoryCreate( path=getDirectoryFromPath( thisConfigFile ), createPath=true, ignoreExists=true )
		fileWrite( thisConfigFile, formatJson( thisConfigRaw ) );
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
		variables.md = variables.md ?: getMetaData( this );
		var configProperties = [];
		for( var prop in md.properties ) {
			if( !listFindNocase( 'configFile', prop.name ) ) {
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
		
		var retval = createObject("java","java.lang.StringBuilder").init('');
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

}