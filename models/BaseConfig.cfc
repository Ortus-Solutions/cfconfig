/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
* 
* I represent the configuration of a CF engine.  I am agnostic and don't contain any particular
* behavior for a specific engine.  Not all the data I store applies to every engine though.  
* I am capable of reading and writing to a standard JSON format, but if you want to read or write
* to/from a specific engine's format, you'll need to create one of my subclasses
*/
component accessors=true {
	
	// ----------------------------------------------------------------------------------------
	// Depdendency Injections
	// ----------------------------------------------------------------------------------------

	property name='wirebox' inject='wirebox';
	property name='Util' inject='Util@cfconfig-services';
	
	// ----------------------------------------------------------------------------------------
	// Properties for the internal workings
	// ----------------------------------------------------------------------------------------
	
	// The config file to read/write from/to
	// - For adobe, it's <installDir>/cfusion
	// - For Railo/Lucee, it's the server context or web context folder
	// - For generic JSON config, it's just the folder you want to read/write from
	property name='CFHomePath' type='string';
	
	// The name of the format this config provider can handle. "adobe", "lucee", or "railo"
	property name='format' type='string';
	// A semver range that covers the version of the formats that are covered.
	property name='version' type='string';
	
	// ----------------------------------------------------------------------------------------
	// CF Config properties that map to the CF engines
	// ----------------------------------------------------------------------------------------
	
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
	property name='applicationMangement' type='boolean' _isCFConfig=true;
	// True/false
	property name='sessionMangement' type='boolean' _isCFConfig=true;
	// True/false
	property name='clientManagement' type='boolean' _isCFConfig=true;
	// True/false
	property name='domainCookies' type='boolean' _isCFConfig=true;
	// True/false
	property name='clientCookies' type='boolean' _isCFConfig=true;
		
	// Number of seconds
	property name='sessionCookieTimeout' type='numeric' _isCFConfig=true;
	// True/false
	property name='sessionCookieHTTPOnly' type='boolean' _isCFConfig=true;
	// True/false
	property name='sessionCookieSecure' type='boolean' _isCFConfig=true;
	// True/false
	property name='sessionCookieDisableUpdate' type='boolean' _isCFConfig=true;
	
	// One of the strings "classic", "modern"
	property name='localScopeMode' type='string' _isCFConfig=true;
	// True/false
	property name='CGIReadOnly' type='string' _isCFConfig=true;
	// Timespan Ex: 0,5,30,0
	property name='sessionTimeout' type='string' _isCFConfig=true;
	// Timespan Ex: 0,5,30,0
	property name='applicationTimeout' type='string' _isCFConfig=true;
	// Timespan Ex: 0,5,30,0
	property name='sessionMaximumTimeout' type='string' _isCFConfig=true;
	// Timespan Ex: 0,5,30,0
	property name='applicationMaximumTimeout' type='string' _isCFConfig=true;
	
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
	// Encoding to use for mail. Ex: UTF-8
	property name='mailDefaultEncoding' type='string' _isCFConfig=true;
	// True/false enable mail spooling
	property name='mailSpoolEnable' type='boolean' _isCFConfig=true;
	// Number of seconds for interval
	property name='mailSpoolInterval' type='numeric' _isCFConfig=true;
	// Number of seconds to wait for mail server response
	property name='mailConnectionTimeout' type='numeric' _isCFConfig=true;
	// True/false to allow downloading attachments for undelivered emails
	property name='mailDownloadUndeliveredAttachments' type='boolean' _isCFConfig=true;
	// Sign messages with cert
	property name='mailSignMesssage' type='boolean' _isCFConfig=true;
	// Path to keystore
	property name='mailSignKeystore' type='string' _isCFConfig=true;
	// Password to the keystore
	property name='mailSignKeystorePassword' type='string' _isCFConfig=true;
	// Alias of the key with which the certificcate and private key is stored in keystore. The supported type is JKS (java key store) and pkcs12.
	property name='mailSignKeyAlias' type='string' _isCFConfig=true;
	// Password with which the private key is stored.
	property name='mailSignKeyPassword' type='string' _isCFConfig=true;
	
	
	
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
			
	// Key is cache connection name, value is struct of properties
	property name='caches' type='struct' _isCFConfig=true;
				
	// name of default Object cache connection
	property name='cacheDefaultObject' type='string' _isCFConfig=true;
	// name of default function cache connection
	property name='cacheDefaultFunction' type='string' _isCFConfig=true;
	// name of default Template cache connection
	property name='cacheDefaultTemplate' type='string' _isCFConfig=true;
	// name of default Query cache connection
	property name='cacheDefaultQuery' type='string' _isCFConfig=true;
	// name of default Resource cache connection
	property name='cacheDefaultResource' type='string' _isCFConfig=true;
	// name of default Include cache connection
	property name='cacheDefaultInclude' type='string' _isCFConfig=true;
	// name of default File cache connection
	property name='cacheDefaultFile' type='string' _isCFConfig=true;
	// name of default HTTP cache connection
	property name='cacheDefaultHTTP' type='string' _isCFConfig=true;
	// name of default WebService cache connection
	property name='cacheDefaultWebservice' type='string' _isCFConfig=true;
	
	// TODO:
	//property name='externalizeStrings' type='string' _isCFConfig=true;
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
	// Plain text admin RDS password
	property name='adminRDSPassword' type='string' _isCFConfig=true;
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
	
	// License key (only used for Adobe)
	property name='license' type='string' _isCFConfig=true;
	// Previous license key (required for an upgrade license key)
	property name='previousLicense' type='string' _isCFConfig=true;
	
	
	// TODO: Figure out what hashing algorithms each version of ACF use, and share the 
	// same setting so the hashes passwords are as portable as possible
	
	// hashed admin password for Adobe CF11
	property name='ACF11Password' type='string' _isCFConfig=true;
	// hashed RDS password for Adobe CF11
	property name='ACF11RDSPassword' type='string' _isCFConfig=true;
	
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
	* 
	* @name name of the cache to save or update
	* @class Java class of implementing provider
	* @readOnly No idea what this does
	* @storage Is this cache used for session or client scope storage?
	* @custom A struct of settings that are meaningful to this cache provider.
	*/
	function addCache(
		required string name,
		string class,
		boolean readOnly,
		boolean storage,
		struct custom
	) {
		var cacheConnection = {};
		if( !isNull( class ) ) { cacheConnection[ 'class' ] = class; };
		if( !isNull( readOnly ) ) { cacheConnection[ 'readOnly' ] = readOnly; };
		if( !isNull( storage ) ) { cacheConnection[ 'storage' ] = storage; };
		if( !isNull( custom ) ) { cacheConnection[ 'custom' ] = custom; };
		
		var thisCaches = getCaches() ?: {};
		thisCaches[ arguments.name ] = cacheConnection; 
		setCaches( thisCaches );
		return this;	
	}
  
	/**
	* Add a single datasource to the config
	* @name Name of datasource
	* @allow Bitmask of allowed operations
	* @blob Enable blob?
	* @class Java class of driver
	* @clob Enable clob?
	* @connectionLimit Max number of connections. -1 means unlimimted
	* @connectionTimeout Connectiontimeout in minutes
	* @custom Extra JDBC URL query string without leading &
	* @database name of database
	* @dbdriver Type of database driver
	*  - MSSQL -- SQL Server driver
	*  - MSSQL2 -- jTDS driver
	*  - PostgreSql
	*  - Oracle
	*  - Other -- Custom JDBC URL
	*  - MySQL
	* @dsn JDBC URL (jdbc:mysql://{host}:{port}/{database})
	* @host name of host
	* @metaCacheTimeout Not sure-- Lucee had this in the XML
	* @password Unencrypted password
	* @port Port to connect on
	* @storage True/False use this datasource as client/session storage (Lucee)
	* @username Username to connect with
	* @validate Validate this datasource connectin every time it's used?
	* @SID Used for Oracle datasources
	* 
	* Allow parameter expects an integer bitmask where the bits in the mask (starting with zero) are:
	* 0 Select (1)
	* 1 delete (2)
	* 2 update (4)
	* 3 insert (8)
	* 4 create (16)
	* 5 grant (32)
	* 6 revoke (64)
	* 7 drop (128)
	* 8 alter (256)
	* 9 Stored procs (512)
	*
	* So a datasource that allows you to select, update, and insert would have a value of 1+4+8, or 13.
	*/
	function addDatasource(
			required string name,
			string allow,
			boolean blob,
			string class,
			boolean clob,
			numeric connectionLimit,
			numeric connectionTimeout,
			string custom,
			string database,
			string dbdriver,
			string dsn,
			string host,
			numeric metaCacheTimeout,
			string password, // Unencrypted
			string port,
			boolean storage,
			string username,
			boolean validate,
			string SID
		) {
		var ds = {};
		if( !isNull( database ) ) { ds[ 'database' ] = database; };
		if( !isNull( allow ) ) { ds[ 'allow' ] = allow; };
		if( !isNull( blob ) ) { ds[ 'blob' ] = blob; };
		if( !isNull( class ) ) { ds[ 'class' ] = class; };
		if( !isNull( dbdriver ) ) { ds[ 'dbdriver' ] = dbdriver; };
		if( !isNull( clob ) ) { ds[ 'clob' ] = clob; };
		if( !isNull( connectionLimit ) ) { ds[ 'connectionLimit' ] = connectionLimit; };
		if( !isNull( connectionTimeout ) ) { ds[ 'connectionTimeout' ] = connectionTimeout; };
		if( !isNull( custom ) ) { ds[ 'custom' ] = custom; };
		if( !isNull( dsn ) ) { ds[ 'dsn' ] = dsn; };
		if( !isNull( password ) ) { ds[ 'password' ] = password; };
		if( !isNull( host ) ) { ds[ 'host' ] = host; };
		if( !isNull( metaCacheTimeout ) ) { ds[ 'metaCacheTimeout' ] = metaCacheTimeout; };
		if( !isNull( port ) ) { ds[ 'port' ] = port; };
		if( !isNull( storage ) ) { ds[ 'storage' ] = storage; };
		if( !isNull( username ) ) { ds[ 'username' ] = username; };
		if( !isNull( validate ) ) { ds[ 'validate' ] = validate; };
		if( !isNull( SID ) ) { ds[ 'SID' ] = SID; };
		
		var thisDatasources = getDataSources() ?: {};
		thisDatasources[ arguments.name ] = ds; 
		setDatasources( thisDatasources );
		return this;
	}
	
	/**
	* Add a single mail server to the config
	* 
	* @idleTimout Idle timeout in seconds
	* @lifeTimeout Overall timeout in seconds
	* @password Plain text password for mail server
	* @port Port for mail server
	* @smtp Host address of mail server
	* @ssl True/False to use SSL for connection
	* @tls True/False to use TLS for connection
	* @username Username for mail server
	*/
	function addMailServer(
		numeric idleTimeout,
		numeric lifeTimeout,
		string password,
		numeric port,
		string smtp,
		boolean SSL,
		boolean TLS,
		string username		
	) {
			
		var mailServer = {};
		if( !isNull( idleTimeout ) ) { mailServer[ 'idleTimeout' ] = idleTimeout; };
		if( !isNull( lifeTimeout ) ) { mailServer[ 'lifeTimeout' ] = lifeTimeout; };
		if( !isNull( password ) ) { mailServer[ 'password' ] = password; };
		if( !isNull( port ) ) { mailServer[ 'port' ] = port; };
		if( !isNull( smtp ) ) { mailServer[ 'smtp' ] = smtp; };
		if( !isNull( ssl ) ) { mailServer[ 'ssl' ] = ssl; };
		if( !isNull( tls ) ) { mailServer[ 'tls' ] = tls; };
		if( !isNull( username ) ) { mailServer[ 'username' ] = username; };
		
		var thisMailServers = getMailServers() ?: [];
		thisMailServers.append( mailServer ); 
		setMailServers( thisMailServers );
		return this;
	}
	
	/**
	* Add a single CF mapping to the config
	*
	* @virtual The virtual path such as /foo
	* @physical The physical path that the mapping points to
	* @archive Path to the Lucee/Railo archive
	* @inspectTemplate String containing one of "never", "once", "always", "" (inherit)
	* @listenerMode 
	* @listenerType 
	* @primary Strings containing one of "physical", "archive"
	* @readOnly True/false
	*/
	function addCFMapping(
			required string virtual,
			string physical,
			string archive,
			string inspectTemplate,
			string listenerMode,
			string listenerType,
			string primary,
			boolean readOnly
		) {
		
		var mapping = {};
		if( !isNull( physical ) ) { mapping.physical = physical; };
		if( !isNull( archive ) ) { mapping.archive = archive; };
		if( !isNull( arguments.inspectTemplate ) ) { mapping.inspectTemplate = arguments.inspectTemplate; };
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
		return getUtil().formatJson( getMemento() );
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
		variables.md = variables.md ?: getUtil().getInheritedMetaData( this );
		var configProperties = [];
		for( var prop in md.properties ) {
			if( prop._isCFConfig ?: false ) {
				configProperties.append( prop.name );				
			}
		}
		return configProperties;
	}

}