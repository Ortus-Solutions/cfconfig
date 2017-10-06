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
	// One of the strings "memory", "file", "cookie", <cache-name>, <datasource-name>, "Registry"
	property name='clientStorage' type='string' _isCFConfig=true;
	// Number of minutes between client storage purge.  Not to be less tham 30 minutes.
	property name='clientStoragePurgeInterval' type='numeric' _isCFConfig=true;
	// A struct of valid client storage locations including registry, cookie, and any configured datasources. Only used by Adobe.
	property name='clientStorageLocations' type='struct' _isCFConfig=true;
	// TODO: Add functions/commands to manage this manually.
	
	
	
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
			
	
	// Maximum number of simultaneous Template requests
	property name='maxTemplateRequests' type='numeric' _isCFConfig=true;
	// Maximum number of simultaneous Flash Remoting requests
	property name='maxFlashRemotingeRequests' type='numeric' _isCFConfig=true;
	// Maximum number of simultaneous Web Service requests
	property name='maxWebServiceRequests' type='numeric' _isCFConfig=true;
	// Maximum number of simultaneous CFC function requests
	property name='maxCFCFunctionRequests' type='numeric' _isCFConfig=true;
	// Maximum number of simultaneous Report threads
	property name='maxReportRequests' type='numeric' _isCFConfig=true;
	// Maximum number of threads available for CFTHREAD
	property name='maxCFThreads' type='numeric' _isCFConfig=true;
	// Timeout requests waiting in queue after XX seconds
	property name='requestQueueTimeout' type='numeric' _isCFConfig=true;
	// Request Queue Timeout Page
	property name='requestQueueTimeoutPage' type='string' _isCFConfig=true;
			
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
	//property name='debuggingDBEnabled' type='string' _isCFConfig=true;
	//property name='debuggingExceptionsEnabled' type='boolean' _isCFConfig=true;
	//property name='debuggingDBActivityEnabled' type='boolean' _isCFConfig=true;
	//property name='debuggingQueryUsageEnabled' type='boolean' _isCFConfig=true;
	//property name='debuggingTracingEnabled' type='boolean' _isCFConfig=true;
	//property name='debuggingDumpEnabled' type='boolean' _isCFConfig=true;
	//property name='debuggingTimerEnabled' type='boolean' _isCFConfig=true;
	//property name='debuggingImplicitVariableAccessEnabled' type='boolean' _isCFConfig=true;
	
	
	// Enable robust error information (Adobe only)
	property name='robustExceptionEnabled' type='boolean' _isCFConfig=true;
	// Enable Ajax debugging window (Adobe only)
	property name='ajaxDebugWindowEnabled' type='boolean' _isCFConfig=true;
	// Enable Request Debugging Output 
	property name='debuggingEnabled' type='boolean' _isCFConfig=true;
	// Remote DOM Inspection Settings 
	property name='weinreRemoteInspectionEnabled' type='boolean' _isCFConfig=true;
	// Report Execution Times
	property name='debuggingReportExecutionTimes' type='boolean' _isCFConfig=true;
	
	
	// Enable Flash remoting
	property name='FlashRemotingEnable' type='boolean' _isCFConfig=true;
	//  Enable Remote Adobe LiveCycle Data Management access
	property name='flexDataServicesEnable' type='boolean' _isCFConfig=true;
	// Enable RMI over SSL for Data Management
	property name='RMISSLEnable' type='boolean' _isCFConfig=true;
	// RMI SSL Keystore
	property name='RMISSLKeystore' type='string' _isCFConfig=true;
	// RMI SSL Keystore Password
	property name='RMISSLKeystorePassword' type='string' _isCFConfig=true;
	
	// Plain text admin password
	property name='adminPassword' type='string' _isCFConfig=true;
	// Plain text admin RDS password
	property name='adminRDSPassword' type='string' _isCFConfig=true;
	// True/false is RDS enabled?
	property name='adminRDSEnabled' type='boolean' _isCFConfig=true;
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
	
	
	// Password required for admin
	property name='adminLoginRequired' type='boolean' _isCFConfig=true;
	// Password required for RDS
	property name='adminRDSLoginRequired' type='boolean' _isCFConfig=true;
	// user ID required for admin login. False means just a password is required
	property name='adminUserIDRequired' type='boolean' _isCFConfig=true;
	// user ID required for RDS login. False means just a password is required
	property name='adminRDSUserIDRequired' type='boolean' _isCFConfig=true;
	// Default/root admin user ID
	property name='adminRootUserID' type='string' _isCFConfig=true;
	// Allow more than one user to be logged into the same userID at once in the admin
	property name='adminAllowConcurrentLogin' type='boolean' _isCFConfig=true;
	// Enable sandbox security
	property name='sandboxEnabled' type='boolean' _isCFConfig=true;
	// List of allowed IPs for exposed services.  Formatted like 1.2.3.4,5.6.7.*
	property name='servicesAllowedIPList' type='string' _isCFConfig=true;
	// List of allowed IPs for admin access.  Formatted like 1.2.3.4,5.6.7.*
	property name='adminAllowedIPList' type='string' _isCFConfig=true;
	// Enable secure profile.  Note, fipping this flag doesn't actually change any of the security settings.  It really just tracks the fact that you've enabled it at some point.
	property name='secureProfileEnabled' type='boolean' _isCFConfig=true;
	
	
	// TODO: adminUsers array (AuthorizedUsers)
	// TODO: sandboxes (contexts)
	
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
	* @type The type of cache. This is a shortcut for providing the "class" parameter. Values "ram", and "ehcache".
	* @readOnly No idea what this does
	* @storage Is this cache used for session or client scope storage?
	* @custom A struct of settings that are meaningful to this cache provider.
	*/
	function addCache(
		required string name,
		string type,
		string class,
		boolean readOnly,
		boolean storage,
		struct custom
	) {
		var cacheConnection = {};
		if( !isNull( class ) ) { cacheConnection[ 'class' ] = class; };
		if( !isNull( type ) ) { cacheConnection[ 'type' ] = type; };
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
	* 
	* @name Name of datasource
	* @allowSelect Allow select operations
	* @allowDelete Allow delete operations
	* @allowUpdate Allow update operations
	* @allowInsert Allow insert operations
	* @allowCreate Allow create operations
	* @allowGrant Allow grant operations
	* @allowRevoke Allow revoke operations
	* @allowDrop Allow drop operations
	* @allowAlter Allow alter operations
	* @allowStoredProcs Allow Stored proc calls
	* @blob Enable blob
	* @blobBuffer Number of bytes to retreive in binary fields 
	* @class Java class of driver
	* @clob Enable clob
	* @clobBuffer Number of chars to retreive in long text fields 
	* @maintainConnections Maintain connections accross client requests
	* @connectionLimit Max number of connections. -1 means unlimimted
	* @connectionTimeout Connectiontimeout in minutes
	* @connectionTimeoutInterval Number of seconds connections are checked to see if they've timed out
	* @maxPooledStatements Max pooled statements if maintain connections is on.
	* @queryTimeout Max time in seconds a query is allowed to run.  Set to 0 to disable
	* @disableConnections Suspend all client connections
	* @loginTimeout Number of seconds for login timeout
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
	* @validate Enable validating this datasource connection every time it's used
	* @validationQuery Query to run when validating datasource connection
	* @logActivity Enable logging queries to a text file
	* @logActivityFile A file path ending with .txt to log to	
	* @disableAutogeneratedKeyRetrieval Disable retrieval of autogenerated keys
	* @SID Used for Oracle datasources
	* @linkedServers Enable Oracle linked servers support
	* @clientHostname Client Information - Client hostname
	* @clientUsername Client Information - Client username
	* @clientApplicationName Client Information - Application name
	* @clientApplicationNamePrefix Client Information - Application name prefix
	* @description Description of this datasource.  Informational only.
	*
	* logActivity notes
	* ;SpyAttributes=(log=(file)C:/foobar.txt; linelimit=80;logTName=yes;timestamp=yes)</
	*/
	function addDatasource(
			required string name,
			boolean allowSelect,
			boolean allowDelete,
			boolean allowUpdate,
			boolean allowInsert,
			boolean allowCreate,
			boolean allowGrant,
			boolean allowRevoke,
			boolean allowDrop,
			boolean allowAlter,
			boolean allowStoredProcs,
			boolean blob,
			numeric blobBuffer,
			string class,
			boolean clob,
			numeric clobBuffer,
			boolean maintainConnections,
			numeric connectionLimit,
			numeric connectionTimeout,
			numeric connectionTimeoutInterval,
			numeric maxPooledStatements,
			numeric queryTimeout,
			numeric loginTimeout,
			boolean disableConnections,
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
			string validationQuery,
			boolean logActivity,
			string logActivityFile,
			boolean disableAutogeneratedKeyRetrieval,
			string SID,
			boolean linkedServers,
			boolean clientHostname,
			boolean clientUsername,
			boolean clientApplicationName,
			string clientApplicationNamePrefix,
			string description
		) {
		var ds = {};
		if( !isNull( database ) ) { ds[ 'database' ] = database; };
		
		if( !isNull( allowSelect ) ) { ds[ 'allowSelect' ] = allowSelect; };
		if( !isNull( allowDelete ) ) { ds[ 'allowDelete' ] = allowDelete; };
		if( !isNull( allowUpdate ) ) { ds[ 'allowUpdate' ] = allowUpdate; };
		if( !isNull( allowInsert ) ) { ds[ 'allowInsert' ] = allowInsert; };
		if( !isNull( allowCreate ) ) { ds[ 'allowCreate' ] = allowCreate; };
		if( !isNull( allowGrant ) ) { ds[ 'allowGrant' ] = allowGrant; };
		if( !isNull( allowRevoke ) ) { ds[ 'allowRevoke' ] = allowRevoke; };
		if( !isNull( allowDrop ) ) { ds[ 'allowDrop' ] = allowDrop; };
		if( !isNull( allowAlter ) ) { ds[ 'allowAlter' ] = allowAlter; };
		if( !isNull( allowStoredProcs ) ) { ds[ 'allowStoredProcs' ] = allowStoredProcs; };
		
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
		if( !isNull( maintainConnections ) ) { ds[ 'maintainConnections' ] = maintainConnections; };
		if( !isNull( maxPooledStatements ) ) { ds[ 'maxPooledStatements' ] = maxPooledStatements; };
		if( !isNull( connectionTimeoutInterval ) ) { ds[ 'connectionTimeoutInterval' ] = connectionTimeoutInterval; };
		if( !isNull( queryTimeout ) ) { ds[ 'queryTimeout' ] = queryTimeout; };
		if( !isNull( logActivity ) ) { ds[ 'logActivity' ] = logActivity; };
		if( !isNull( logActivityFile ) ) { ds[ 'logActivityFile' ] = logActivityFile; };
		if( !isNull( disableConnections ) ) { ds[ 'disableConnections' ] = disableConnections; };
		if( !isNull( loginTimeout ) ) { ds[ 'loginTimeout' ] = loginTimeout; };
		if( !isNull( clobBuffer ) ) { ds[ 'clobBuffer' ] = clobBuffer; };
		if( !isNull( blobBuffer ) ) { ds[ 'blobBuffer' ] = blobBuffer; };
		if( !isNull( disableAutogeneratedKeyRetrieval ) ) { ds[ 'disableAutogeneratedKeyRetrieval' ] = disableAutogeneratedKeyRetrieval; };
		if( !isNull( validationQuery ) ) { ds[ 'validationQuery' ] = validationQuery; };
		if( !isNull( linkedServers ) ) { ds[ 'linkedServers' ] = linkedServers; };
		if( !isNull( clientHostname ) ) { ds[ 'clientHostname' ] = clientHostname; };
		if( !isNull( clientUsername ) ) { ds[ 'clientUsername' ] = clientUsername; };
		if( !isNull( clientApplicationName ) ) { ds[ 'clientApplicationName' ] = clientApplicationName; };
		if( !isNull( clientApplicationNamePrefix ) ) { ds[ 'clientApplicationNamePrefix' ] = clientApplicationNamePrefix; };
		if( !isNull( description ) ) { ds[ 'description' ] = description; };
		
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
	* Add a single client storage location to the config.  Only used for Adobe engines
	* 
	* @name Name of the storage.  "cookie", "registry" or a datasource name
	* @description The description of the storage
	* @DSN Name of DSN for JDBC storage locations
	* @disableGlobals Disable global client variable updates
	* @purgeEnable Purge data for clients that remain unvisited
	* @purgeTimeout Number of days before purging data
	* @type The string "cookie", "registry", or "JDBC"
	*/
	function addClientStorageLocation(
		required string name,
		string description,
		string DSN,
		boolean disableGlobals,
		boolean purgeEnable,
		numeric purgeTimeout,
		string type
	) {
			
		var clientStorageLocation = {};
		if( !isNull( name ) ) { clientStorageLocation[ 'name' ] = name; };
		if( !isNull( description ) ) { clientStorageLocation[ 'description' ] = description; };
		if( !isNull( DSN ) ) { clientStorageLocation[ 'DSN' ] = DSN; };
		if( !isNull( disableGlobals ) ) { clientStorageLocation[ 'disableGlobals' ] = disableGlobals; };
		if( !isNull( purgeEnable ) ) { clientStorageLocation[ 'purgeEnable' ] = purgeEnable; };
		if( !isNull( purgeTimeout ) ) { clientStorageLocation[ 'purgeTimeout' ] = purgeTimeout; };
		if( !isNull( type ) ) { clientStorageLocation[ 'type' ] = type; };
		
		var thisClientStorageLocations = getClientStorageLocations() ?: {};
		thisClientStorageLocations[ name ] = clientStorageLocation; 
		setClientStorageLocations( thisClientStorageLocations );
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