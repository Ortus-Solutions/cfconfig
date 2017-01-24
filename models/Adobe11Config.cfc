/**
* I represent the behavior of reading and writing CF engine config in the format compatible with an Adobe 11.x server
* I extend the BaseConfig class, which represents the data itself.
*/
component accessors=true extends='BaseConfig' {
	
	property name='runtimeConfigPath' type='string';
	property name='runtimeConfigTemplate' type='string';

	property name='clientStoreConfigPath' type='string';
	property name='clientStoreConfigTemplate' type='string';

	property name='watchConfigPath' type='string';
	property name='watchConfigTemplate' type='string';

	property name='mailConfigPath' type='string';
	property name='mailConfigTemplate' type='string';

	property name='datasourceConfigPath' type='string';
	property name='datasourceConfigTemplate' type='string';


	property name='seedPropertiesPath' type='string';
	property name='AdobePasswordManager';
	
	/**
	* Constructor
	*/
	function init() {
		setRuntimeConfigTemplate( expandPath( '/resources/adobe11/neo-runtime.xml' ) );		
		setRuntimeConfigPath( '/lib/neo-runtime.xml' );
		
		setClientStoreConfigTemplate( expandPath( '/resources/adobe11/neo-clientstore.xml' ) );		
		setClientStoreConfigPath( '/lib/neo-clientstore.xml' );
		
		setWatchConfigTemplate( expandPath( '/resources/adobe11/neo-watch.xml' ) );		
		setWatchConfigPath( '/lib/neo-watch.xml' );
		
		setMailConfigTemplate( expandPath( '/resources/adobe11/neo-mail.xml' ) );		
		setMailConfigPath( '/lib/neo-mail.xml' );
		
		setDatasourceConfigTemplate( expandPath( '/resources/adobe11/neo-datasource.xml' ) );
		setDatasourceConfigPath( '/lib/neo-datasource.xml' );
		
		setSeedPropertiesPath( '/lib/seed.properties' );
		setAdobePasswordManager( new AdobePasswordManager() );
		
		super.init();
	}
	
	/**
	* I read in config
	*
	* @CFHomePath The JSON file to read from
	*/
	function read( string CFHomePath ){
		// Override what's set if a path is passed in
		setCFHomePath( arguments.CFHomePath ?: getCFHomePath() );
		
		if( !len( getCFHomePath() ) ) {
			throw 'No CF home specified to read from';
		}
		
		readRuntime();
		readClientStore();
		readWatch();
		readMail();
		readDatasource();
			
		return this;
	}
	
	private function readRuntime() {
		thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getRuntimeConfigPath(), '/' ) );
		
		fileWrite( expandPath( '/newConfig.json' ), formatJSON( thisConfig ) );
		
		setSessionMangement( thisConfig[ 7 ].session.enable );
		setSessionTimeout( thisConfig[ 7 ].session.timeout );
		setSessionMaximumTimeout( thisConfig[ 7 ].session.maximum_timeout );
		setSessionType( thisConfig[ 7 ].session.usej2eesession ? 'j2ee' : 'j2ee' );
		
		setApplicationMangement( thisConfig[ 7 ].application.enable );
		setApplicationTimeout( thisConfig[ 7 ].application.timeout );
		setApplicationMaximumTimeout( thisConfig[ 7 ].application.maximum_timeout );
		
		// Stored as 0/1
		setErrorStatusCode( ( thisConfig[ 8 ].EnableHTTPStatus == 1 ) );
		setMissingErrorTemplate( thisConfig[ 8 ].missing_template );
		setGeneralErrorTemplate( thisConfig[ 8 ].site_wide );
		
		var ignoreList = '/CFIDE,/gateway';
		for( var thisMapping in thisConfig[ 9 ] ) {
			if( !listFindNoCase( ignoreList, thisMapping ) ){
				addCFMapping( thisMapping, thisConfig[ 9 ][ thisMapping ] );
			}
		}		
		
		setRequestTimeoutEnabled( thisConfig[ 10 ].timeoutRequests );
		setRequestTimeout( '0,0,0,#thisConfig[ 10 ].timeoutRequestTimeLimit#' );
		setPostParametersLimit( thisConfig[ 10 ].postParametersLimit );
		setPostSizeLimit( thisConfig[ 10 ].postSizeLimit );
				
		setTemplateCacheSize( thisConfig[ 11 ].templateCacheSize );
		if( thisConfig[ 11 ].trustedCacheEnabled ) {
			setInspectTemplate( 'never' );
		} else if ( thisConfig[ 11 ].inRequestTemplateCacheEnabled ?: false ) {
			setInspectTemplate( 'once' );
		} else {
			setInspectTemplate( 'always' );
		}
		setSaveClassFiles(  thisConfig[ 11 ].saveClassFiles  );
		setComponentCacheEnabled( thisConfig[ 11 ].componentCacheEnabled );
		
		setMailDefaultEncoding( thisConfig[ 12 ].defaultMailCharset );
		
		setCFFormScriptDirectory( thisConfig[ 14 ].CFFormScriptSrc );
		
		// Adobe doesn't do "all" or "none" like Lucee, just the list.  Empty string if nothing.
		setScriptProtect( thisConfig[ 15 ] );
		
		setPerAppSettingsEnabled( thisConfig[ 16 ].isPerAppSettingsEnabled );				
		// Adobe stores the inverse of Lucee
		setUDFTypeChecking( !thisConfig[ 16 ].cfcTypeCheckEnabled );
		setDisableInternalCFJavaComponents( thisConfig[ 16 ].disableServiceFactory );
		// Lucee and Adobe store opposite value
		setDotNotationUpperCase( !thisConfig[ 16 ].preserveCaseForSerialize );
		setSecureJSON( thisConfig[ 16 ].secureJSON );
		setSecureJSONPrefix( thisConfig[ 16 ].secureJSONPrefix );
		setMaxOutputBufferSize( thisConfig[ 16 ].maxOutputBufferSize );
		setInMemoryFileSystemEnabled( thisConfig[ 16 ].enableInMemoryFileSystem );
		setInMemoryFileSystemLimit( thisConfig[ 16 ].inMemoryFileSystemLimit );
		setInMemoryFileSystemAppLimit( thisConfig[ 16 ].inMemoryFileSystemAppLimit );
		setAllowExtraAttributesInAttrColl( thisConfig[ 16 ].allowExtraAttributesInAttrColl );
		setDisallowUnamedAppScope( thisConfig[ 16 ].dumpunnamedappscope );
		setAllowApplicationVarsInServletContext( thisConfig[ 16 ].allowappvarincontext );
		setCFaaSGeneratedFilesExpiryTime( thisConfig[ 16 ].CFaaSGeneratedFilesExpiryTime );
		setORMSearchIndexDirectory( thisConfig[ 16 ].ORMSearchIndexDirectory );
		setGoogleMapKey( thisConfig[ 16 ].googleMapKey );
		setServerCFCEenabled( thisConfig[ 16 ].enableServerCFC );
		setServerCFC( thisConfig[ 16 ].serverCFC );
		setCompileExtForCFInclude( thisConfig[ 16 ].compileextforinclude );
		setSessionCookieTimeout( thisConfig[ 16 ].sessionCookieTimeout );
		setSessionCookieHTTPOnly( thisConfig[ 16 ].httpOnlySessionCookie );
		setSessionCookieSecure( thisConfig[ 16 ].secureSessionCookie );
		setSessionCookieDisableUpdate( thisConfig[ 16 ].internalCookiesDisableUpdate );
		
		// Map Adobe values to shared Lucee settings
		switch( thisConfig[ 16 ].applicationCFCSearchLimit ) {
			case '1' :
				setApplicationMode( 'curr2driveroot' );
				break;
			case '2' :
				setApplicationMode( 'curr2root' );
				break;
			case '3' :
				setApplicationMode( 'currorroot' );
		}
				
		setThrottleThreshold( thisConfig[ 18 ][ 'throttle-threshold' ] );
		setTotalThrottleMemory( thisConfig[ 18 ][ 'total-throttle-memory' ] );
		
	//	dump( thisConfig );
	}
	
	private function readClientStore() {
		thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getClientStoreConfigPath(), '/' ) );
				
		setUseUUIDForCFToken( thisConfig[ 2 ].uuidToken );
	}
	
	private function readWatch() {
		thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getWatchConfigPath(), '/' ) );
	
		setWatchConfigFilesForChangesEnabled( thisConfig[ 'watch.watchEnabled' ] );
		setWatchConfigFilesForChangesInterval( thisConfig[ 'watch.interval' ] );
		setWatchConfigFilesForChangesExtensions( thisConfig[ 'watch.extensions' ] );
	}
	
	private function readMail() {
		var passwordManager = getAdobePasswordManager().setSeedProperties( getCFHomePath().listAppend( getSeedPropertiesPath(), '/' ) );
		thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getMailConfigPath(), '/' ) );
		
		setMailSpoolEnable( thisConfig.spoolEnable );
		setMailSpoolInterval( thisConfig.schedule );
		setMailConnectionTimeout( thisConfig.timeout );
		setMailDownloadUndeliveredAttachments( thisConfig.allowDownload );
		setMailSignMesssage( thisConfig.sign );
		setMailSignKeystore( thisConfig.keystore );
		setMailSignKeystorePassword( passwordManager.decryptMailServer( thisConfig.keystorepassword ) );
		setMailSignKeyAlias( thisConfig.keyAlias );
		setMailSignKeyPassword( passwordManager.decryptMailServer( thisConfig.keypassword ) );
		
		addMailServer(
			smtp = thisConfig.server,
			username = thisConfig.username,
			password = passwordManager.decryptMailServer( thisConfig.password ),
			port = thisConfig.port,
			SSL= thisConfig.useSSL,
			TSL = thisConfig.useTLS		
		);	
	}
	
	private function readDatasource() {
		var passwordManager = getAdobePasswordManager().setSeedProperties( getCFHomePath().listAppend( getSeedPropertiesPath(), '/' ) );
		thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getDatasourceConfigPath(), '/' ) );
		var datasources = thisConfig[ 1 ];
		
		for( var datasource in datasources ) {
			dump(datasource);
			dump(datasources[ datasource ]);
		}
	}

	/**
	* I write out config from a base JSON format
	*
	* @CFHomePath The JSON file to write to
	*/
	function write( string CFHomePath ){
		setCFHomePath( arguments.CFHomePath ?: getCFHomePath() );
		var thisCFHomePath = getCFHomePath();
		
		if( !len( thisCFHomePath ) ) {
			throw 'No CF home specified to write to';
		}
		
		var configFilePath = locateConfigFile();
		
		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfigRaw = fileRead( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var configFileTemplate = getConfigFileTemplate();
			var thisConfigRaw = fileRead( configFileTemplate );			
		}
		
		var thisConfig = XMLParse( thisConfigRaw );
		
		writeDatasources( thisConfig );
		
		// Ensure the parent directories exist
		directoryCreate( path=getDirectoryFromPath( configFilePath ), createPath=true, ignoreExists=true )
		fileWrite( configFilePath, toString( thisConfig ) );
		
		return this;
	}
	
	private function readWDDXConfigFile( configFilePath ) {
		if( !fileExists( configFilePath ) ) {
			throw "The config file doesn't exist [#configFilePath#]";
		}
		
		var thisConfigRaw = fileRead( configFilePath );
		if( !isXML( thisConfigRaw ) ) {
			throw "Config file doesn't contain XML [#configFilePath#]";
		}
		
		// Work around Lucee bug:
		// https://luceeserver.atlassian.net/browse/LDEV-1167
		thisConfigRaw = reReplaceNoCase( thisConfigRaw, '\s*type=["'']coldfusion\.server\.ConfigMap["'']', '', 'all' );
		
		wddx action='wddx2cfml' input=thisConfigRaw output='local.thisConfig';
		return local.thisConfig;		
	}
	
}