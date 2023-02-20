/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
*
* I represent shared behavior for all Adobe providers.  The concrete providers can override my methods and proeprties as neccessary.
* I extend the BaseConfig class, which represents the data itself.
*/
component accessors=true extends='cfconfig-services.models.BaseConfig' {


	// ----------------------------------------------------------------------------------------
	// Depdendency Injections
	// ----------------------------------------------------------------------------------------
	property name='DSNUtil' inject='BaseAdobeDSNMapper@cfconfig-services';

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

	property name='securityConfigPath' type='string';
	property name='securityConfigTemplate' type='string';

	property name='debugConfigPath' type='string';
	property name='debugConfigTemplate' type='string';

	property name='schedulerConfigPath' type='string';
	property name='schedulerConfigTemplate' type='string';

	property name='eventGatewayConfigPath' type='string';
	property name='eventGatewayConfigTemplate' type='string';

	property name='websocketConfigPath' type='string';
	property name='websocketConfigTemplate' type='string';

	// I'm basically always writing all properties in these two files, so not bothering with a template.
	property name='seedPropertiesPath' type='string';
	property name='passwordPropertiesPath' type='string';

	property name='licensePropertiesPath' type='string';
	property name='licensePropertiesTemplate' type='string';

	property name='jettyConfigPath' type='string';
	property name='jettyConfigTemplate' type='string';

	property name='dotNetConfigPath' type='string';
	property name='dotNetConfigTemplate' type='string';

	property name='loggingConfigPath' type='string';
	property name='loggingConfigTemplate' type='string';

	property name='updateConfigPath' type='string';
	property name='updateConfigTemplate' type='string';

	property name='documentConfigPath' type='string';
	property name='documentConfigTemplate' type='string';

	property name='graphConfigPath' type='string';
	property name='graphConfigTemplate' type='string';

	property name='cloudConfigPath' type='string';
	property name='cloudConfigTemplate' type='string';

	property name='cloudCredPath' type='string';
	property name='cloudCredTemplate' type='string';

	property name='SAMLPath' type='string';
	property name='SAMLTemplate' type='string';


	property name='AdminRDSLoginRequiredBoolean' type='boolean' default="false" ;
	property name='supportsMultiCloud' type='boolean' default=false;



	/**
	* Constructor
	*/
	function init() {
		super.init();

		setRuntimeConfigPath( '/lib/neo-runtime.xml' );
		setClientStoreConfigPath( '/lib/neo-clientstore.xml' );
		setWatchConfigPath( '/lib/neo-watch.xml' );
		setMailConfigPath( '/lib/neo-mail.xml' );
		setDatasourceConfigPath( '/lib/neo-datasource.xml' );
		setSecurityConfigPath( '/lib/neo-security.xml' );
		setDebugConfigPath( '/lib/neo-debug.xml' );
		setSchedulerConfigPath( '/lib/neo-cron.xml' );
		setEventGatewayConfigPath( '/lib/neo-event.xml' );
		setWebsocketConfigPath( '/lib/neo-websocket.xml' );
		setSeedPropertiesPath( '/lib/seed.properties' );
		setPasswordPropertiesPath( '/lib/password.properties' );
		setLicensePropertiesPath( '/lib/license.properties' );
		setJettyConfigPath( '/lib/jetty.xml' );
		setDotNetConfigPath( '/lib/neo-dotnet.xml' );
		setLoggingConfigPath( '/lib/neo-logging.xml' );
		setUpdateConfigPath( '/lib/neo_updates.xml' );
		setDocumentConfigPath( '/lib/neo-document.xml' );
		setGraphConfigPath( '/lib/neo-graphing.xml' );
		setCloudConfigPath( '/lib/neo-cloud-config.xml' );
		setSAMLPath( '/lib/neo-saml.xml' );
		setCloudCredPath( '/lib/neo-cloudcredential.xml' );


		// CF 10+ stors as a string.  CF9 will override this.
		setAdminRDSLoginRequiredBoolean( false );
		setSupportsMultiCloud( false )

		setFormat( 'adobe' );

		return this;
	}

	// This is not a singleton since it holds state regarding the encryption seeds, so create it fresh each time as a transient.
	private function getAdobePasswordManager() {

		var passwordManager = wirebox.getInstance( 'PasswordManager@adobe-password-util' );
		var pathToPasswordFile = getCFHomePath().listAppend( getSeedPropertiesPath(), '/' );

		if(FileExists(pathToPasswordFile)){
			passwordManager.setSeedProperties( pathToPasswordFile );
		}
		return passwordManager;
	}

	/**
	* I read in config
	*
	* @CFHomePath The path of the coldfusion home, to find lib/neo-*.xml files to read from
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
		readAuth();
		readLicense();
		readSecurity();
		readDebug();
		readScheduler();
		readEventGateway();
		readWebsocket();
		readJetty();
		readDotNet();
		readLogging();
		readUpdate();
		readDocument();
		readGraph();

		if( getSupportsMultiCloud() ) {
			readCloudCred();
			readSAML();
			readCloudConfig();
		}

		return this;
	}

	private function readCloudCred() {
		var passwordManager = getAdobePasswordManager();
		var thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getCloudCredPath(), '/' ) );

		for( var name in thisConfig ) {
			var thisCloudCred = thisConfig[ name ];
			var params = {
				name : name
			};

			if( !isNull( thisCloudCred.vendorName ) ) { params.vendor = thisCloudCred.vendorName }
			if( !isNull( thisCloudCred.connectionString ) ) { params.connectionString = passwordManager.decryptMailServer( thisCloudCred.connectionString ) }
			if( !isNull( thisCloudCred.secretAccessKey ) ) { params.secretKey = passwordManager.decryptMailServer( thisCloudCred.secretAccessKey ) }
			if( !isNull( thisCloudCred.accessKeyId ) ) { params.accessKey = passwordManager.decryptMailServer( thisCloudCred.accessKeyId ) }
			if( !isNull( thisCloudCred.region ) ) { params.region = thisCloudCred.region }

			addCloudCredential( argumentCollection = params );
		}

	}

	private function readCloudConfig() {
		var thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getCloudConfigPath(), '/' ) );

		for( var name in thisConfig ) {
			addCloudService( name=name, config=thisConfig[ name ] );
		}

	}


	private function readSAML() {
		var thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getSAMLPath(), '/' ) );

		if( !isNull( thisConfig.IdentityProvidersMap ) ) {
			for( var name in thisConfig.IdentityProvidersMap ) {
				var thisIdentityProvider = thisConfig.IdentityProvidersMap[ name ];
				var params = {
					name : name
				};

				if( !isNull( thisIdentityProvider.description ) ) { params.description = thisIdentityProvider.description }
				if( !isNull( thisIdentityProvider.encryptCertificate ) ) { params.encryptCertificate = thisIdentityProvider.encryptCertificate }
				if( !isNull( thisIdentityProvider.encryptRequests ) ) { params.encryptRequests = thisIdentityProvider.encryptRequests }
				if( !isNull( thisIdentityProvider.entityId ) ) { params.entityId = thisIdentityProvider.entityId }
				if( !isNull( thisIdentityProvider.logoutResponseUrl ) ) { params.logoutResponseUrl = thisIdentityProvider.logoutResponseUrl }
				if( !isNull( thisIdentityProvider.signCertificate ) ) { params.signCertificate = thisIdentityProvider.signCertificate }
				if( !isNull( thisIdentityProvider.signRequests ) ) { params.signRequests = thisIdentityProvider.signRequests }
				if( !isNull( thisIdentityProvider.SLOBinding ) ) { params.SLOBinding = thisIdentityProvider.SLOBinding }
				if( !isNull( thisIdentityProvider.SLOURL ) ) { params.SLOURL = thisIdentityProvider.SLOURL }
				if( !isNull( thisIdentityProvider.SSOBinding ) ) { params.SSOBinding = thisIdentityProvider.SSOBinding }
				if( !isNull( thisIdentityProvider.SSOURL ) ) { params.SSOURL = thisIdentityProvider.SSOURL }
				if( !isNull( thisIdentityProvider.metadataURL ) ) { params.metadataURL = thisIdentityProvider.metadataURL }

				addSAMLIdentityProvider( argumentCollection = params );
			}
		}

		if( !isNull( thisConfig.ServiceProvidersMap ) ) {
			for( var name in thisConfig.ServiceProvidersMap ) {
				var thisServiceProvider = thisConfig.ServiceProvidersMap[ name ];
				var params = {
					name : name
				};

				if( !isNull( thisServiceProvider.ACSBinding ) ) { params.ACSBinding = thisServiceProvider.ACSBinding }
				if( !isNull( thisServiceProvider.ACSURL ) ) { params.ACSURL = thisServiceProvider.ACSURL }
				if( !isNull( thisServiceProvider.allowIdpInitiatedSso ) ) { params.allowIdpInitiatedSso = thisServiceProvider.allowIdpInitiatedSso }
				if( !isNull( thisServiceProvider.description ) ) { params.description = thisServiceProvider.description }
				if( !isNull( thisServiceProvider.entityId ) ) { params.entityId = thisServiceProvider.entityId }
				if( !isNull( thisServiceProvider.logoutResponseSigned ) ) { params.logoutResponseSigned = thisServiceProvider.logoutResponseSigned }
				if( !isNull( thisServiceProvider.signKeystoreAlias ) ) { params.sdfsdfsignKeystoreAliassdfsd = thisServiceProvider.signKeystoreAlias }
				if( !isNull( thisServiceProvider.signKeystorePassword ) ) { params.signKeystorePassword = thisServiceProvider.signKeystorePassword }
				if( !isNull( thisServiceProvider.signKeystorePath ) ) { params.signKeystorePath = thisServiceProvider.signKeystorePath }
				if( !isNull( thisServiceProvider.signMetadata ) ) { params.signMetadata = thisServiceProvider.signMetadata }
				if( !isNull( thisServiceProvider.signRequests ) ) { params.signRequests = thisServiceProvider.signRequests }
				if( !isNull( thisServiceProvider.SLOBinding ) ) { params.SLOBinding = thisServiceProvider.SLOBinding }
				if( !isNull( thisServiceProvider.SLOURL ) ) { params.SLOURL = thisServiceProvider.SLOURL }
				if( !isNull( thisServiceProvider.stateStore ) ) { params.stateStore = thisServiceProvider.stateStore }
				if( !isNull( thisServiceProvider.strict ) ) { params.strict = thisServiceProvider.strict }
				if( !isNull( thisServiceProvider.wantAssertionsSigned ) ) { params.wantAssertionsSigned = thisServiceProvider.wantAssertionsSigned }

				addSAMLServiceProvider( argumentCollection = params );
			}
		}

	}

	private function readRuntime() {
		var passwordManager = getAdobePasswordManager();
		var thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getRuntimeConfigPath(), '/' ) );

		// Special Adobe Custom Tag path we don't want to remove
		var ignoredCustomTagPaths = [ '##server.coldfusion.rootdir##/CustomTags', '#getCFHomePath()#/CustomTags' ];
		for( var thisMapping in thisConfig[ 4 ] ) {
			// This will remove the spurious name of the custom tag path, but on adobe, they're unnecessary anyway.
			// Adobe only supports the physical path, all the other options are Lucee-specific
			// Add some of the Lucee-specific ones, just in case we want to port our config...
			if( !ignoredCustomTagPaths.findNoCase( normalizeSlashes( thisConfig[ 4 ][ thisMapping ] ) ) ) {
				addCustomTagPath( physical = thisConfig[ 4 ][ thisMapping ], primary = "physical", archive = "" );
			}
		}

		if( !isNull( thisConfig[ 1 ] ) ) { setWhitespaceManagement( translateWhitespaceFromAdobe( thisConfig[ 1 ] ) ); }
		if( !isNull( thisConfig[ 5 ].logging ) ) { setLogCORBACalls( thisConfig[ 5 ].logging ); }
		setSessionManagement( thisConfig[ 7 ].session.enable );
		setSessionTimeout( thisConfig[ 7 ].session.timeout );
		setSessionMaximumTimeout( thisConfig[ 7 ].session.maximum_timeout );
		setSessionType( thisConfig[ 7 ].session.usej2eesession ? 'j2ee' : 'cfml' );

		setApplicationManagement( thisConfig[ 7 ].application.enable );
		setApplicationTimeout( thisConfig[ 7 ].application.timeout );
		setApplicationMaximumTimeout( thisConfig[ 7 ].application.maximum_timeout );

		// Stored as 0/1
		setErrorStatusCode( ( thisConfig[ 8 ].EnableHTTPStatus == 1 ) );
		setMissingErrorTemplate( translateAdobeToSharedErrorTemplate( thisConfig[ 8 ].missing_template ) );
		setGeneralErrorTemplate( translateAdobeToSharedErrorTemplate( thisConfig[ 8 ].site_wide ) );
		setRequestQueueTimeoutPage( thisConfig[ 8 ][ 'queue_timeout' ] );

		var ignoredMappings = [ '/CFIDE', '/gateway' ];
		for( var thisMapping in thisConfig[ 9 ] ) {
			if( !ignoredMappings.findNoCase( thisMapping ) ){
				addCFMapping( thisMapping, thisConfig[ 9 ][ thisMapping ] );
			}
		}

		setRequestTimeoutEnabled( thisConfig[ 10 ].timeoutRequests );
		// Convert from seconds to timespan
		setRequestTimeout( '0,0,0,#thisConfig[ 10 ].timeoutRequestTimeLimit#' );
		setPostParametersLimit( thisConfig[ 10 ].postParametersLimit );
		setPostSizeLimit( thisConfig[ 10 ].postSizeLimit );

		// Request Tuning
		setMaxTemplateRequests( thisConfig[ 10 ][ 'requestLimit' ] );
		setmaxFlashRemotingRequests( thisConfig[ 10 ][ 'flashRemotingLimit' ] );
		setMaxWebServiceRequests( thisConfig[ 10 ][ 'webserviceLimit' ] );
		setMaxCFCFunctionRequests( thisConfig[ 10 ][ 'CFCLimit' ] );
		setMaxReportRequests( thisConfig[ 17 ][ 'numSimultaneousReports' ] );
		setMaxCFThreads( thisConfig[ 16 ][ 'cfthreadpool' ] );
		setRequestQueueTimeout( thisConfig[ 10 ][ 'queueTimeout' ] );

		if( !isNull( thisConfig[ 10 ][ 'logSlowRequests' ] ) ) { setLogSlowRequestsEnabled( thisConfig[ 10 ][ 'logSlowRequests' ] ); }
		if( !isNull( thisConfig[ 10 ][ 'slowRequestTimeLimit' ] ) ) { setLogSlowRequestsThreshold( thisConfig[ 10 ][ 'slowRequestTimeLimit' ] ); }

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
		if( !isNull( thisConfig[ 11 ].enableInternalQueryCache ) ) { setQueryInternalCacheEnabled( thisConfig[ 11 ].enableInternalQueryCache ); }

		setMailDefaultEncoding( thisConfig[ 12 ].defaultMailCharset );

		setCFFormScriptDirectory( thisConfig[ 14 ].CFFormScriptSrc );

		// Adobe doesn't do "all" or "none" like Lucee, just the list.  Empty string if nothing.
		setScriptProtect( thisConfig[ 15 ] );

		setPerAppSettingsEnabled( thisConfig[ 16 ].isPerAppSettingsEnabled );
		// Adobe stores the inverse of Lucee
		setUDFTypeChecking( !thisConfig[ 16 ].cfcTypeCheckEnabled );
		setDisableInternalCFJavaComponents( thisConfig[ 16 ].disableServiceFactory );

		// This setting CF11+
		// Lucee and Adobe store opposite value
		if( !isNull( thisConfig[ 16 ].preserveCaseForSerialize ) ) { setDotNotationUpperCase( !thisConfig[ 16 ].preserveCaseForSerialize ); }
		setSecureJSON( thisConfig[ 16 ].secureJSON );
		setSecureJSONPrefix( thisConfig[ 16 ].secureJSONPrefix );
		if(structKeyExists(thisConfig[ 16 ] , "maxOutputBufferSize" )){
			//Default: 1024   kb
			setMaxOutputBufferSize( thisConfig[ 16 ].maxOutputBufferSize );
		}

		setInMemoryFileSystemEnabled( thisConfig[ 16 ].enableInMemoryFileSystem );

		if(structKeyExists(thisConfig[ 16 ], "inMemoryFileSystemLimit")){
			//default  100 Mb
			setInMemoryFileSystemLimit( thisConfig[ 16 ].inMemoryFileSystemLimit );
		}

		if(structKeyExists(thisConfig[ 16 ],"inMemoryFileSystemAppLimit")){
			setInMemoryFileSystemAppLimit( thisConfig[ 16 ].inMemoryFileSystemAppLimit );
		}

		setAllowExtraAttributesInAttrColl( thisConfig[ 16 ].allowExtraAttributesInAttrColl );

		if(structKeyExists(thisConfig[ 16 ], "dumpunnamedappscope")){
			setDisallowUnamedAppScope( thisConfig[ 16 ].dumpunnamedappscope );
		}

		setFlashRemotingEnable( thisConfig[ 16 ].enableFlashRemoting );
		setFlexDataServicesEnable( thisConfig[ 16 ].enableFlexDataServices );
		setRMISSLEnable( thisConfig[ 16 ].enableRmiSSL );
		setRMISSLKeystore( thisConfig[ 16 ].RmiSSLKeystore );
		if( thisConfig[ 16 ].RmiSSLKeystorePassword.len() ) {
			setRMISSLKeystorePassword( passwordManager.decryptMailServer( thisConfig[ 16 ].RmiSSLKeystorePassword ) );
		}

		// This setting CF11+
		if( !isNull( thisConfig[ 16 ].allowappvarincontext ) ) { setAllowApplicationVarsInServletContext( thisConfig[ 16 ].allowappvarincontext ); }

		setCFaaSGeneratedFilesExpiryTime( thisConfig[ 16 ].CFaaSGeneratedFilesExpiryTime );

		if(structKeyExists(thisConfig[ 16 ], "ORMSearchIndexDirectory")){
			setORMSearchIndexDirectory( thisConfig[ 16 ].ORMSearchIndexDirectory );
		}

		setGoogleMapKey( thisConfig[ 16 ].googleMapKey );
		setServerCFCEenabled( thisConfig[ 16 ].enableServerCFC );
		setServerCFC( thisConfig[ 16 ].serverCFC );

		// This setting CF11+
		if( !isNull( thisConfig[ 16 ].compileextforinclude ) ) { setCompileExtForCFInclude( thisConfig[ 16 ].compileextforinclude ); }

		//CF9 doesn't have any of these.

		if(!isNull(thisConfig[ 16 ].sessionCookieTimeout)){
			setSessionCookieTimeout( thisConfig[ 16 ].sessionCookieTimeout );
		}
		if(!isNull(thisConfig[ 16 ].httpOnlySessionCookie)){
			setSessionCookieHTTPOnly( thisConfig[ 16 ].httpOnlySessionCookie );
		}
		if(!isNull(thisConfig[ 16 ].secureSessionCookie)){
			setSessionCookieSecure( thisConfig[ 16 ].secureSessionCookie );
		}
		if(!isNull(thisConfig[ 16 ].internalCookiesDisableUpdate)){
			setSessionCookieDisableUpdate( thisConfig[ 16 ].internalCookiesDisableUpdate );
		}
		if(!isNull(thisConfig[ 16 ].sessionCookieSamesite)){
			setSessionCookieSamesite( thisConfig[ 16 ].sessionCookieSamesite );
		}

		if( !isNull( thisConfig[ 16 ][ 'blockedExtForFileUpload' ] ) ) { setBlockedExtForFileUpload( thisConfig[ 16 ][ 'blockedExtForFileUpload' ] ); }
		if( !isNull( thisConfig[ 16 ][ 'enableNullSupport' ] ) ) { setNullSupport( thisConfig[ 16 ][ 'enableNullSupport' ] ); }

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

		if( !isNull( thisConfig[ 16 ][ 'sessionStorage' ] ) ) { setSessionStorageLocation( thisConfig[ 16 ][ 'sessionStorage' ] ); }
		if( !isNull( thisConfig[ 16 ][ 'sessionStoragePassword' ] ) ) {
			// Just in case an empty string ever makes it in here, don't try and decrypt it
			if( len( thisConfig[ 16 ][ 'sessionStoragePassword' ] ) ) {
				setSessionStoragePassword( passwordManager.decryptMailServer( thisConfig[ 16 ][ 'sessionStoragePassword' ] ) );
			} else {
				setSessionStoragePassword( thisConfig[ 16 ][ 'sessionStoragePassword' ] );
			}
		}
		if( !isNull( thisConfig[ 16 ][ 'sessionStorageHost' ] ) ) { setSessionStorageHost( thisConfig[ 16 ][ 'sessionStorageHost' ] ); }
		if( !isNull( thisConfig[ 16 ][ 'sessionStorageTimeout' ] ) ) { setSessionStorageTimeout( thisConfig[ 16 ][ 'sessionStorageTimeout' ] ); }
		if( !isNull( thisConfig[ 16 ][ 'sessionStoragePort' ] ) ) { setSessionStoragePort( thisConfig[ 16 ][ 'sessionStoragePort' ] ); }

		setThrottleThreshold( thisConfig[ 18 ][ 'throttle-threshold' ] );
		setTotalThrottleMemory( thisConfig[ 18 ][ 'total-throttle-memory' ] );

	}

	private function readDebug() {
		var thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getDebugConfigPath(), '/' ) );

		if( !isNull( thisConfig[ 1 ].robust_enabled ) ) { setRobustExceptionEnabled( thisConfig[ 1 ].robust_enabled ); }
		if( !isNull( thisConfig[ 1 ].ajax_enabled ) ) { setAjaxDebugWindowEnabled( thisConfig[ 1 ].ajax_enabled ); }
		if( !isNull( thisConfig[ 1 ].enabled ) ) { setDebuggingEnabled( thisConfig[ 1 ].enabled ); }
		if( !isNull( thisConfig[ 1 ].template ) ) { setDebuggingReportExecutionTimes( thisConfig[ 1 ].template ); }
		if( !isNull( thisConfig[ 1 ].template_highlight_minimum ) ) { setDebuggingReportExecutionTimesMinimum( thisConfig[ 1 ].template_highlight_minimum ); }
		if( !isNull( thisConfig[ 1 ].template_mode ) ) { setDebuggingReportExecutionTimesTemplate( thisConfig[ 1 ].template_mode ); }
		if( !isNull( thisConfig[ 1 ].debug_template ) ) { setDebuggingTemplate( thisConfig[ 1 ].debug_template ); }
		if( !isNull( thisConfig[ 1 ].general ) ) { setDebuggingShowGeneral( thisConfig[ 1 ].general ); }
		if( !isNull( thisConfig[ 1 ].database ) ) { setDebuggingShowDatabase( thisConfig[ 1 ].database ); }
		if( !isNull( thisConfig[ 1 ].exception ) ) { setDebuggingShowException( thisConfig[ 1 ].exception ); }
		if( !isNull( thisConfig[ 1 ].trace ) ) { setDebuggingShowTrace( thisConfig[ 1 ].trace ); }
		if( !isNull( thisConfig[ 1 ].TIMER ) ) { setDebuggingShowTimer( thisConfig[ 1 ].TIMER ); }
		if( !isNull( thisConfig[ 1 ].FLASHFORMCOMPILEERRORS ) ) { setDebuggingShowFlashFormCompileErrors( thisConfig[ 1 ].FLASHFORMCOMPILEERRORS ); }
		if( !isNull( thisConfig[ 1 ][ 'variables' ] ) ) { setDebuggingShowVariables( thisConfig[ 1 ][ 'variables' ] ); }
		if( !isNull( thisConfig[ 1 ].applicationvar ) ) { setDebuggingShowVariableApplication( thisConfig[ 1 ].applicationvar ); }
		if( !isNull( thisConfig[ 1 ].cgivar ) ) { setDebuggingShowVariableCGI( thisConfig[ 1 ].cgivar ); }
		if( !isNull( thisConfig[ 1 ].clientvar ) ) { setDebuggingShowVariableClient( thisConfig[ 1 ].clientvar ); }
		if( !isNull( thisConfig[ 1 ].cookievar ) ) { setDebuggingShowVariableCookie( thisConfig[ 1 ].cookievar ); }
		if( !isNull( thisConfig[ 1 ].formvar ) ) { setDebuggingShowVariableForm( thisConfig[ 1 ].formvar ); }
		if( !isNull( thisConfig[ 1 ].requestvar ) ) { setDebuggingShowVariableRequest( thisConfig[ 1 ].requestvar ); }
		if( !isNull( thisConfig[ 1 ].servervar ) ) { setDebuggingShowVariableServer( thisConfig[ 1 ].servervar ); }
		if( !isNull( thisConfig[ 1 ].sessionvar ) ) { setDebuggingShowVariableSession( thisConfig[ 1 ].sessionvar ); }
		if( !isNull( thisConfig[ 1 ].urlvar ) ) { setDebuggingShowVariableURL( thisConfig[ 1 ].urlvar ); }

		if( !isNull( thisConfig[ 2 ].iplist ) ) { setDebuggingIPList( thisConfig[ 2 ].iplist ); }

		if( !isNull( thisConfig[ 3 ].LINE_DEBUGGER_ENABLED ) ) { setLineDebuggerEnabled( thisConfig[ 3 ].LINE_DEBUGGER_ENABLED ); }
		if( !isNull( thisConfig[ 3 ].LINE_DEBUGGER_PORT ) ) { setLineDebuggerPort( thisConfig[ 3 ].LINE_DEBUGGER_PORT ); }
		if( !isNull( thisConfig[ 3 ].MAX_DEBUG_SESSIONS ) ) { setLineDebuggerMaxSessions( thisConfig[ 3 ].MAX_DEBUG_SESSIONS ); }

		if( !isNull( thisConfig[ 4 ].remote_inspection_enabled ) ) { setWeinreRemoteInspectionEnabled( thisConfig[ 4 ].remote_inspection_enabled ); }
	}

	private function readScheduler() {
		var passwordManager = getAdobePasswordManager();
		var thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getSchedulerConfigPath(), '/' ) );

		if( isStruct( thisConfig[ 1 ] ) ) {
			for( var thisTaskID in thisConfig[ 1 ] ) {
				var thisTask = thisConfig[ 1 ][ thisTaskID ];
				var params = {};

				if( !isNull( thisTask.chained ) && isBoolean( thisTask.chained ) ) { params[ 'chained' ] = thisTask.chained; }
				if( !isNull( thisTask.clustered ) && isBoolean( thisTask.clustered ) ) { params[ 'clustered' ] = thisTask.clustered; }
				if( !isNull( thisTask.crontime ) ) { params[ 'crontime' ] = thisTask.crontime; }
				if( !isNull( thisTask.end_date ) ) { params[ 'endDate' ] = thisTask.end_date; }
				if( !isNull( thisTask.end_time ) ) { params[ 'endTime' ] = thisTask.end_time; }
				if( !isNull( thisTask.eventhandler ) ) { params[ 'eventhandler' ] = thisTask.eventhandler; }
				if( isNull( params[ 'eventhandler' ] ) && !isNull( thisTask.eventhandlerrp ) ) { params[ 'eventhandler' ] = thisTask.eventhandlerrp; }
				if( !isNull( thisTask.exclude ) ) { params[ 'exclude' ] = thisTask.exclude; }
				// Combine path and file into a full path
				if( !isNull( thisTask.file ) && !isNull( thisTask.path ) ) { params[ 'file' ] = thisTask.path & thisTask.file; }
				params[ 'group' ] = thisTask.group ?: 'DEFAULT';
				if( !isNull( thisTask.http_port ) ) { params[ 'httpPort' ] = thisTask.http_port; }
				if( !isNull( thisTask.http_proxy_port ) ) { params[ 'httpProxyPort' ] = thisTask.http_proxy_port; }
				if( !isNull( thisTask.interval ) ) { params[ 'interval' ] = thisTask.interval; }
				if( !isNull( thisTask.oncomplete ) ) { params[ 'oncomplete' ] = thisTask.oncomplete; }
				if( !isNull( thisTask.overwrite ) ) { params[ 'overwrite' ] = thisTask.overwrite; }
				if( !isNull( thisTask.password ) && thisTask.password.len() ) { params[ 'password' ] = passwordManager.decryptMailServer( thisTask.password ); }
				if( !isNull( thisTask.priority ) ) { params[ 'priority' ] = thisTask.priority; }
				if( !isNull( thisTask.proxy_password ) && thisTask.proxy_password.len() ) { params[ 'proxyPassword' ] = passwordManager.decryptMailServer( thisTask.proxy_password ); }
				if( !isNull( thisTask.proxy_server ) ) { params[ 'proxyServer' ] = thisTask.proxy_server; }
				if( !isNull( thisTask.proxy_user ) ) { params[ 'proxyUser' ] = thisTask.proxy_user; }
				if( !isNull( thisTask.publish ) && isBoolean( thisTask.publish ) ) { params[ 'saveOutputToFile' ] = thisTask.publish; }
				if( !isNull( thisTask.repeat ) ) { params[ 'repeat' ] = thisTask.repeat; }
				if( !isNull( thisTask.request_time_out ) ) { params[ 'requestTimeOut' ] = thisTask.request_time_out; }
				if( !isNull( thisTask.resolveURL ) && isBoolean( thisTask.resolveURL ) ) { params[ 'resolveURL' ] = thisTask.resolveURL; }
				if( !isNull( thisTask.retryCount ) ) { params[ 'retryCount' ] = thisTask.retryCount; }
				if( !isNull( thisTask.start_date ) ) { params[ 'startDate' ] = thisTask.start_date; }
				if( !isNull( thisTask.start_time ) ) { params[ 'startTime' ] = thisTask.start_time; }

				if( !isNull( thisTask.status ) ) {
					params[ 'status' ] = thisTask.status;
				// Fall back for CF9
				} else if( !isNull( thisTask.paused ) ) {
					if( thisTask.paused ) {
						params[ 'status' ] = 'Paused';
					} else {
						params[ 'status' ] = 'Running';
					}
				}

				if( !isNull( thisTask.task ) ) { params[ 'task' ] = thisTask.task; }
				if( !isNull( thisTask.URL ) ) { params[ 'URL' ] = thisTask.URL; }
				if( !isNull( thisTask.username ) ) { params[ 'username' ] = thisTask.username; }

				// Adobe stores empty string for "ignore"
				if( !isNull( thisTask.onexception ) ) {
					if( !thisTask.onexception.len() ) {
						thisTask.onexception = 'Ignore';
					}
					params[ 'onexception' ] = thisTask.onexception;
				}

				// Adobe stores empty string for "ignore"
				if( !isNull( thisTask.misfire ) ) {
					if( !thisTask.misfire.len() ) {
						thisTask.misfire = 'Ignore';
					}
					params[ 'misfire' ] = thisTask.misfire;
				}

				addScheduledTask( argumentCollection = params );
			}
		}

		if( !isNull( thisConfig[ 2 ] ) ) { setSchedulerLoggingEnabled( thisConfig[ 2 ] ); }
		if( !isNull( thisConfig[ 3 ] ) ) { setSchedulerClusterDatasource( thisConfig[ 3 ] ); }
		if( !isNull( thisConfig[ 4 ] ) ) { setSchedulerLogFileExtensions( thisConfig[ 4 ] ); }

	}

	private function readEventGateway() {
		var thisConfig=readWDDXConfigFile(getCFHomePath().listAppend(getEventGatewayConfigPath(), '/'));

		setEventGatewayEnabled(thisConfig[ 'GLOBAL' ][ 'ENABLEEVENTGATEWAYSERVICE' ]);
		setEventGatewayMaxQueueSize(thisConfig[ 'GLOBAL' ][ 'MAXQUEUESIZE' ]);
		setEventGatewayThreadpoolSize(thisConfig[ 'GLOBAL' ][ 'THREADPOOLSIZE' ]);

		if (!isNull(thisConfig.instances) && thisConfig.instances.len()) {
			for (var gatewayInstance in thisConfig.instances) {
				var params={};

				if (!isNull(gatewayInstance.cfcpaths) && isValid("array", gatewayInstance.cfcpaths)) { params[ 'cfcpaths' ]=gatewayInstance.cfcpaths; }
				if (!isNull(gatewayInstance.configurationPath)) { params[ 'configurationPath' ]=gatewayInstance.configurationPath; }
				if (!isNull(gatewayInstance.gatewayId)) { params[ 'gatewayId' ]=gatewayInstance.gatewayId; }
				if (!isNull(gatewayInstance.mode)) { params[ 'mode' ]=gatewayInstance.mode; }
				if (!isNull(gatewayInstance.type)) { params[ 'type' ]=gatewayInstance.type; }

				addGatewayInstance(argumentCollection=params);
			}
		}

		if (!isNull(thisConfig.gateways) && thisConfig.gateways.len()) {
			for (var gateway in thisConfig.gateways) {
				var params={};

				if (!isNull(gateway.class)) { params[ 'class' ]=gateway.class; }
				if (!isNull(gateway.description)) { params[ 'description' ]=gateway.description; }
				if (!isNull(gateway.killontimeout) && isBoolean(gateway.killontimeout)) { params[ 'killontimeout' ]=gateway.killontimeout; }
				if (!isNull(gateway.starttimeout)) { params[ 'starttimeout' ]=gateway.starttimeout; }
				if (!isNull(gateway.type)) { params[ 'type' ]=gateway.type; }

				addGatewayConfiguration(argumentCollection=params);
			}
		}
	}

	private function readWebsocket() {
		var thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getWebsocketConfigPath(), '/' ) );

		if( !isNull( thisConfig[ 'startWebSocketService' ] ) ) { setWebsocketEnabled( thisConfig[ 'startWebSocketService' ] ); }
	}

	private function readJetty() {
		var thisConfig = readXMLConfigFile( getCFHomePath().listAppend( getJettyConfigPath(), '/' ) );

		var hostSearch = XMLSearch( thisConfig, "//Call[@name='addConnector']/Arg/New/Set[@name='host']" );
		var portSearch = XMLSearch( thisConfig, "//Call[@name='addConnector']/Arg/New/Set[@name='port']" );

		if( hostSearch.len() ) {
			setMonitoringServiceHost( hostSearch[ 1 ].XMLText );
		}
		if( portSearch.len() ) {
			setMonitoringServicePort( portSearch[ 1 ].XMLText );
		}

	}

	private function readDotNet() {
		var thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getDotNetConfigPath(), '/' ) );

		if( !isNull( thisConfig[ 'port' ] ) ) { setDotNetPort( thisConfig[ 'port' ] ); }
		if( !isNull( thisConfig[ 'dotnetport' ] ) ) { setDotNetClientPort( thisConfig[ 'dotnetport' ] ); }
		if( !isNull( thisConfig[ 'install_dir' ] ) ) { setDotNetInstallDir( thisConfig[ 'install_dir' ] ); }
		if( !isNull( thisConfig[ 'protocol' ] ) ) { setDotNetProtocol( thisConfig[ 'protocol' ] ); }
	}


	private function readClientStore() {
		var thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getClientStoreConfigPath(), '/' ) );

		if( isStruct( thisConfig[ 2 ] ) ) {
			for( var storageLocationName in thisConfig[ 1 ] ) {
				var thisStorageLocation = thisConfig[ 1 ][ storageLocationName ];

				var params = { name : storageLocationName };
				if( !isNull( thisStorageLocation.description ) ) { params[ 'description' ] = thisStorageLocation.description; }
				if( !isNull( thisStorageLocation.disable_globals ) ) { params[ 'disableGlobals' ] = thisStorageLocation.disable_globals; }
				if( !isNull( thisStorageLocation.purge ) ) { params[ 'purgeEnable' ] = thisStorageLocation.purge; }
				if( !isNull( thisStorageLocation.timeout ) ) { params[ 'purgeTimeout' ] = thisStorageLocation.timeout; }
				if( !isNull( thisStorageLocation.type ) ) { params[ 'type' ] = thisStorageLocation.type; }
				if( !isNull( thisStorageLocation.DSN ) ) { params[ 'DSN' ] = thisStorageLocation.DSN; }

				addClientStorageLocation( argumentCollection = params );
			}
		}

		setClientStorage( thisConfig[ 2 ][ 'default' ] );
		setUseUUIDForCFToken( thisConfig[ 2 ].uuidToken );
		if( !isNull( thisConfig[ 2 ][ 'PURGE_INTERVAL' ] ) ) {
			// A colon-delimited list with 2 items representing hours and minutes. Ex: 1:7
			setClientStoragePurgeInterval( ( thisConfig[ 2 ][ 'PURGE_INTERVAL' ].listFirst( ':' ) * 60 ) + thisConfig[ 2 ][ 'PURGE_INTERVAL' ].listLast( ':' ) );
		}
	}

	private function readSecurity() {
		var thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getSecurityConfigPath(), '/' ) );

		if( !isNull( thisConfig[ 'secureprofile.enabled' ] ) ) { setSecureProfileEnabled( thisConfig[ 'secureprofile.enabled' ] ); }
		if( !isNull( thisConfig[ 'rds.enabled' ] ) ) { setAdminRDSEnabled( thisConfig[ 'rds.enabled' ] ); }
		if( !isNull( thisConfig[ 'admin.userid.root.salt' ] ) ) { setAdminSalt( thisConfig[ 'admin.userid.root.salt' ] ); }
		if( !isNull( thisConfig[ 'admin.security.enabled' ] ) ) { setAdminLoginRequired( thisConfig[ 'admin.security.enabled' ] ); }
		if( !isNull( thisConfig[ 'admin.userid.required' ] ) ) { setAdminUserIDRequired( thisConfig[ 'admin.userid.required' ] ); }
		if( !isNull( thisConfig[ 'admin.userid.root' ] ) ) { setAdminRootUserID( thisConfig[ 'admin.userid.root' ] ); }
		if( !isNull( thisConfig[ 'allowconcurrentadminlogin' ] ) ) { setAdminAllowConcurrentLogin( thisConfig[ 'allowconcurrentadminlogin' ] ); }
		if( !isNull( thisConfig[ 'sbs.security.enabled' ] ) ) { setSandboxEnabled( thisConfig[ 'sbs.security.enabled' ] ); }
		if( !isNull( thisConfig[ 'allowedAdminIPList' ] ) ) { setAdminAllowedIPList( thisConfig[ 'allowedAdminIPList' ] ); }
		if( !isNull( thisConfig[ 'allowedIPList' ] ) ) { setServicesAllowedIPList( thisConfig[ 'allowedIPList' ] ); }
		if( !isNull( thisConfig[ 'rds.security.enabled' ] ) ) { setAdminRDSLoginRequired( thisConfig[ 'rds.security.enabled' ] ); }
		if( !isNull( thisConfig[ 'rds.security.usesinglerdspassword' ] ) ) { setAdminRDSUserIDRequired( thisConfig[ 'rds.security.usesinglerdspassword' ] ); }
	}

	private function readWatch() {
		var thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getWatchConfigPath(), '/' ) );

		setWatchConfigFilesForChangesEnabled( thisConfig[ 'watch.watchEnabled' ] );
		setWatchConfigFilesForChangesInterval( thisConfig[ 'watch.interval' ] );
		setWatchConfigFilesForChangesExtensions( thisConfig[ 'watch.extensions' ] );
	}

	private function readMail() {
		var passwordManager = getAdobePasswordManager();
		var thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getMailConfigPath(), '/' ) );

		if( !isNull( thisConfig.spoolEnable ) ) { setMailSpoolEnable( thisConfig.spoolEnable ); }
		if( !isNull( thisConfig.schedule ) ) { setMailSpoolInterval( thisConfig.schedule ); }
		if( !isNull( thisConfig.timeout ) ) { setMailConnectionTimeout( thisConfig.timeout ); }
		if( !isNull( thisConfig.allowDownload ) ) { setMailDownloadUndeliveredAttachments( thisConfig.allowDownload ); }
		if( !isNull( thisConfig.sign ) ) { setMailSignMesssage( thisConfig.sign ); }
		if( !isNull( thisConfig.keystore ) ) { setMailSignKeystore( thisConfig.keystore ); }
		if( !isNull( thisConfig.keystorepassword ) ) { setMailSignKeystorePassword( passwordManager.decryptMailServer( thisConfig.keystorepassword ) ); }
		if( !isNull( thisConfig.keyAlias ) ) { setMailSignKeyAlias( thisConfig.keyAlias ); }
		if( !isNull( thisConfig.keypassword ) ) { setMailSignKeyPassword( passwordManager.decryptMailServer( thisConfig.keypassword ) ); }
		if( !isNull( thisConfig.mailsentloggingenable ) ) { setMailLogEnabled( thisConfig.mailsentloggingenable ); }
		if( !isNull( thisConfig.severity ) ) { setMailLogSeverity( thisConfig.severity ); }
		if( !isNull( thisConfig.maxthreads ) ) { setMailMaxThreads( thisConfig.maxthreads ); }


		if( !isNull( thisConfig.server ) && thisConfig.server.len() ) {
			addMailServer(
				smtp = thisConfig.server,
				username = thisConfig.username ?: '',
				password = ( ( thisConfig.password ?: '' ).len() ? passwordManager.decryptMailServer( thisConfig.password ) : '' ),
				port = val( thisConfig.port ?: '0' ),
				SSL= thisConfig.useSSL ?: false,
				TLS = thisConfig.useTLS ?: false
			);

		}
	}

	private function readDatasource() {
		var passwordManager = getAdobePasswordManager();
		var thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getDatasourceConfigPath(), '/' ) );
		var datasources = thisConfig[ 1 ];

		for( var datasource in datasources ) {
			// For brevity
			var ds = datasources[ datasource ];

			addDatasource(
				name = datasource,

				allowSelect = ds.select ?: true,
				allowDelete = ds.delete ?: true,
				allowUpdate = ds.update ?: true,
				allowInsert = ds.insert ?: true,
				allowCreate = ds.create ?: true,
				allowGrant = ds.grant ?: true,
				allowRevoke = ds.revoke ?: true,
				allowDrop = ds.drop ?: true,
				allowAlter = ds.alter ?: true,
				allowStoredProcs = ds.storedproc ?: true,

				// Invert logic
				blob = !ds.disable_blob,
				class = ds.class,
				// Invert logic
				clob = !ds.disable_clob,
				// If the field doesn't exist, it's unlimited
				connectionLimit = ds.urlmap.maxConnections ?: -1,
				// Convert from seconds to minutes
				connectionTimeout = round( ds.timeout / 60 ),
				database = ds.urlmap.database,
				// Normalize names
				dbdriver = DSNUtil.translateDatasourceDriverToGeneric( ds.driver ),
				dsn = ds.url,
				host = ds.urlmap.host,
				password = passwordManager.decryptDataSource( ds.password ),
				port = ds.urlmap.port,
				username = ds.username,
				validate = ds.keyExists("validateConnection")?ds.validateConnection:false,
				SID = ds.urlmap.SID ?: '',
				serviceName = ds.urlmap.serviceName ?: '',
				maintainConnections = ds.pooling ?: false,
				sendStringParametersAsUnicode = ds.urlmap.sendStringParametersAsUnicode ?: false,
				maxPooledStatements = ds.urlmap.maxPooledStatements ?: 100,
				connectionTimeoutInterval = ds.interval ?: 420,
				queryTimeout = ds.urlmap.qTimeout ?: 0,
				logActivity = ds.urlmap.useSpyLog ?: false,
				logActivityFile = ds.urlmap.spyLogFile ?: '',
				disableConnections = ds.disable ?: false,
				loginTimeout = ds.login_timeout ?: 30,
				clobBuffer = ds.buffer ?: 64000,
				blobBuffer = ds.blob_buffer ?: 64000,
				disableAutogeneratedKeyRetrieval = ds.disable_autogenkeys ?: false,
				validationQuery = ds.validationQuery ?: '',
				linkedServers = ds.urlmap.supportLinks ?: true,
				clientHostname = ds.clientinfo.ClientHostName ?: false,
				clientUsername = ds.clientinfo.ClientUser ?: false,
				clientApplicationName = ds.clientinfo.ApplicationName ?: false,
				clientApplicationNamePrefix = ds.clientinfo.ApplicationNamePrefix ?: '',
				description = ds.description ?: '',
				// Convert foo=bar;baz=bum to foo=bar&baz=bum if neccessary.  CFConfig always uses &
				custom = listChangeDelims( ds.urlmap.args ?: '', '&', DSNUtil.customURLDelimiter( DSNUtil.translateDatasourceDriverToGeneric( ds.driver ) ) )
			);
		} // end loop over datasource

		if( !isNull( thisConfig[ 2 ].maxcachecount ) ) { setQueryCacheSize( thisConfig[ 2 ].maxcachecount ) }
	}

	function readAuth() {
		if( !fileExists( getCFHomePath().listAppend( getPasswordPropertiesPath(), '/' ) ) ) {
			return;
		}
		var propertyFile = wirebox.getInstance( 'propertyFile@propertyFile' ).load( getCFHomePath().listAppend( getPasswordPropertiesPath(), '/' ) );

		if( !propertyFile.get( 'encrypted', false ) ) {
			setAdminPassword( propertyFile.password );
			setAdminRDSPassword( propertyFile.rdspassword );
		} else {
			setACF11Password( propertyFile.password );
			setACF11RDSPassword( propertyFile.rdspassword );
		}
	}


	function readLicense() {
		if( !fileExists( getCFHomePath().listAppend( getLicensePropertiesPath(), '/' ) ) ) {
			return;
		}
		var propertyFile = wirebox.getInstance( 'propertyFile@propertyFile' ).load( getCFHomePath().listAppend( getLicensePropertiesPath(), '/' ) );

		if( len( propertyFile.get( 'sn', '' ) ) ) { setLicense( propertyFile.get( 'sn', '' ) ); }
		if( len( propertyFile.get( 'previous_sn', '' ) ) ) { setPreviousLicense( propertyFile.get( 'previous_sn', '' ) ); }
	}

	private function readLogging() {
		var thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getLoggingConfigPath(), '/' ) );

		if( !isNull( thisConfig[ 1 ] ) && isArray( thisConfig[ 1 ] ) ) {
			setLogFilesDisabled( thisConfig[ 1 ] );
		}

		if( !isNull( thisConfig[ 2 ].logDirectory ) ) { setLogDirectory( thisConfig[ 2 ].logDirectory ); }
		// Setting is in KB, but storage is in B. Factor of 1000, not 1024.  Thanks, Adobe.
		if( !isNull( thisConfig[ 2 ].maxFileSize ) ) { setLogMaxFileSize( thisConfig[ 2 ].maxFileSize/1000 ); }
		if( !isNull( thisConfig[ 2 ].maxFileBackup ) ) { setLogMaxArchives( thisConfig[ 2 ].maxFileBackup ); }
		if( !isNull( thisConfig[ 2 ].enableOSLogging ) ) { setLogSysLogEnabled( thisConfig[ 2 ].enableOSLogging ); }

	}

	private function readUpdate() {
		var thisConfig = readXMLConfigFile( getCFHomePath().listAppend( getUpdateConfigPath(), '/' ) ).settings;

		if( !isNull( thisConfig.update.url.XMLText ) ) { setUpdateSiteURL( thisConfig.update.url.XMLText ); }

		if( !isNull( thisConfig.update.XMLAttributes.autocheck ) ) { setUpdateCheckOnLoginEnable( thisConfig.update.XMLAttributes.autocheck ); }

		if( !isNull( thisConfig.update.XMLAttributes.checkperiodically ) ) { setUpdateCheckOnScheduleEnable( thisConfig.update.XMLAttributes.checkperiodically ); }
		if( !isNull( thisConfig.update.XMLAttributes.checkinterval ) ) { setUpdateCheckOnScheduleDays( thisConfig.update.XMLAttributes.checkinterval ); }
		if( !isNull( thisConfig.update.notification.emaillist.XMLText ) ) { setUpdateCheckOnScheduleToAddress( thisConfig.update.notification.emaillist.XMLText ); }
		if( !isNull( thisConfig.update.notification.fromemail.XMLText ) ) { setUpdateCheckOnScheduleFromAddress( thisConfig.update.notification.fromemail.XMLText ); }

		if( !isNull( thisConfig.proxy.hostname.XMLText ) ) { setUpdateProxyHost( thisConfig.proxy.hostname.XMLText ); }
		if( !isNull( thisConfig.proxy.port.XMLText ) ) { setUpdateProxyPort( val( thisConfig.proxy.port.XMLText ) ); }
		if( !isNull( thisConfig.proxy.username.XMLText ) ) { setUpdateProxyUsername( thisConfig.proxy.username.XMLText ); }
		if( !isNull( thisConfig.proxy.password.XMLText ) ) { setUpdateProxyPassword( thisConfig.proxy.password.XMLText ); }

	}

	private function readDocument() {
		var thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getDocumentConfigPath(), '/' ) );
		var PDFServices = thisConfig[ 4 ] ?: {};

		for( var PDFServiceName in PDFServices ) {
			var PDFService = PDFServices[ PDFServiceName ];

			addPDFServiceManager(
				name = PDFServiceName,
				hostname = PDFService.hostname ?: '',
				port = PDFService.port ?: 0,
				isHTTPS = PDFService.isHTTPS ?: false,
				weight = PDFService.weight ?: 2,
				isLocal = PDFService.isLocal ?: false,
				isEnabled = PDFService.isEnabled ?: true
			);
		}
	}

	private function readGraph() {
		var thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getGraphConfigPath(), '/' ) );

		if( !isNull( thisConfig[1].CacheType ) ) { setChartCacheType( thisConfig[1].CacheType ); }
		if( !isNull( thisConfig[1].TimeToLive ) ) { setChartCacheTTL( thisConfig[1].TimeToLive ); }
		if( !isNull( thisConfig[1].CacheSize ) ) { setChartCacheSize( thisConfig[1].CacheSize ); }
		if( !isNull( thisConfig[1].CACHEPATH ) ) { setChartCacheDiskLocation( thisConfig[1].CACHEPATH ); }

	}

	/**
	* I write out config from a base JSON format
	*
	* @CFHomePath The coldfusion home path to write xml files
	*/
	function write( string CFHomePath, pauseTasks=false ){
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

		ensureSeedProperties( getCFHomePath().listAppend( getSeedPropertiesPath(), '/' ) );

		writeRuntime();
		writeClientStore();
		writeWatch();
		writeMail();
		writeDatasource();
		writeAuth();
		writeLicense();
		writeLogging();
		writeSecurity();
		writeDebug();
		writeScheduler( pauseTasks );
		writeEventGateway();
		writeWebsocket();
		writeJetty();
		writeDotNet();
		writeUpdate();
		writeDocument();
		writeGraph();

		if( getSupportsMultiCloud() ) {
			writeCloudCred();
			writeSAML();
			writeCloudConfig();
		}

		return this;
	}

	private function writeCloudCred() {
		// Short circuit if there's no config to import
		if( isNull( getCloudCredentials() ) ) {
			return;
		}

		var passwordManager = getAdobePasswordManager();
		var configFilePath = getCFHomePath().listAppend( getCloudCredPath(), '/' );

		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getCloudCredTemplate() );
		}

		var cloudCredentials = getCloudCredentials();
		thisConfig = {};
		for ( var cloudCredentialName in cloudCredentials ) {
			var cloudCredential = cloudCredentials[ cloudCredentialName ];
			var currentcloudCredential = {
				'alias' : cloudCredentialName
			};
			if( !isNull( cloudCredential.vendor ) ) { currentcloudCredential[ 'vendorName' ] = cloudCredential.vendor }
			if( !isNull( cloudCredential.connectionString ) ) { currentcloudCredential[ 'connectionString' ] = passwordManager.encryptMailServer( cloudCredential.connectionString ) }
			if( !isNull( cloudCredential.secretKey ) ) { currentcloudCredential[ 'secretAccessKey' ] = passwordManager.encryptMailServer( cloudCredential.secretKey ) }
			if( !isNull( cloudCredential.accessKey ) ) { currentcloudCredential[ 'accessKeyId' ] = passwordManager.encryptMailServer( cloudCredential.accessKey ) }
			if( !isNull( cloudCredential.region ) ) { currentcloudCredential[ 'region' ] = cloudCredential.region }
			thisConfig[ cloudCredentialName ] = currentcloudCredential;
		}

		writeWDDXConfigFile( thisConfig, configFilePath );

	}

	private function writeCloudConfig() {

		// Short circuit if there's no config to import
		if( isNull( getCloudServices() ) ) {
			return;
		}

		var configFilePath = getCFHomePath().listAppend( getCloudConfigPath(), '/' );

		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getCloudConfigTemplate() );
		}

		var cloudServices = getCloudServices();
		for( var cloudServiceName in cloudServices ) {
			thisConfig[ cloudServiceName ] = cloudServices[ cloudServiceName ];
		}

		writeWDDXConfigFile( thisConfig, configFilePath );

	}


	private function writeSAML() {
		var configFilePath = getCFHomePath().listAppend( getSAMLPath(), '/' );

		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getSAMLTemplate() );
		}

		if( !isNull( getSAMLIdentityProviders() ) ) {
			var SAMLIdentityProviders = getSAMLIdentityProviders();
			thisConfig[ 'IdentityProvidersMap' ] = {};
			for ( var SAMLIdentityProviderName in SAMLIdentityProviders ) {
				var SAMLIdentityProvider = SAMLIdentityProviders[ SAMLIdentityProviderName ];
				var currentSAMLIdentityProvider = {};

				if( !isNull( SAMLIdentityProvider.description ) ) { currentSAMLIdentityProvider[ 'description' ] = SAMLIdentityProvider.description }
				if( !isNull( SAMLIdentityProvider.encryptCertificate ) ) { currentSAMLIdentityProvider[ 'encryptCertificate' ] = SAMLIdentityProvider.encryptCertificate }
				if( !isNull( SAMLIdentityProvider.encryptRequests ) ) { currentSAMLIdentityProvider[ 'encryptRequests' ] = !!SAMLIdentityProvider.encryptRequests }
				if( !isNull( SAMLIdentityProvider.entityId ) ) { currentSAMLIdentityProvider[ 'entityId' ] = SAMLIdentityProvider.entityId }
				if( !isNull( SAMLIdentityProvider.logoutResponseUrl ) ) { currentSAMLIdentityProvider[ 'logoutResponseUrl' ] = SAMLIdentityProvider.logoutResponseUrl }
				if( !isNull( SAMLIdentityProvider.signCertificate ) ) { currentSAMLIdentityProvider[ 'signCertificate' ] = SAMLIdentityProvider.signCertificate }
				if( !isNull( SAMLIdentityProvider.signRequests ) ) { currentSAMLIdentityProvider[ 'signRequests' ] = !!SAMLIdentityProvider.signRequests }
				if( !isNull( SAMLIdentityProvider.SLOBinding ) ) { currentSAMLIdentityProvider[ 'sloBinding' ] = SAMLIdentityProvider.SLOBinding }
				if( !isNull( SAMLIdentityProvider.SLOURL ) ) { currentSAMLIdentityProvider[ 'sloUrl' ] = SAMLIdentityProvider.SLOURL }
				if( !isNull( SAMLIdentityProvider.SSOBinding ) ) { currentSAMLIdentityProvider[ 'ssoBinding' ] = SAMLIdentityProvider.SSOBinding }
				if( !isNull( SAMLIdentityProvider.SSOURL ) ) { currentSAMLIdentityProvider[ 'ssoUrl' ] = SAMLIdentityProvider.SSOURL }
				if( !isNull( SAMLIdentityProvider.metadataURL ) ) { currentSAMLIdentityProvider[ 'metadataUrl' ] = SAMLIdentityProvider.metadataURL }

				thisConfig.IdentityProvidersMap[ SAMLIdentityProviderName ] = currentSAMLIdentityProvider;
			}
		}

		if( !isNull( getSAMLServiceProviders() ) ) {
			var SAMLServiceProviders = getSAMLServiceProviders();
			thisConfig[ 'ServiceProvidersMap' ] = {};
			for ( var SAMLServiceProviderName in SAMLServiceProviders ) {
				var SAMLServiceProvider = SAMLServiceProviders[ SAMLServiceProviderName ];
				var currentSAMLServiceProvider = {};

				if( !isNull( SAMLServiceProvider.ACSBinding ) ) { currentSAMLServiceProvider[ 'acsBinding' ] = SAMLServiceProvider.ACSBinding }
				if( !isNull( SAMLServiceProvider.ACSURL ) ) { currentSAMLServiceProvider[ 'acsUrl' ] = SAMLServiceProvider.ACSURL }
				if( !isNull( SAMLServiceProvider.allowIdpInitiatedSso ) ) { currentSAMLServiceProvider[ 'allowIdpInitiatedSso' ] = !!SAMLServiceProvider.allowIdpInitiatedSso }
				if( !isNull( SAMLServiceProvider.description ) ) { currentSAMLServiceProvider[ 'description' ] = SAMLServiceProvider.description }
				if( !isNull( SAMLServiceProvider.entityId ) ) { currentSAMLServiceProvider[ 'entityId' ] = SAMLServiceProvider.entityId }
				if( !isNull( SAMLServiceProvider.logoutResponseSigned ) ) { currentSAMLServiceProvider[ 'logoutResponseSigned' ] = !!SAMLServiceProvider.logoutResponseSigned }
				if( !isNull( SAMLServiceProvider.signKeystoreAlias ) ) { currentSAMLServiceProvider[ 'signKeystoreAlias' ] = SAMLServiceProvider.signKeystoreAlias }
				if( !isNull( SAMLServiceProvider.signKeystorePassword ) ) { currentSAMLServiceProvider[ 'signKeystorePassword' ] = SAMLServiceProvider.signKeystorePassword }
				if( !isNull( SAMLServiceProvider.signKeystorePath ) ) { currentSAMLServiceProvider[ 'signKeystorePath' ] = SAMLServiceProvider.signKeystorePath }
				if( !isNull( SAMLServiceProvider.signMetadata ) ) { currentSAMLServiceProvider[ 'signMetadata' ] = !!SAMLServiceProvider.signMetadata }
				if( !isNull( SAMLServiceProvider.signRequests ) ) { currentSAMLServiceProvider[ 'signRequests' ] = !!SAMLServiceProvider.signRequests }
				if( !isNull( SAMLServiceProvider.SLOBinding ) ) { currentSAMLServiceProvider[ 'sloBinding' ] = SAMLServiceProvider.SLOBinding }
				if( !isNull( SAMLServiceProvider.SLOURL ) ) { currentSAMLServiceProvider[ 'sloUrl' ] = SAMLServiceProvider.SLOURL }
				if( !isNull( SAMLServiceProvider.stateStore ) ) { currentSAMLServiceProvider[ 'stateStore' ] = SAMLServiceProvider.stateStore }
				if( !isNull( SAMLServiceProvider.strict ) ) { currentSAMLServiceProvider[ 'strict' ] = !!SAMLServiceProvider.strict }
				if( !isNull( SAMLServiceProvider.wantAssertionsSigned ) ) { currentSAMLServiceProvider[ 'wantAssertionsSigned' ] = !!SAMLServiceProvider.wantAssertionsSigned }

				thisConfig.ServiceProvidersMap[ SAMLServiceProviderName ] = currentSAMLServiceProvider;
			}
		}

		writeWDDXConfigFile( thisConfig, configFilePath );
	}


	private function writeRuntime() {
		var passwordManager = getAdobePasswordManager();
		var configFilePath = getCFHomePath().listAppend( getRuntimeConfigPath(), '/' );

		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getRuntimeConfigTemplate() );
		}

		// Only save custom tag paths if defined.
		// i.e., an empty array means delete everything, not having a value at all means don't touch it.
		if( !isNull( getCustomTagPaths() ) ) {
			// Special Adobe Custom Tag path we don't want to remove
			var ignoredCustomTagPaths = [ '##server.coldfusion.rootdir##/CustomTags', '#getCFHomePath()#/CustomTags' ];
			for( var thisMapping in thisConfig[ 4 ] ) {
				if( !ignoredCustomTagPaths.findNoCase( normalizeSlashes( thisConfig[ 4 ][ thisMapping ] ) ) ) {
					structDelete( thisConfig[ 4 ], thisMapping );
				}
			}
			var ctr = 100000;
			for( var customTagPath in getCustomTagPaths() ?: [] ) {
				// All Adobe handles is physical paths.  Anything that doesn't have a physical path
				// probably came from Lucee, or from someone adding it manually, regardless, we can
				// only write what is supported.  We manufacture new keys for WDDX.
				if ( !isNull( customTagPath[ 'physical' ] ) && len( customTagPath[ 'physical' ] ) ) {
					thisConfig[ 4 ][ "/WEB-INF/customtags" & ctr ] = customTagPath[ 'physical' ];
					ctr = ctr + 10;
				}
			}
		}

		if( !isNull( getWhitespaceManagement() ) ) { thisConfig[ 1 ] = ( translateWhitespaceToAdobe( getWhitespaceManagement() ) ? true : false ); }
		if( !isNull( getLogCORBACalls() ) ) { thisConfig[ 5 ].logging = ( getLogCORBACalls() ? true : false ); }
		if( !isNull( getSessionManagement() ) ) { thisConfig[ 7 ].session.enable = ( getSessionManagement() ? true : false ); }
		if( !isNull( getSessionTimeout() ) ) { thisConfig[ 7 ].session.timeout = getSessionTimeout(); }
		if( !isNull( getSessionMaximumTimeout() ) ) { thisConfig[ 7 ].session.maximum_timeout = getSessionMaximumTimeout(); }
		if( !isNull( getSessionType() ) ) { thisConfig[ 7 ].session.usej2eesession = ( getSessionType() == 'j2ee' ); }

		if( !isNull( getApplicationManagement() ) ) { thisConfig[ 7 ].application.enable = ( getApplicationManagement() ? true : false ); }
		if( !isNull( getApplicationTimeout() ) ) { thisConfig[ 7 ].application.timeout = getApplicationTimeout(); }
		if( !isNull( getApplicationMaximumTimeout() ) ) { thisConfig[ 7 ].application.maximum_timeout = getApplicationMaximumTimeout(); }

		// Convert from boolean back to 1/0
		if( !isNull( getErrorStatusCode() ) ) { thisConfig[ 8 ].EnableHTTPStatus = ( getErrorStatusCode() ? 1 : 0 ); }
		if( !isNull( getMissingErrorTemplate() ) ) { thisConfig[ 8 ].missing_template = translateSharedErrorTemplateToAdobe( getMissingErrorTemplate(), 'missing' ); }
		if( !isNull( getGeneralErrorTemplate() ) ) { thisConfig[ 8 ].site_wide = translateSharedErrorTemplateToAdobe( getGeneralErrorTemplate(), 'error' ); }
		if( !isNull( getRequestQueueTimeoutPage() ) ) { thisConfig[ 8 ][ 'queue_timeout' ] = getRequestQueueTimeoutPage(); }

		// Only save CF Mapingsif defined.
		if( !isNull( getCFmappings() ) ) {
			var ignoredMappings = [ '/CFIDE', '/gateway' ];
			for( var thisMapping in thisConfig[ 9 ] ) {
				if( !ignoredMappings.findNoCase( thisMapping ) ) {
					structDelete( thisConfig[ 9 ], thisMapping );
				}
			}

			for( var virtual in getCFmappings() ?: {} ) {
				if( !isNull( getCFmappings()[ virtual ][ 'physical' ] ) && len( getCFmappings()[ virtual ][ 'physical' ] ) ) {
					var physical = getCFmappings()[ virtual ][ 'physical' ];
					thisConfig[ 9 ][ virtual ] = physical;
				}
			}
		}

		if( !isNull( getRequestTimeoutEnabled() ) ) { thisConfig[ 10 ].timeoutRequests = ( getRequestTimeoutEnabled() ? true : false ); }
		if( !isNull( getRequestTimeout() ) ) {
			// Convert from timepsan to seconds
			var rt = getRequestTimeout();
			var ts = createTimespan( rt.listGetAt( 1 ), rt.listGetAt( 2 ), rt.listGetAt( 3 ), rt.listGetAt( 4 ) );
			// timespan of "1" is one day.  Multiple to get seconds
			thisConfig[ 10 ].timeoutRequestTimeLimit = round( ts*24*60*60 );
		}
		if( !isNull( getPostParametersLimit() ) ) { thisConfig[ 10 ].postParametersLimit = getPostParametersLimit()+0; }
		if( !isNull( getPostSizeLimit() ) ) { thisConfig[ 10 ].postSizeLimit = getPostSizeLimit()+0; }

		// Request Tuning
		if( !isNull( getMaxTemplateRequests() ) ) { thisConfig[ 10 ][ 'requestLimit' ] = getMaxTemplateRequests()+0; }
		if( !isNull( getmaxFlashRemotingRequests() ) ) { thisConfig[ 10 ][ 'flashRemotingLimit' ] = getmaxFlashRemotingRequests()+0; }
		if( !isNull( getMaxWebServiceRequests() ) ) { thisConfig[ 10 ][ 'webserviceLimit' ] = getMaxWebServiceRequests()+0; }
		if( !isNull( getMaxCFCFunctionRequests() ) ) { thisConfig[ 10 ][ 'CFCLimit' ] = getMaxCFCFunctionRequests()+0; }
		if( !isNull( getMaxReportRequests() ) ) { thisConfig[ 17 ][ 'numSimultaneousReports' ] = getMaxReportRequests()+0; }
		if( !isNull( getMaxCFThreads() ) ) { thisConfig[ 16 ][ 'cfthreadpool' ] = getMaxCFThreads()+0; }
		if( !isNull( getRequestQueueTimeout() ) ) { thisConfig[ 10 ][ 'queueTimeout' ] = getRequestQueueTimeout()+0; }
		if( !isNull( getLogSlowRequestsEnabled() ) ) { thisConfig[ 10 ][ 'logSlowRequests' ] = !!getLogSlowRequestsEnabled(); }
		if( !isNull( getLogSlowRequestsThreshold() ) ) { thisConfig[ 10 ][ 'slowRequestTimeLimit' ] = getLogSlowRequestsThreshold()+0; }


		if( !isNull( getTemplateCacheSize() ) ) { thisConfig[ 11 ].templateCacheSize = getTemplateCacheSize()+0; }
		if( !isNull( getSaveClassFiles() ) ) { thisConfig[ 11 ].saveClassFiles = ( getSaveClassFiles() ? true : false ); }
		if( !isNull( getComponentCacheEnabled() ) ) { thisConfig[ 11 ].componentCacheEnabled = ( getComponentCacheEnabled() ? true : false ); }
		if( !isNull( getQueryInternalCacheEnabled() ) ) { thisConfig[ 11 ].enableInternalQueryCache = ( getQueryInternalCacheEnabled() ? true : false ); }

		if( !isNull( getInspectTemplate() ) ) {

			switch( getInspectTemplate() ) {
				case 'never' :
					thisConfig[ 11 ].trustedCacheEnabled = true;
					thisConfig[ 11 ].inRequestTemplateCacheEnabled = true;
					break;
				case 'once' :
					thisConfig[ 11 ].trustedCacheEnabled = false;
					thisConfig[ 11 ].inRequestTemplateCacheEnabled = true;
					break;
				case 'always' :
					thisConfig[ 11 ].trustedCacheEnabled = false;
					thisConfig[ 11 ].inRequestTemplateCacheEnabled = false;
			}

		}

		if( !isNull( getMailDefaultEncoding() ) ) { thisConfig[ 12 ].defaultMailCharset = getMailDefaultEncoding(); }

		if( !isNull( getCFFormScriptDirectory() ) ) { thisConfig[ 14 ].CFFormScriptSrc = getCFFormScriptDirectory(); }

		if( !isNull( getScriptProtect() ) ) {

			// Adobe doesn't do "all" or "none" like Lucee, just the list.  Empty string if nothing.
			switch( getScriptProtect() ) {
				case 'all' :
					thisConfig[ 15 ] = 'FORM,URL,COOKIE,CGI';
					break;
				case 'none' :
					thisConfig[ 15 ] = '';
					break;
				default :
					thisConfig[ 15 ] = getScriptProtect();
			}

		}


		if( !isNull( getPerAppSettingsEnabled() ) ) { thisConfig[ 16 ].isPerAppSettingsEnabled = ( getPerAppSettingsEnabled() ? true : false ); }
		// Adobe stores the inverse of Lucee
		if( !isNull( getUDFTypeChecking() ) ) { thisConfig[ 16 ].cfcTypeCheckEnabled = ( getUDFTypeChecking() ? false : true ); }
		if( !isNull( getDisableInternalCFJavaComponents() ) ) { thisConfig[ 16 ].disableServiceFactory = ( getDisableInternalCFJavaComponents() ? true : false ); }
		// Lucee and Adobe store opposite value
		if( !isNull( getDotNotationUpperCase() ) ) { thisConfig[ 16 ].preserveCaseForSerialize = !getDotNotationUpperCase(); }
		if( !isNull( getSecureJSON() ) ) { thisConfig[ 16 ].secureJSON = ( getSecureJSON() ? true : false ); }
		if( !isNull( getSecureJSONPrefix() ) ) { thisConfig[ 16 ].secureJSONPrefix = getSecureJSONPrefix(); }
		if( !isNull( getMaxOutputBufferSize() ) ) { thisConfig[ 16 ].maxOutputBufferSize = getMaxOutputBufferSize()+0; }
		if( !isNull( getInMemoryFileSystemEnabled() ) ) { thisConfig[ 16 ].enableInMemoryFileSystem = ( getInMemoryFileSystemEnabled() ? true : false ); }
		if( !isNull( getInMemoryFileSystemLimit() ) ) { thisConfig[ 16 ].inMemoryFileSystemLimit = getInMemoryFileSystemLimit()+0; }
		if( !isNull( getInMemoryFileSystemAppLimit() ) ) { thisConfig[ 16 ].inMemoryFileSystemAppLimit = getInMemoryFileSystemAppLimit()+0; }
		if( !isNull( getAllowExtraAttributesInAttrColl() ) ) { thisConfig[ 16 ].allowExtraAttributesInAttrColl = ( getAllowExtraAttributesInAttrColl() ? true : false ); }
		if( !isNull( getDisallowUnamedAppScope() ) ) { thisConfig[ 16 ].dumpunnamedappscope = ( getDisallowUnamedAppScope() ? true : false ); }
		if( !isNull( getAllowApplicationVarsInServletContext() ) ) { thisConfig[ 16 ].allowappvarincontext = ( getAllowApplicationVarsInServletContext() ? true : false ); }
		if( !isNull( getCFaaSGeneratedFilesExpiryTime() ) ) { thisConfig[ 16 ].CFaaSGeneratedFilesExpiryTime = getCFaaSGeneratedFilesExpiryTime()+0; }
		if( !isNull( getORMSearchIndexDirectory() ) ) { thisConfig[ 16 ].ORMSearchIndexDirectory = getORMSearchIndexDirectory(); }
		if( !isNull( getGoogleMapKey() ) ) { thisConfig[ 16 ].googleMapKey = getGoogleMapKey(); }
		if( !isNull( getServerCFCEenabled() ) ) { thisConfig[ 16 ].enableServerCFC = ( getServerCFCEenabled() ? true : false ); }
		if( !isNull( getServerCFC() ) ) { thisConfig[ 16 ].serverCFC = getServerCFC(); }
		if( !isNull( getCompileExtForCFInclude() ) ) { thisConfig[ 16 ].compileextforinclude = getCompileExtForCFInclude(); }
		if( !isNull( getSessionCookieTimeout() ) ) { thisConfig[ 16 ].sessionCookieTimeout = getSessionCookieTimeout()+0; }
		if( !isNull( getSessionCookieHTTPOnly() ) ) { thisConfig[ 16 ].httpOnlySessionCookie = ( getSessionCookieHTTPOnly() ? true : false ); }
		if( !isNull( getSessionCookieSecure() ) ) { thisConfig[ 16 ].secureSessionCookie = ( getSessionCookieSecure() ? true : false ); }
		if( !isNull( getSessionCookieDisableUpdate() ) ) { thisConfig[ 16 ].internalCookiesDisableUpdate = ( getSessionCookieDisableUpdate() ? true : false ); }
		if( !isNull( getSessionCookieSamesite() ) ) { thisConfig[ 16 ].sessionCookieSamesite = ( getSessionCookieSamesite() ); }
		if( !isNull( getBlockedExtForFileUpload() ) ) { thisConfig[ 16 ].blockedExtForFileUpload = getBlockedExtForFileUpload(); }
		if( !isNull( getNullSupport() ) ) { thisConfig[ 16 ].enableNullSupport = !!getNullSupport(); }
		if( !isNull( getFlashRemotingEnable() ) ) { thisConfig[ 16 ].enableFlashRemoting = !!getFlashRemotingEnable(); }
		if( !isNull( getFlexDataServicesEnable() ) ) { thisConfig[ 16 ].enableFlexDataServices = !!getFlexDataServicesEnable(); }
		if( !isNull( getRMISSLEnable() ) ) { thisConfig[ 16 ].enableRmiSSL = !!getRMISSLEnable(); }
		if( !isNull( getRMISSLKeystore() ) ) { thisConfig[ 16 ].RmiSSLKeystore = getRMISSLKeystore(); }
		if( !isNull( getRMISSLKeystorePassword() ) ) { thisConfig[ 16 ].RmiSSLKeystorePassword = passwordManager.encryptMailServer( getRMISSLKeystorePassword() ); }

		if( !isNull( getApplicationMode() ) ) {

			// See comments in BaseConfig class for descriptions
			// This needs to be a string in the WDDX!
			switch( getApplicationMode() ) {
				case 'curr2driveroot' :
				// Next best match for "current only"
				case 'curr' :
					thisConfig[ 16 ].applicationCFCSearchLimit = '1';
					break;
				case 'curr2root' :
					thisConfig[ 16 ].applicationCFCSearchLimit = '2';
					break;
				case 'currorroot' :
				// Next best match for "root only"
				case 'root' :
					thisConfig[ 16 ].applicationCFCSearchLimit = '3';
			}

		}

		if( !isNull( getSessionStorageLocation() ) ) { thisConfig[ 16 ][ 'sessionStorage' ] = getSessionStorageLocation(); }
		if( !isNull( getSessionStoragePassword() ) ) { thisConfig[ 16 ][ 'sessionStoragePassword' ] = passwordManager.encryptMailServer( getSessionStoragePassword() ); }
		if( !isNull( getSessionStorageHost() ) ) { thisConfig[ 16 ][ 'sessionStorageHost' ] = getSessionStorageHost(); }
		if( !isNull( getSessionStorageTimeout() ) ) { thisConfig[ 16 ][ 'sessionStorageTimeout' ] = getSessionStorageTimeout()+0; }
		if( !isNull( getSessionStoragePort() ) ) { thisConfig[ 16 ][ 'sessionStoragePort' ] = getSessionStoragePort()+0; }

		if( !isNull( getSessionCookieDisableUpdate() ) ) { thisConfig[ 18 ][ 'throttle-threshold' ] = getThrottleThreshold()+0; }
		if( !isNull( getTotalThrottleMemory() ) ) { thisConfig[ 18 ][ 'total-throttle-memory' ] = getTotalThrottleMemory()+0; }



		writeWDDXConfigFile( thisConfig, configFilePath );

	}

	private function writeDebug() {
		var configFilePath = getCFHomePath().listAppend( getDebugConfigPath(), '/' );

		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getDebugConfigTemplate() );
		}

		if( !isNull( getRobustExceptionEnabled() ) ) { thisConfig[ 1 ][ 'robust_enabled' ] = !!getRobustExceptionEnabled(); }
		if( !isNull( getAjaxDebugWindowEnabled() ) ) { thisConfig[ 1 ][ 'ajax_enabled' ] = !!getAjaxDebugWindowEnabled(); }
		if( !isNull( getDebuggingEnabled() ) ) { thisConfig[ 1 ][ 'enabled' ] = !!getDebuggingEnabled(); }
		if( !isNull( getDebuggingReportExecutionTimes() ) ) { thisConfig[ 1 ][ 'template' ] = !!getDebuggingReportExecutionTimes(); }


		if( !isNull( getDebuggingReportExecutionTimesMinimum() ) ) { thisConfig[ 1 ][ 'template_highlight_minimum' ] = getDebuggingReportExecutionTimesMinimum()+0; }
		if( !isNull( getDebuggingReportExecutionTimesTemplate() ) ) { thisConfig[ 1 ][ 'template_mode' ] = getDebuggingReportExecutionTimesTemplate()&''; }
		if( !isNull( getDebuggingTemplate() ) ) { thisConfig[ 1 ][ 'debug_template' ] = getDebuggingTemplate()&''; }
		if( !isNull( getDebuggingShowGeneral() ) ) { thisConfig[ 1 ][ 'general' ] = !!getDebuggingShowGeneral(); }
		if( !isNull( getDebuggingShowDatabase() ) ) { thisConfig[ 1 ][ 'database' ] = !!getDebuggingShowDatabase(); }
		if( !isNull( getDebuggingShowException() ) ) { thisConfig[ 1 ][ 'exception' ] = !!getDebuggingShowException(); }
		if( !isNull( getDebuggingShowTrace() ) ) { thisConfig[ 1 ][ 'trace' ] = !!getDebuggingShowTrace(); }
		if( !isNull( getDebuggingShowTimer() ) ) { thisConfig[ 1 ][ 'TIMER' ] = !!getDebuggingShowTimer(); }
		if( !isNull( getDebuggingShowFlashFormCompileErrors() ) ) { thisConfig[ 1 ][ 'FLASHFORMCOMPILEERRORS' ] = !!getDebuggingShowFlashFormCompileErrors(); }
		if( !isNull( getDebuggingShowVariables() ) ) { thisConfig[ 1 ][ 'variables' ] = !!getDebuggingShowVariables(); }
		if( !isNull( getDebuggingShowVariableApplication() ) ) { thisConfig[ 1 ][ 'applicationvar' ] = !!getDebuggingShowVariableApplication(); }
		if( !isNull( getDebuggingShowVariableCGI() ) ) { thisConfig[ 1 ][ 'cgivar' ] = !!getDebuggingShowVariableCGI(); }
		if( !isNull( getDebuggingShowVariableClient() ) ) { thisConfig[ 1 ][ 'clientvar' ] = !!getDebuggingShowVariableClient(); }
		if( !isNull( getDebuggingShowVariableCookie() ) ) { thisConfig[ 1 ][ 'cookievar' ] = !!getDebuggingShowVariableCookie(); }
		if( !isNull( getDebuggingShowVariableForm() ) ) { thisConfig[ 1 ][ 'formvar' ] = !!getDebuggingShowVariableForm(); }
		if( !isNull( getDebuggingShowVariableRequest() ) ) { thisConfig[ 1 ][ 'requestvar' ] = !!getDebuggingShowVariableRequest(); }
		if( !isNull( getDebuggingShowVariableServer() ) ) { thisConfig[ 1 ][ 'servervar' ] = !!getDebuggingShowVariableServer(); }
		if( !isNull( getDebuggingShowVariableSession() ) ) { thisConfig[ 1 ][ 'sessionvar' ] = !!getDebuggingShowVariableSession(); }
		if( !isNull( getDebuggingShowVariableURL() ) ) { thisConfig[ 1 ][ 'urlvar' ] = !!getDebuggingShowVariableURL(); }

		if( !isNull( getDebuggingIPList() ) ) { thisConfig[ 2 ][ 'iplist' ] = getDebuggingIPList()&''; }


		if( !isNull( getLineDebuggerEnabled() ) ) { thisConfig[ 3 ][ 'LINE_DEBUGGER_ENABLED' ] = !!getLineDebuggerEnabled(); }
		if( !isNull( getLineDebuggerPort() ) ) { thisConfig[ 3 ][ 'LINE_DEBUGGER_PORT' ] = getLineDebuggerPort()+0; }
		if( !isNull( getLineDebuggerMaxSessions() ) ) { thisConfig[ 3 ][ 'MAX_DEBUG_SESSIONS' ] = getLineDebuggerMaxSessions()+0; }

		if( !isNull( getWeinreRemoteInspectionEnabled() ) ) {
			// CF will freak out if the 3rd index exists, but is null.
			thisConfig[ 3 ] = thisConfig[ 3 ] ?: {};
			thisConfig[ 4 ][ 'REMOTE_INSPECTION_ENABLED' ] = !!getWeinreRemoteInspectionEnabled();
		}
		writeWDDXConfigFile( thisConfig, configFilePath );
	}

	private function writeScheduler( boolean pauseTasks=false ) {

		if( isNull( getScheduledTasks() ) ) {
			return;
		}

		var passwordManager = getAdobePasswordManager();
		var configFilePath = getCFHomePath().listAppend( getSchedulerConfigPath(), '/' );

		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getSchedulerConfigTemplate() );
		}

		thisConfig[ 1 ] = {};

		for( var taskName in getScheduledTasks() ?: {} ) {
			var thisTask = getScheduledTasks()[ taskName ];
			var thisName = thisTask.task;

			var thisGroup = 'default';
			if( !isNull( thisTask.group ) && len( thisTask.group ) ) {
				var thisGroup = thisTask.group;
			}

			// This will ensure every task has all the default data
			var taskData = getDefaultScheduledTaskData();
			taskData[ 'task' ] = thisName;
			taskData[ 'chained' ] = ( thisTask.chained ?: taskData.chained ) & '';
			taskData[ 'clustered' ] = ( thisTask.clustered ?: taskData.clustered ) & '';
			taskData[ 'crontime' ] = ( thisTask.crontime ?: taskData.crontime ) & '';
			taskData[ 'eventhandler' ] = ( thisTask.eventhandler ?: taskData.eventhandler ) & '';
			taskData[ 'eventhandlerrp' ] = ( thisTask.eventhandler ?: taskData.eventhandler ) & '';
			taskData[ 'exclude' ] = ( thisTask.exclude ?: taskData.exclude ) & '';
			taskData[ 'path' ] = ( getDirectoryFromPath( thisTask.file ?: taskData.file ) ) & '';
			taskData[ 'file' ] = ( getFileFromPath( thisTask.file ?: taskData.file ) ) & '';
			taskData[ 'group' ] = thisGroup;
			taskData[ 'http_port' ] = ( thisTask.httpPort ?: taskData.http_port ) & '';
			taskData[ 'http_proxy_port' ] = ( thisTask.httpProxyPort ?: taskData.http_proxy_port ) & '';
			taskData[ 'interval' ] = ( thisTask.interval ?: taskData.interval ) & '';
			taskData[ 'oncomplete' ] = ( thisTask.oncomplete ?: taskData.oncomplete ) & '';
			taskData[ 'overwrite' ] = ( thisTask.overwrite ?: taskData.overwrite ) & '';
			taskData[ 'priority' ] = ( thisTask.priority ?: taskData.priority ) & '';
			taskData[ 'proxy_server' ] = ( thisTask.proxyServer ?: taskData.proxy_server ) & '';
			taskData[ 'proxy_user' ] = ( thisTask.proxyUser ?: taskData.proxy_user ) & '';
			taskData[ 'publish' ] = !!( thisTask.saveOutputToFile ?: taskData.publish );
			taskData[ 'repeat' ] = ( thisTask.repeat ?: taskData.repeat ) & '';
			taskData[ 'request_time_out' ] = ( thisTask.requestTimeOut ?: taskData.request_time_out ) & '';
			taskData[ 'resolveURL' ] = !!( thisTask.resolveURL ?: taskData.resolveURL );
			taskData[ 'retryCount' ] = ( thisTask.retryCount ?: taskData.retryCount ) & '';
			taskData[ 'start_date' ] = ( thisTask.startDate ?: taskData.start_date ) & '';
			taskData[ 'start_time' ] = ( thisTask.startTime ?: taskData.start_time ) & '';
			taskData[ 'URL' ] = ( thisTask.URL ?: taskData.URL ) & '';
			taskData[ 'username' ] = ( thisTask.username ?: taskData.username ) & '';

			// User can specify all tasks to be inserted in a paused state
			if( pauseTasks ) {
				taskData[ 'status' ] = 'Paused';
			} else {
				taskData[ 'status' ] = thisTask.status ?: taskData.status;
			}

			if( !isNull( thisTask.proxyPassword ) && thisTask.proxyPassword.len() ) {
				taskData.proxy_password = passwordManager.encryptMailServer( thisTask.proxyPassword );
			}
			if( !isNull( thisTask.password ) && thisTask.password.len() ) {
				taskData.password = passwordManager.encryptMailServer( thisTask.password );
			}

			// Don't save it unless we have a time.
			if( !isNull( thisTask.endTime ) && thisTask.endTime.len() ) {
				taskData[ 'end_time' ] = thisTask.endTime;
			}

			// Don't save it unless we have a date.
			if( !isNull( thisTask.endDate ) && thisTask.endDate.len() ) {
				taskData[ 'end_date' ] = thisTask.endDate;
			}

			if( !isNull( thisTask.onexception ) ) {
				// Adobe stores empty string for "ignore"
				if( thisTask.onexception == 'Ignore' ) {
					thisTask.onexception = '';
				}
				taskData[ 'onexception' ] = thisTask.onexception;
			}

			if( !isNull( thisTask.misfire ) ) {
				// Adobe stores empty string for "ignore"
				if( thisTask.misfire == 'Ignore' ) {
					thisTask.misfire = '';
				}
				taskData[ 'misfire' ] = thisTask.misfire;
			}

			// Adobe uses this weird syntax as the key for each task
			thisConfig[ 1 ][ 'SERVERSCHEDULETASK##$%^#thisGroup.ucase()###$%^#thisName.ucase()#' ] = taskData;
		}

		if( !isNull( getSchedulerLoggingEnabled() ) ) { thisConfig[ 2 ] = !!getSchedulerLoggingEnabled(); }
		if( !isNull( getSchedulerClusterDatasource() ) ) { thisConfig[ 3 ] = getSchedulerClusterDatasource(); }
		if( !isNull( getSchedulerLogFileExtensions() ) && getSchedulerLogFileExtensions().len() ) { thisConfig[ 4 ] = getSchedulerLogFileExtensions(); }



		writeWDDXConfigFile( thisConfig, configFilePath );
	}

	private function writeEventGateway() {
		var configFilePath = getCFHomePath().listAppend( getEventGatewayConfigPath(), '/' );

		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getEventGatewayConfigTemplate() );
		}

		if( !isNull( getEventGatewayEnabled() ) ) { thisConfig[ 'GLOBAL' ][ 'ENABLEEVENTGATEWAYSERVICE' ] = !!getEventGatewayEnabled(); }
		if( !isNull( getEventGatewayInstances() ) ) {
			var eventGatewayInstances = getEventGatewayInstances();
			thisConfig[ 'INSTANCES' ] = [];
			for ( var eventGateway in getEventGatewayInstances() ) {
				var currentEventGateWay = {
					"CFCPATHS" = eventGateway.cfcpaths,
					"CONFIGURATIONPATH" = eventGateway.configurationpath,
					"GATEWAYID" = eventGateway.gatewayid,
					"MODE" = eventGateway.mode,
					"TYPE" = eventGateway.type
				};
				thisConfig[ 'INSTANCES' ].append( currentEventGateWay );
			}
		}
		if( !isNull( getEventGatewayConfigurations() ) ) {
			var eventGatewayConfigurations = getEventGatewayConfigurations();
			thisConfig[ 'GATEWAYS' ] = [];
			for (var eventGatewayConfiguration in eventGatewayConfigurations) {
				var currentEventGatewayConfiguration = {
					"DESCRIPTION" = eventGatewayConfiguration.description,
					"KILLONTIMEOUT" = !!eventGatewayConfiguration.killontimeout,
					"CLASS" = eventGatewayConfiguration.class,
					"STARTTIMEOUT" = eventGatewayConfiguration.starttimeout+0,
					"TYPE" = eventGatewayConfiguration.type
				};
				thisConfig[ 'GATEWAYS' ].append( currentEventGatewayConfiguration );
			}
		}

		writeWDDXConfigFile( thisConfig, configFilePath );
	}

	private function writeWebsocket() {
		var configFilePath = getCFHomePath().listAppend( getWebsocketConfigPath(), '/' );

		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getWebsocketConfigTemplate() );
		}

		if( !isNull( getWebsocketEnabled() ) ) { thisConfig[ 'startWebSocketService' ] = !!getWebsocketEnabled(); }

		writeWDDXConfigFile( thisConfig, configFilePath );
	}

	private function writeJetty() {
		var configFilePath = getCFHomePath().listAppend( getJettyConfigPath(), '/' );

		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readXMLConfigFile( configFilePath );
			var docType = getDocTypeFromXMLFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readXMLConfigFile( getJettyConfigTemplate() );
			var docType = getDocTypeFromXMLFile( getJettyConfigTemplate() );
		}

		var hostSearch = XMLSearch( thisConfig, "//Call[@name='addConnector']/Arg/New/Set[@name='host']" );
		var portSearch = XMLSearch( thisConfig, "//Call[@name='addConnector']/Arg/New/Set[@name='port']" );

		if( !isNull( getMonitoringServiceHost() ) && hostSearch.len() ) {
			hostSearch[ 1 ].XMLText = getMonitoringServiceHost();
		}

		if( !isNull( getMonitoringServicePort() ) && portSearch.len() ) {
			portSearch[ 1 ].XMLText = getMonitoringServicePort();
		}

		writeXMLConfigFile( thisConfig, configFilePath, docType );
	}

	private function writeDotNet() {
		var configFilePath = getCFHomePath().listAppend( getDotNetConfigPath(), '/' );

		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getDotNetConfigTemplate() );
		}

		// All of these are strings, even the ports!
		if( !isNull( getDotNetPort() ) ) { thisConfig[ 'port' ] = getDotNetPort()&''; }
		if( !isNull( getDotNetClientPort() ) ) { thisConfig[ 'dotnetport' ] = getDotNetClientPort()&''; }
		if( !isNull( getDotNetInstallDir() ) ) { thisConfig[ 'install_dir' ] = getDotNetInstallDir()&''; }
		if( !isNull( getDotNetProtocol() ) ) { thisConfig[ 'protocol' ] = getDotNetProtocol()&''; }

		writeWDDXConfigFile( thisConfig, configFilePath );
	}



	private function writeClientStore() {
		var configFilePath = getCFHomePath().listAppend( getClientStoreConfigPath(), '/' );

		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getClientStoreConfigTemplate() );
		}

		if( !isNull( getClientStorage() ) ) {
			var thisClientStorage = getClientStorage();

			// These Lucee values aren't valid on Adobe, so swap to Cookie instead
			if( listFindNoCase( 'memory,file', thisClientStorage ) ) {
				thisClientStorage = 'Cookie';
			}
			thisConfig[ 2 ].default = thisClientStorage;
		}
		if( !isNull( getUseUUIDForCFToken() ) ) { thisConfig[ 2 ].uuidToken = ( getUseUUIDForCFToken() ? true : false ); }
		if( !isNull( getClientStoragePurgeInterval() ) ) {
			// A colon-delimited list with 2 items representing hours and minutes. Ex: 1:7
			thisConfig[ 2 ][ 'PURGE_INTERVAL' ] = int( getClientStoragePurgeInterval() / 60 ) & ':' & int( getClientStoragePurgeInterval() % 60 );
		}


		if( !isNull( getClientStorageLocations() ) ) {

			// Clear out all storages locations except for for these special ones that should always be there
			var ignoredLocations = [ 'Registry', 'Cookie' ];
			for( var thisLocation in thisConfig[ 1 ] ) {
				if( !ignoredLocations.findNoCase( thisLocation ) ) {
					structDelete( thisConfig[ 1 ], thisLocation );
				}
			}

			for( var storageLocation in getClientStorageLocations() ?: {} ) {
				var thisLocation = getClientStorageLocations()[ storageLocation ];
				var thisName = thisLocation[ 'name' ];
				// Write out each of the client storage locations
				thisConfig[ 1 ][ storageLocation ] = {
					'name' : thisName,
					'description' : thisLocation[ 'description' ] ?: '',
					'disable_globals' : !!( thisLocation[ 'disableGlobals' ] ?: false ),
					'purge' : !!( thisLocation[ 'purgeEnable' ] ?: false ),
					'timeout' : ( thisLocation[ 'purgeTimeout' ] ?: 90 )+0,
					'type' : thisLocation[ 'type' ] ?: ( listFindNoCase( 'Cookie,Registry', thisName ) ? thisName : 'JDBC' )
				};

				// Add in DSN if it exists
				if( !isNull( thisLocation[ 'DSN' ] ) ) {
					thisConfig[ 1 ][ storageLocation ][ 'DSN' ] = thisLocation[ 'DSN' ];
				}

			}
		}

		writeWDDXConfigFile( thisConfig, configFilePath );
	}

	private function writeSecurity() {
		var configFilePath = getCFHomePath().listAppend( getSecurityConfigPath(), '/' );

		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getSecurityConfigTemplate() );
		}

		if( !isNull( getSecureProfileEnabled() ) ) { thisConfig[ 'secureprofile.enabled' ] = !!getSecureProfileEnabled(); }
		// It's a string in the WDDX, not a boolean!
		if( !isNull( getAdminRDSEnabled() ) ) { thisConfig[ 'rds.enabled' ] = getAdminRDSEnabled()&''; }
		if( !isNull( getAdminSalt() ) ) { thisConfig[ 'admin.userid.root.salt' ] = getAdminSalt(); }
		if( !isNull( getAdminLoginRequired() ) ) { thisConfig[ 'admin.security.enabled' ] = !!getAdminLoginRequired(); }
		if( !isNull( getAdminUserIDRequired() ) ) { thisConfig[ 'admin.userid.required' ] = !!getAdminUserIDRequired(); }
		if( !isNull( getAdminRootUserID() ) ) { thisConfig[ 'admin.userid.root' ] = getAdminRootUserID(); }
		if( !isNull( getAdminAllowConcurrentLogin() ) ) { thisConfig[ 'allowconcurrentadminlogin' ] = !!getAdminAllowConcurrentLogin(); }
		if( !isNull( getSandboxEnabled() ) ) { thisConfig[ 'sbs.security.enabled' ] = !!getSandboxEnabled(); }
		if( !isNull( getAdminAllowedIPList() ) ) { thisConfig[ 'allowedAdminIPList' ] = getAdminAllowedIPList(); }
		if( !isNull( getServicesAllowedIPList() ) ) { thisConfig[ 'allowedIPList' ] = getServicesAllowedIPList(); }

		// CF9 is boolean, CF10+ is string
		if( getAdminRDSLoginRequiredBoolean() ) {
			// Force to boolean
			if( !isNull( getAdminRDSLoginRequired() ) ) { thisConfig[ 'rds.security.enabled' ] = !!getAdminRDSLoginRequired(); }
		} else {
			// Force to string
			if( !isNull( getAdminRDSLoginRequired() ) ) { thisConfig[ 'rds.security.enabled' ] = getAdminRDSLoginRequired()&''; }
		}


		if( !isNull( getAdminRDSUserIDRequired() ) ) { thisConfig[ 'rds.security.usesinglerdspassword' ] = !!getAdminRDSUserIDRequired(); }

		writeWDDXConfigFile( thisConfig, configFilePath );
	}

	private function writeWatch() {
		var configFilePath = getCFHomePath().listAppend( getWatchConfigPath(), '/' );

		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getWatchConfigTemplate() );
		}

		if( !isNull( getWatchConfigFilesForChangesEnabled() ) ) { thisConfig[ 'watch.watchEnabled' ] = getWatchConfigFilesForChangesEnabled() ? true : false; }
		if( !isNull( getWatchConfigFilesForChangesInterval() ) ) { thisConfig[ 'watch.interval' ] = getWatchConfigFilesForChangesInterval()+0; }
		if( !isNull( getWatchConfigFilesForChangesExtensions() ) ) { thisConfig[ 'watch.extensions' ] = getWatchConfigFilesForChangesExtensions(); }

		writeWDDXConfigFile( thisConfig, configFilePath );

	}

	private function writeMail() {
		var configFilePath = getCFHomePath().listAppend( getMailConfigPath(), '/' );
		var passwordManager = getAdobePasswordManager();

		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getMailConfigTemplate() );
		}

		if( !isNull( getMailSpoolEnable() ) ) { thisConfig.spoolEnable = getMailSpoolEnable() ? true : false; }
		if( !isNull( getMailSpoolInterval() ) ) { thisConfig.schedule = getMailSpoolInterval()+0; }
		if( !isNull( getMailConnectionTimeout() ) ) { thisConfig.timeout = getMailConnectionTimeout()+0; }
		if( !isNull( getMailDownloadUndeliveredAttachments() ) ) { thisConfig.allowDownload = getMailDownloadUndeliveredAttachments() ? true : false; }
		if( !isNull( getMailSignMesssage() ) ) { thisConfig.sign = getMailSignMesssage() ? true : false; }
		if( !isNull( getMailSignKeystore() ) ) { thisConfig.keystore = getMailSignKeystore(); }
		if( !isNull( getMailSignKeystorePassword() ) ) { thisConfig.keystorepassword = passwordManager.encryptMailServer( getMailSignKeystorePassword() ); }
		if( !isNull( getMailSignKeyAlias() ) ) { thisConfig.keyAlias = getMailSignKeyAlias(); }
		if( !isNull( getMailSignKeyPassword() ) ) { thisConfig.keypassword = passwordManager.encryptMailServer( getMailSignKeyPassword() ); }
		if( !isNull( getMailLogEnabled() ) ) { thisConfig.mailsentloggingenable = getMailLogEnabled() ? true : false; }
		if( !isNull( getMailLogSeverity() ) ) { thisConfig.severity = getMailLogSeverity(); }
		if( !isNull( getMailMaxThreads() ) ) { thisConfig.maxthreads = getMailMaxThreads()+0; }


		// Adobe can only store 1 mail server, so ignore any others.
		if( !isNull( getMailServers() ) && arrayLen( getMailServers() ) ) {
			var mailServer = getMailServers()[ 1 ];

			if( !isNull( mailServer.smtp ) ) { thisConfig.server = mailServer.smtp; }
			if( !isNull( mailServer.username ) ) { thisConfig.username = mailServer.username; }
			if( !isNull( mailServer.password ) ) { thisConfig.password = passwordManager.encryptMailServer( mailServer.password ); }
			if( !isNull( mailServer.port ) ) { thisConfig.port = val( mailServer.port ); }
			if( !isNull(  mailServer.SSL ) ) { thisConfig.useSSL = ( mailServer.SSL ? true : false ); }
			if( !isNull( mailServer.TLS ) ) { thisConfig.useTLS = ( mailServer.TLS ? true : false ); }
		}

		writeWDDXConfigFile( thisConfig, configFilePath );
	}

	private function writeDatasource() {
		var configFilePath = getCFHomePath().listAppend( getDatasourceConfigPath(), '/' );
		var passwordManager = getAdobePasswordManager();

		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getDatasourceConfigTemplate() );
		}

		if( !isNull( getQueryCacheSize() ) ) { thisConfig[ 2 ].maxcachecount = getQueryCacheSize()+0; }

		if( !isNull( getDatasources() ) ) {

			thisConfig[ 1 ] = {};

			var datasources = getDatasources();

			for( var datasource in datasources ) {
				// For brevity
				var incomingDS = datasources[ datasource ];
				thisConfig[ 1 ][ datasource ] = thisConfig[ 1 ][ datasource ] ?: DSNUtil.getDefaultDatasourceStruct( DSNUtil.translateDatasourceDriverToAdobe( incomingDS.dbdriver ?: 'Other'  ) );
				var savingDS = thisConfig[ 1 ][ datasource ];

				savingDS.name = datasource;

				// Only use the incoming JDBC URL if it exists and this is a datasource of type other or we don't have a default URL
				// for this DB type.  This is to prevent a Lucee JDBC URL from getting imported into Adobe.
				// Instead, the URL will be pulled from  getDefaultDatasourceStruct() above.
				if( incomingDS.keyExists( 'dsn' ) && ( ( incomingDS.dbdriver ?: 'Other' ) == 'Other' || !savingDS.url.len() ) ) {
						savingDS.url = incomingDS.dsn;
				}

				// Invert logic
				if( !isNull( incomingDS.blob ) ) { savingDS.disable_blob = !incomingDS.blob; }
				if( !isNull( incomingDS.dbdriver ) ) { savingDS.class = DSNUtil.translateDatasourceClassToAdobe( DSNUtil.translateDatasourceDriverToAdobe( incomingDS.dbdriver ), incomingDS.class ?: '' ); }
				// Invert logic
				if( !isNull( incomingDS.clob ) ) { savingDS.disable_clob = !incomingDS.clob; }

				if( !isNull( incomingDS.connectionLimit ) ) {
					// If the field is "-1" (unlimited) then remove it entirely from the config
					if( incomingDS.connectionLimit == -1 ) {
						structDelete( savingDS.urlmap, 'maxConnections' );
					} else {
						savingDS.urlmap.maxConnections = incomingDS.connectionLimit;
					}
				}

				// Convert from minutes to seconds
				if( !isNull( incomingDS.connectionTimeout ) ) { savingDS.timeout = incomingDS.connectionTimeout * 60; }
				if( !isNull( incomingDS.database ) ) {
					savingDS.urlmap.database = incomingDS.database;
					savingDS.urlmap.connectionprops.database = incomingDS.database;
					savingDS.url = savingDS.url.replaceNoCase( '{database}', incomingDS.database );
				} else {
					// Database is not required.
					// Need to turn jdbc:mysql://127.0.0.1/{database} into jdbc:mysql://127.0.0.1/
					// And jdbc:macromedia:sqlserver://{host}:{port};databaseName={database};SelectMethod=direct; into jdbc:macromedia:sqlserver://{host}:{port};SelectMethod=direct;
					savingDS.url = savingDS.url.replaceNoCase( 'databaseName={database};', '' );
					savingDS.url = savingDS.url.replaceNoCase( '{database}', '' );
				}
				if( !isNull( incomingDS.sendStringParametersAsUnicode ) ) {
					savingDS.urlmap.sendStringParametersAsUnicode = !!incomingDS.sendStringParametersAsUnicode;
					savingDS.urlmap.connectionprops.sendStringParametersAsUnicode = !!incomingDS.sendStringParametersAsUnicode;
					savingDS.url = savingDS.url.replaceNoCase( '{sendStringParametersAsUnicode}', !!incomingDS.sendStringParametersAsUnicode );
				} else if (structKeyExists(savingDS.urlmap.connectionprops, "sendStringParametersAsUnicode")) {
					savingDS.url = savingDS.url.replaceNoCase( '{sendStringParametersAsUnicode}', !!savingDS.urlmap.connectionprops.sendStringParametersAsUnicode );
				}
				// Normalize names
				if( !isNull( incomingDS.dbdriver ) ) { savingDS.driver = DSNUtil.translateDatasourceDriverToAdobe( incomingDS.dbdriver ); }
				if( !isNull( incomingDS.host ) ) {
					savingDS.urlmap.host = incomingDS.host;
					savingDS.urlmap.connectionprops.host = incomingDS.host;
					savingDS.url = savingDS.url.replaceNoCase( '{host}', incomingDS.host );
				}
				if( !isNull( incomingDS.password ) ) { savingDS.password = passwordManager.encryptDataSource( incomingDS.password ); }

				// Named SQL Server instances have no port, so remove the place holder
				if( isNull( incomingDS.port ) || trim( incomingDS.port ) == '' ) {
					savingDS.urlmap.port = '';
					savingDS.urlmap.connectionprops.port = '';
					savingDS.url = savingDS.url.replaceNoCase( ':{port}', '' );
				} else {
					savingDS.urlmap.port = incomingDS.port;
					savingDS.urlmap.connectionprops.port = incomingDS.port;
					savingDS.url = savingDS.url.replaceNoCase( '{port}', incomingDS.port );
				}

				if( !isNull( incomingDS.username ) ) { savingDS.username = incomingDS.username; }
				if( !isNull( incomingDS.validate ) ) { savingDS.validateConnection = !!incomingDS.validate; }

				// Check for Oracle Servicename
				if( !isNull( incomingDS.serviceName ) && len( incomingDS.serviceName ) ) {
					savingDS.urlmap.serviceName = incomingDS.serviceName;
					savingDS.urlmap.connectionprops.serviceName = incomingDS.serviceName;
					savingDS.url = savingDS.url.replaceNoCase( '{serviceName}', incomingDS.serviceName );
					// Remove SID in this case
					savingDS.url = savingDS.url.replaceNoCase( 'SID={SID};', '' );
					savingDS.urlmap.delete( 'SID' );
					savingDS.urlmap.connectionprops.delete( 'SID' );
				// Check for Oracle SID
				} else if( !isNull( incomingDS.SID ) && len( incomingDS.SID ) ) {
					savingDS.urlmap.SID = incomingDS.SID;
					savingDS.urlmap.connectionprops.SID = incomingDS.SID;
					savingDS.url = savingDS.url.replaceNoCase( '{SID}', incomingDS.SID );
					// Remove service name in this case
					savingDS.url = savingDS.url.replaceNoCase( 'ServiceName={serviceName};', '' );
					savingDS.urlmap.delete( 'SERVICENAME' );
					savingDS.urlmap.connectionprops.delete( 'SERVICENAME' );
				} else {
					// If there is no SID or serviceName, then just remove both of these.
					// This is technically not valid as the CF admin throws this error if you try to create a datasource with no SID and no serviceName
					// "Both SID Name and Service Name cannot be empty"
					savingDS.url = savingDS.url.replaceNoCase( 'SID={SID};', '' );
					savingDS.url = savingDS.url.replaceNoCase( 'ServiceName={serviceName};', '' );
				}
				// All the datasource templates default to true for all permissions, so a new datasource will have all permissions turned on by default.
				// When saving an existing datasource, default to whatever is there.
				savingDS.select = !!(incomingDS.allowSelect ?: savingDS.select);
				savingDS.delete = !!(incomingDS.allowDelete ?: savingDS.delete);
				savingDS.update = !!(incomingDS.allowUpdate ?: savingDS.update);
				savingDS.insert = !!(incomingDS.allowInsert ?: savingDS.insert);
				savingDS.create = !!(incomingDS.allowCreate ?: savingDS.create);
				savingDS.grant = !!(incomingDS.allowGrant ?: savingDS.grant);
				savingDS.revoke = !!(incomingDS.allowRevoke ?: savingDS.revoke);
				savingDS.drop = !!(incomingDS.allowDrop ?: savingDS.drop);
				savingDS.alter = !!(incomingDS.allowAlter ?: savingDS.alter);
				savingDS.storedproc = !!(incomingDS.allowStoredProcs ?: savingDS.storedproc);

				if( !isNull( incomingDS.maintainConnections ) ) { savingDS.pooling = !!incomingDS.maintainConnections; }
				if( !isNull( incomingDS.maxPooledStatements ) ) {
					savingDS.urlmap.maxPooledStatements = incomingDS.maxPooledStatements+0;
					savingDS.urlmap.connectionprops.maxPooledStatements = incomingDS.maxPooledStatements+0;
					savingDS.url = savingDS.url.replaceNoCase( '{maxPooledStatements}', incomingDS.maxPooledStatements+0 );
				} else if (structKeyExists(savingDS.urlmap.connectionprops, "maxPooledStatements")) {
					savingDS.url = savingDS.url.replaceNoCase( '{maxPooledStatements}', savingDS.urlmap.connectionprops.maxPooledStatements+0 );
				}
				if( !isNull( incomingDS.connectionTimeoutInterval ) ) { savingDS.interval = incomingDS.connectionTimeoutInterval+0; }
				if( !isNull( incomingDS.queryTimeout ) ) {
					savingDS.urlmap.qTimeout = incomingDS.queryTimeout+0;
					savingDS.urlmap.connectionprops.qTimeout = incomingDS.queryTimeout+0;
					savingDS.url = savingDS.url.replaceNoCase( '{queryTimeout}', incomingDS.queryTimeout+0 );
				} else if (structKeyExists(savingDS.urlmap.connectionprops, "qTimeout")) {
					savingDS.url = savingDS.url.replaceNoCase( '{queryTimeout}', savingDS.urlmap.connectionprops.qTimeout+0 );
				}
				if( !isNull( incomingDS.logActivity ) ) { savingDS.urlmap.useSpyLog = !!incomingDS.logActivity; }
				if( !isNull( incomingDS.logActivityFile ) ) { savingDS.urlmap.spyLogFile = incomingDS.logActivityFile; }
				if( !isNull( incomingDS.disableConnections ) ) { savingDS.disable = !!incomingDS.disableConnections; }
				if( !isNull( incomingDS.loginTimeout ) ) { savingDS.login_timeout = incomingDS.loginTimeout+0; }
				if( !isNull( incomingDS.clobBuffer ) ) { savingDS.buffer = incomingDS.clobBuffer+0; }
				if( !isNull( incomingDS.blobBuffer ) ) { savingDS.blob_buffer = incomingDS.blobBuffer+0; }
				if( !isNull( incomingDS.disableAutogeneratedKeyRetrieval ) ) { savingDS.disable_autogenkeys = !!incomingDS.disableAutogeneratedKeyRetrieval; }
				if( !isNull( incomingDS.validationQuery ) ) { savingDS.validationQuery = incomingDS.validationQuery; }
				if( !isNull( incomingDS.linkedServers ) ) { savingDS.urlmap.supportLinks = !!incomingDS.linkedServers; }
				if( !isNull( incomingDS.clientHostname ) ) { savingDS.clientinfo.ClientHostName = !!incomingDS.clientHostname; }
				if( !isNull( incomingDS.clientUsername ) ) { savingDS.clientinfo.ClientUser = !!incomingDS.clientUsername; }
				if( !isNull( incomingDS.clientApplicationName ) ) { savingDS.clientinfo.ApplicationName = !!incomingDS.clientApplicationName; }
				if( !isNull( incomingDS.clientApplicationNamePrefix ) ) { savingDS.clientinfo.ApplicationNamePrefix = incomingDS.clientApplicationNamePrefix; }
				if( !isNull( incomingDS.description ) ) { savingDS.description = incomingDS.description; }
				if( !isNull( incomingDS.custom ) ) {
					// Append in custom URL like foo=bar&baz=bum as struct keys into connectionprops
					var customAsStruct = DSNUtil.parseCustom( incomingDS.dbdriver ?: 'Other', incomingDS.custom );
					savingDS.urlmap.connectionprops.append( customAsStruct, false );
					if( len( incomingDS.custom ) ) {
						// TODO: possibly check for duplicate items specified both in a dedicated arg as well as in the custom URL.
						// Not sure which one to honor though
						var delim = DSNUtil.customURLDelimiter( incomingDS.dbdriver ?: 'Other' );
						var DBSpecificCustomURL = DSNUtil.assembleCustom( incomingDS.dbdriver ?: 'Other', customAsStruct )
						if( savingDS.url.endsWith( delim ) ) {
							savingDS.url = savingDS.url.left( -1 )
						}
						if( DBSpecificCustomURL.startsWith( delim ) ) {
							DBSpecificCustomURL = DBSpecificCustomURL.right( -1 )
						}
						if( savingDS.url.endsWith( '?' ) ) {
							savingDS.url = savingDS.url & DBSpecificCustomURL;
						} else {
							savingDS.url = savingDS.url & delim & DBSpecificCustomURL;
						}
						savingDS.urlmap.args = DBSpecificCustomURL;
					}
				}

			} // end loop over datasources

		} // end if datasources is null

		writeWDDXConfigFile( thisConfig, configFilePath );
	}

	private function writeAuth() {
		var configFilePath = getCFHomePath().listAppend( getPasswordPropertiesPath(), '/' );

		var propertyFile = wirebox.getInstance( 'propertyFile@propertyFile' );

		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			propertyFile.load( configFilePath );
		}

		if( !isNull( getAdminPassword() ) ) {
			propertyFile[ 'password' ] = getAdminPassword();
			propertyFile[ 'encrypted' ] = 'false';

			if( !isNull( getAdminRDSPassword() ) ) { propertyFile[ 'rdspassword' ] = getAdminRDSPassword(); }

			// CF will get angry if there's no rds password set, so make up one if we have to.
			if( !propertyFile.exists( 'rdspassword' ) ) {
				propertyFile[ 'rdspassword' ] = createUUID();
			}

			propertyFile.store( configFilePath );

		} else if( !isNull( getACF11Password() ) ) {
			propertyFile[ 'password' ] = getACF11Password();
			propertyFile[ 'encrypted' ] = 'true';

			if( !isNull( getACF11RDSPassword() ) ) { propertyFile[ 'rdspassword' ] = getACF11RDSPassword(); }

			// CF will get angry if there's no rds password set, so make up one if we have to.
			if( !propertyFile.exists( 'rdspassword' ) ) {
				propertyFile[ 'rdspassword' ] = createUUID();
			}

			propertyFile.store( configFilePath );
		}


	}

	private function writeLicense() {
		var configFilePath = getCFHomePath().listAppend( getLicensePropertiesPath(), '/' );

		var propertyFile = wirebox.getInstance( 'propertyFile@propertyFile' );

		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			propertyFile.load( configFilePath );
		// Else read the template
		} else {
			propertyFile.load( getLicensePropertiesTemplate() );
		}

		if( !isNull( getLicense() ) ) { propertyFile[ 'sn' ] = getLicense(); }
		if( !isNull( getPreviousLicense() ) ) { propertyFile[ 'previous_sn' ] = getPreviousLicense(); }

		propertyFile.store( configFilePath );
	}

	private function writeLogging() {
		var configFilePath = getCFHomePath().listAppend( getLoggingConfigPath(), '/' );

		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getLoggingConfigTemplate() );
		}

		if( !isNull( getLogFilesDisabled() ) ) {
			thisConfig[ 1 ] = getLogFilesDisabled();
		}

		if( !isNull( getLogDirectory() ) ) { thisConfig[ 2 ].logDirectory = getLogDirectory(); }
		// Setting is in KB, but storage is in B. Factor of 1000, not 1024.  Thanks, Adobe.
		if( !isNull( getLogMaxFileSize() ) ) { thisConfig[ 2 ].maxFileSize = getLogMaxFileSize()*1000; }
		if( !isNull( getLogMaxArchives() ) ) { thisConfig[ 2 ].maxFileBackup = getLogMaxArchives(); }
		if( !isNull( getLogSysLogEnabled() ) ) { thisConfig[ 2 ].enableOSLogging = !!getLogSysLogEnabled(); }

		writeWDDXConfigFile( thisConfig, configFilePath );

	}

	private function writeUpdate() {
		var configFilePath = getCFHomePath().listAppend( getUpdateConfigPath(), '/' );

		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readXMLConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readXMLConfigFile( getUpdateConfigTemplate() );
		}

		if( isNull( thisConfig.settings.update ) ) {
			var XMLNode = xmlElemnew(thisConfig,"update");
			XMLNode.XMLAttributes['sendupdate'] = true;
			XMLNode.XMLAttributes['checkperiodically'] = false;
			XMLNode.XMLAttributes['checkinterval'] = 10;
			XMLNode.XMLAttributes['autocheck'] = false;
			thisConfig.settings.XMLChildren.append( XMLNode );
		}
		if( isNull( thisConfig.settings.update.url ) ) {
			var XMLNode = xmlElemnew(thisConfig,"url");
			thisConfig.settings.update.XMLChildren.append( XMLNode );
		}
		if( isNull( thisConfig.settings.update.notification ) ) {
			var XMLNode = xmlElemnew(thisConfig,"notification");
			thisConfig.settings.update.XMLChildren.append( XMLNode );
		}
		if( isNull( thisConfig.settings.update.notification.emaillist ) ) {
			var XMLNode = xmlElemnew(thisConfig,"emaillist");
			thisConfig.settings.update.notification.XMLChildren.append( XMLNode );
		}
		if( isNull( thisConfig.settings.update.notification.fromemail ) ) {
			var XMLNode = xmlElemnew(thisConfig,"fromemail");
			thisConfig.settings.update.notification.XMLChildren.append( XMLNode );
		}
		if( isNull( thisConfig.settings.proxy ) ) {
			var XMLNode = xmlElemnew(thisConfig,"proxy");
			thisConfig.settings.XMLChildren.append( XMLNode );
		}
		if( isNull( thisConfig.settings.proxy.hostname ) ) {
			var XMLNode = xmlElemnew(thisConfig,"hostname");
			thisConfig.settings.proxy.XMLChildren.append( XMLNode );
		}
		if( isNull( thisConfig.settings.proxy.port ) ) {
			var XMLNode = xmlElemnew(thisConfig,"port");
			XMLNode.XMLText=0;
			thisConfig.settings.proxy.XMLChildren.append( XMLNode );
		}
		if( isNull( thisConfig.settings.proxy.username ) ) {
			var XMLNode = xmlElemnew(thisConfig,"username");
			thisConfig.settings.proxy.XMLChildren.append( XMLNode );
		}
		if( isNull( thisConfig.settings.proxy.password ) ) {
			var XMLNode = xmlElemnew(thisConfig,"password");
			thisConfig.settings.proxy.XMLChildren.append( XMLNode );
		}

		// Ignore Lucee URLs if transerring from an Lucee server to a Adobe server
		if( !isNull( getUpdateSiteURL() ) && !(getUpdateSiteURL() contains 'lucee' ) ) {
			thisConfig.settings.update.url.XMLText = getUpdateSiteURL();
		}

		if( !isNull( getUpdateCheckOnLoginEnable() ) ) { thisConfig.settings.update.XMLAttributes.autocheck = !!getUpdateCheckOnLoginEnable(); }
		if( !isNull( getUpdateCheckOnScheduleEnable() ) ) { thisConfig.settings.update.XMLAttributes.checkperiodically = !!getUpdateCheckOnScheduleEnable(); }
		if( !isNull( getUpdateCheckOnScheduleDays() ) ) { thisConfig.settings.update.XMLAttributes.checkinterval = getUpdateCheckOnScheduleDays()+0; }
		if( !isNull( getUpdateCheckOnScheduleToAddress() ) ) { thisConfig.settings.update.notification.emaillist.XMLText = getUpdateCheckOnScheduleToAddress(); }
		if( !isNull( getUpdateCheckOnScheduleFromAddress() ) ) { thisConfig.settings.update.notification.fromemail.XMLText = getUpdateCheckOnScheduleFromAddress(); }
		if( !isNull( getUpdateProxyHost() ) ) { thisConfig.settings.proxy.hostname.XMLText = getUpdateProxyHost(); }
		if( !isNull( getUpdateProxyPort() ) ) { thisConfig.settings.proxy.port.XMLText = val(  getUpdateProxyPort() ); }
		if( !isNull( getUpdateProxyUsername() ) ) { thisConfig.settings.proxy.username.XMLText = getUpdateProxyUsername(); }
		if( !isNull( getUpdateProxyPassword() ) ) { thisConfig.settings.proxy.password.XMLText = getUpdateProxyPassword(); }

		writeXMLConfigFile( thisConfig, configFilePath );

	}

	private function writeDocument() {
		var configFilePath = getCFHomePath().listAppend( getDocumentConfigPath(), '/' );

		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getDocumentConfigTemplate() );
		}

		if( !isNull( getPDFServiceManagers() ) ) {

			thisConfig[ 4 ] = {};

			var PDFServices = getPDFServiceManagers();

			for( var PDFServiceName in PDFServices ) {
				var incomingPDFService = PDFServices[ PDFServiceName ];
				thisConfig[ 4 ][ PDFServiceName ] = thisConfig[ 4 ][ PDFServiceName ] ?: {};
				var savingPDFService = thisConfig[ 4 ][ PDFServiceName ];

				savingPDFService[ 'name' ] = PDFServiceName;

				if( !isNull( incomingPDFService.hostname ) ) { savingPDFService[ 'hostname' ] = incomingPDFService.hostname; }
				if( !isNull( incomingPDFService.port ) ) { savingPDFService[ 'port' ] = incomingPDFService.port+0; }
				if( !isNull( incomingPDFService.isHTTPS ) ) { savingPDFService[ 'ishttps' ] = !!incomingPDFService.isHTTPS; }
				if( !isNull( incomingPDFService.weight ) ) { savingPDFService[ 'weight' ] = incomingPDFService.weight+0; }
				if( !isNull( incomingPDFService.isLocal ) ) { savingPDFService[ 'islocal' ] = !!incomingPDFService.isLocal; }
				// Default this to true for backwards compat
				incomingPDFService.isEnabled = incomingPDFService.isEnabled ?: true;
				savingPDFService[ 'isenabled' ] = !!incomingPDFService.isEnabled;

			} // end loop over datasources

		} // end if datasources is null

		writeWDDXConfigFile( thisConfig, configFilePath );
	}

	private function writeGraph() {
		var configFilePath = getCFHomePath().listAppend( getGraphConfigPath(), '/' );

		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getGraphConfigTemplate() );
		}

		if( !isNull( getChartCacheType() ) ) { thisConfig[ 1 ].CacheType = getChartCacheType()+0; }
		if( !isNull( getChartCacheTTL() ) ) { thisConfig[ 1 ].TimeToLive = getChartCacheTTL()+0; }
		if( !isNull( getChartCacheSize() ) ) { thisConfig[ 1 ].CacheSize = getChartCacheSize()+0; }
		if( !isNull( getChartCacheDiskLocation() ) ) { thisConfig[ 1 ].CACHEPATH = getChartCacheDiskLocation(); }

		writeWDDXConfigFile( thisConfig, configFilePath );

	}

	private function ensureSeedProperties( required string seedPropertiesPath ) {
		if( !fileExists( seedPropertiesPath ) ) {
			wirebox.getInstance( 'propertyFile@propertyFile' )
				// Take the first 16 alphanumeric characters of a UUID.
				.set( 'seed', left( replace( createUUID(), '-', '', 'all' ), 16 ) )
				.set( 'algorithm', 'AES/CBC/PKCS5Padding' )
				.store( seedPropertiesPath );
		}

	}

	private function translateSharedErrorTemplateToAdobe( required string templateName, required string type ) {

		switch( templateName ) {
			case 'default' :
				return '';
			case 'secure' :
				if ( type == 'error' )
					return '/CFIDE/administrator/templates/secure_profile_error.cfm';
				else if ( type == 'missing' )
					return '/CFIDE/administrator/templates/missing_template_error.cfm';
			case 'neo' :
				return '';
			default :
				return arguments.templateName;
		}

	}

	private function translateAdobeToSharedErrorTemplate( required string templateName ) {

		switch( templateName ) {
			case '' :
				return 'default';
			case '/CFIDE/administrator/templates/secure_profile_error.cfm' :
				return 'secure';
			case '/CFIDE/administrator/templates/missing_template_error.cfm' :
				return 'secure';
			default :
				return arguments.templateName;
		}

	}

	private function getDefaultScheduledTaskData() {
		// These appear to be the default when adding via the UI (tested in 2016)
		return {
			'appname' : 'serverscheduletask',
			'chained' : 'false',
			'clustered' : 'false',
			'crontime' : '',
			'eventhandler' : '',
			'exclude' : '',
			'file' : '',
			'group' : '',
			'http_port' : '80',
			'http_proxy_port' : '80',
			'interval' : '',
			'lastfire' : '',
			'misfire' : '',
			'mode' : 'server',
			'nextfire' : '',
			'oncomplete' : '',
			'onexception' : '',
			'overwrite' : 'true',
			'password' : '',
			'path' : '\',
			'priority' : '5',
			'proxy_password' : '',
			'proxy_server' : '',
			'proxy_user' : '',
			'publish' : false,
			'remainingCount' : '1',
			'repeat' : 0,
			'request_time_out' : '',
			'resolveURL' : false,
			'retryCount' : '3',
			'start_date' : '',
			'start_time' : '',
			'status' : 'Running', // Paused
			'task' : '',
			'url' : '',
			'username' : '',
			'request_time_out' : ''
		};
	}

	/**
	* Reads an XML file from disk.  Returns a string or XML doc based on raw variable
	*/
	private function readXMLConfigFile( required string configFilePath, boolean raw=false ) {
		if( !fileExists( configFilePath ) ) {
			throw "The config file doesn't exist [#configFilePath#]";
		}

		var thisConfigRaw = fileRead( configFilePath );
		if( !isXML( thisConfigRaw ) ) {
			throw "Config file doesn't contain XML [#configFilePath#]";
		}

		if( raw ) {
			return thisConfigRaw;
		} else {
			return XMLParse( thisConfigRaw );
		}
	}

	/**
	* Reads an XML file from disk and parses the DOCTYPE element from it if it exists.
	* If no doctype is found, an empty string will be returned
	*/
	private function getDocTypeFromXMLFile( required string path ) {

		// Look for a doctype before we clobber it
		if( fileExists( path ) ) {
		 	var rawXMLOriginal = fileRead( path );
		 	var doctypeSearch = rawXMLOriginal.reFind( '<!DOCTYPE[^<]*>', 1, true );
		 	// Found a doctype in the original XML doc
		 	if( doctypeSearch.pos.len() && doctypeSearch.pos[ 1 ] ) {
		 		return rawXMLOriginal.mid( doctypeSearch.pos[ 1 ], doctypeSearch.len[ 1 ] );
		 	}
		}
		return '';
	}

	/**
	* Writes an XML file to disk and applies formatting to it.  If a DOCTYPE is supplied, it will be
	* inserted before the opening root tag.
	*/
	private function writeXMLConfigFile( required any data, required string configFilePath, string docType='' ) {
		// Ensure the parent directories exist
		directoryCreate( path=getDirectoryFromPath( configFilePath ), createPath=true, ignoreExists=true )

		var xlt = '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
			<xsl:output method="xml" encoding="utf-8" indent="yes" xslt:indent-amount="2" xmlns:xslt="http://xml.apache.org/xslt" />
			<xsl:strip-space elements="*"/>
			<xsl:template match="node() | @*"><xsl:copy><xsl:apply-templates select="node() | @*" /></xsl:copy></xsl:template>
			</xsl:stylesheet>';

		 var rawXMLToWrite = toString( XmlTransform( data, xlt) );

		// Look for a doctype before we clobber it
		if( docType.len() ) {
	 		var rootTagName = xmlParse( rawXMLToWrite ).XMLRoot.xmlName;
	 		rawXMLToWrite = rawXMLToWrite.reReplace( '(.*)(<#rootTagName#.*)', '\1#chr(10)##docType##chr(10)#\2' )
		}

		fileWrite( configFilePath, rawXMLToWrite );

	}

	/**
	* Reads a WDDX file from disk and returns parsed version.
	*/
	private function readWDDXConfigFile( required string configFilePath ) {
		var thisConfigRaw = readXMLConfigFile( configFilePath=configFilePath, raw=true );

		// Work around Lucee bug:
		// https://luceeserver.atlassian.net/browse/LDEV-1167
		thisConfigRaw = reReplaceNoCase( thisConfigRaw, '\s*type=["'']coldfusion\.server\.ConfigMap["'']', '', 'all' );
		thisConfigRaw = reReplaceNoCase( thisConfigRaw, '\s*type=["'']coldfusion\.util\.FastHashtable["'']', '', 'all' );

		// Check for Lucee's buggy parsing
		// https://luceeserver.atlassian.net/browse/LDEV-4392
		var testParse = xmlParse( thisConfigRaw );
		// Missing or empty data will just return empty struct
		if( !isDefined( "testParse.wddxPacket.data" ) || !testParse.wddxPacket.data.XMLChildren.len() ) {
			return {};
		}

		wddx action='wddx2cfml' input=thisConfigRaw output='local.thisConfig';
		if( isNull( local.thisConfig ) ) {
			return {};
		}
		return local.thisConfig;
	}

	/**
	* Writes a WDDX file to disk.
	*/
	private function writeWDDXConfigFile( required any data, required string configFilePath ) {

		wddx action='cfml2wddx' input=data output='local.thisConfigRaw';
		thisConfigRaw = thisConfigRaw.replaceNoCase( '<struct>', '<struct type="coldfusion.server.ConfigMap">', 'all' );
		// Adobe started erroring out if the conenctionProps struct was of type ConfigMap.
		thisConfigRaw = thisConfigRaw.replaceNoCase( '<var name=''CONNECTIONPROPS''><struct type="coldfusion.server.ConfigMap">', '<var name=''CONNECTIONPROPS''><struct>', 'all' );

		if( configFilePath contains 'saml' ) {
			local.thisConfigXML = XMLParse( thisConfigRaw );

			var SPConfigs = xmlSearch( thisConfigXML, "/wddxPacket/data/struct/var[@name='ServiceProvidersMap']/struct/var/struct" )
			SPConfigs.each( (node)=>node.XMLAttributes['type']='Lcoldfusion.saml.SpConfiguration;' );

			var SPConfigs = xmlSearch( thisConfigXML, "/wddxPacket/data/struct/var[@name='IdentityProvidersMap']/struct/var/struct" )
			SPConfigs.each( (node)=>node.XMLAttributes['type']='Lcoldfusion.saml.IdpConfiguration;' );

			thisConfigRaw = toString( thisConfigXML );
		}

		writeXMLConfigFile( thisConfigRaw, configFilePath );
	}

	private function translateWhitespaceToAdobe( required string whitespaceManagement ) {

		switch( whitespaceManagement ) {
			case 'off' :
			case 'regular' :
				return false;
			case 'simple' :
			case 'white-space' :
				return true;
			case 'smart' :
			case 'white-space-pref' :
				return true;
			default :
				return false;
		}

	}

	private function translateWhitespaceFromAdobe( required string whitespaceManagement ) {

		switch( whitespaceManagement ) {
			case false :
				return 'off';
			case true :
				return 'smart';
			default :
				return 'off';
		}

	}

}
