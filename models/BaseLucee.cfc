/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
*
* I represent shared behavior for all Lucee providers.  The concrete providers can override my methods and proeprties as neccessary.
* I extend the BaseConfig class, which represents the data itself.
*/
component accessors=true extends='cfconfig-services.models.BaseConfig' {

	property name='configFileTemplate' type='string';
	property name='configFileName' type='string';
	property name='configRelativePathWithinServerHome' type='string';
	property name='luceePasswordManager' inject='PasswordManager@lucee-password-util';


	/**
	* Constructor
	*/
	function init() {
		super.init();

		// Used when writing out a Lucee server context config file from the generic config
		setConfigFileTemplate( expandPath( '/cfconfig-services/resources/lucee4/lucee-server-base.xml' ) );

		// Ex: lucee-server/context/lucee-server.xml

		// This is the file name used by this config file
		setConfigFileName( 'lucee-server.xml' );
		// This is where said config file is stored inside the server home
		setConfigRelativePathWithinServerHome( '/context/' );

		setFormat( 'luceeServer' );
		setVersion( '4' );

		return this;
	}

	/**
	* I read in config
	*
	* @CFHomePath The server home directory
	*/
	function read( string CFHomePath ){
		// Override what's set if a path is passed in
		setCFHomePath( arguments.CFHomePath ?: getCFHomePath() );

		if( !len( getCFHomePath() ) ) {
			throw 'No CF home specified to read from';
		}

		var configFilePath = locateConfigFile();
		if( !fileExists( configFilePath ) ) {
			throw "The config file doesn't exist [#configFilePath#]";
		}

		var thisConfigRaw = fileRead( configFilePath );
		if( !isXML( thisConfigRaw ) ) {
			throw "Config file doesn't contain XML [#configFilePath#]";
		}

		var thisConfig = XMLParse( thisConfigRaw );

		//dump( thisConfig );abort;

		var compiler = xmlSearch( thisConfig, '/cfLuceeConfiguration/compiler' );
		if( compiler.len() ){ readCompiler( compiler[ 1 ] ); }

		var charset = xmlSearch( thisConfig, '/cfLuceeConfiguration/charset' );
		if( charset.len() ){ readCharset( charset[ 1 ] ); }

		var java = xmlSearch( thisConfig, '/cfLuceeConfiguration/java' );
		if( java.len() ){ readJava( java[ 1 ] ); }

		var regional = xmlSearch( thisConfig, '/cfLuceeConfiguration/regional' );
		if( regional.len() ){ readRegional( regional[ 1 ] ); }

		var datasources = xmlSearch( thisConfig, '/cfLuceeConfiguration/data-sources' );
		if( datasources.len() ){ readDatasources( datasources[ 1 ] ); }

		var thisApplication = xmlSearch( thisConfig, '/cfLuceeConfiguration/application' );
		if( thisApplication.len() ){ readApplication( thisApplication[ 1 ] ); }

		var scope = xmlSearch( thisConfig, '/cfLuceeConfiguration/scope' );
		if( scope.len() ){ readScope( scope[ 1 ] ); }

		var mail = xmlSearch( thisConfig, '/cfLuceeConfiguration/mail' );
		if( mail.len() ){ readMail( mail[ 1 ] ); }

		var mappings = xmlSearch( thisConfig, '/cfLuceeConfiguration/mappings' );
		if( mappings.len() ){ readMappings( mappings[ 1 ] ); }

		var customTags = xmlSearch( thisConfig, '/cfLuceeConfiguration/custom-tag' );
		if( customTags.len() ){ readCustomTags( customTags[ 1 ] ); }

		var debugging = xmlSearch( thisConfig, '/cfLuceeConfiguration/debugging' );
		if( debugging.len() ){ readDebugging( debugging[ 1 ] ); }

		var setting = xmlSearch( thisConfig, '/cfLuceeConfiguration/setting' );
		if( setting.len() ){ readSetting( setting[ 1 ] ); }

		var thisCache = xmlSearch( thisConfig, '/cfLuceeConfiguration/cache' );
		if( thisCache.len() ){ readCache( thisCache[ 1 ] ); }

		var logging = xmlSearch( thisConfig, '/cfLuceeConfiguration/logging' );
		if( logging.len() ){ readLoggers( logging[ 1 ] ); }

		var error = xmlSearch( thisConfig, '/cfLuceeConfiguration/error' );
    	if( error.len() ){ readError( error[ 1 ] ); }

		var extensionProviders = xmlSearch( thisConfig, '/cfLuceeConfiguration/extensions' );
    	if( extensionProviders.len() ){ readExtensionProviders( extensionProviders[ 1 ] ); }

		var security = xmlSearch( thisConfig, '/cfLuceeConfiguration/security' );
    	if( security.len() ){ readSecurity( security[ 1 ] ); }

		var update = xmlSearch( thisConfig, '/cfLuceeConfiguration/update' );
    	if( update.len() ){ readUpdate( update[ 1 ] ); }

		var system = xmlSearch( thisConfig, '/cfLuceeConfiguration/system' );
		if( system.len() ){ readSystem( system[ 1 ] ); }

		readAuth( thisConfig.XMLRoot );

		readConfigChanges( thisConfig.XMLRoot );

		return this;
	}

	private function readSecurity( security ) {
		var config = security.XMLAttributes;

		/*cache
		mapping
		orm
		search
		tag_registry
		tag_object
		tag_import
		tag_execute
		setting
		scheduled_task
		remote
		mail
		gateway
		file
		direct_java_access
		debugging
		datasource
		custom_tag
		cfx_usage
		cfx_setting
		*/

		if( !isNull( config[ 'access_write' ] ) ) { setAdminAccessWrite( config[ 'access_write' ] ); }
		if( !isNull( config[ 'access_read' ] ) ) { setAdminAccessRead( config[ 'access_read' ] ); }
	}

	private function readUpdate( update ) {
		var config = update.XMLAttributes;
		if( !isNull( config[ 'location' ] ) ) { setUpdateSiteURL( config[ 'location' ] ); }
	}

	private function readExtensionProviders( extensionProviders ) {
		var providers = extensionProviders.XMLChildren;
		var configExtproviders = getExtensionProviders() ?: [];
		for( var provider in providers ) {
			if( provider.XMLName == 'rhprovider' && isDefined( 'provider.XMLAttributes.url' ) && !configExtproviders.contains( provider.XMLAttributes.url ) ) {
				configExtproviders.append( provider.XMLAttributes.url );
				setExtensionProviders( configExtproviders );
			}
		}
	}

	private function readCompiler( compiler ) {
		var config = compiler.XMLAttributes;
		if( !isNull( config[ 'dot-notation-upper-case' ] ) ) { setDotNotationUpperCase( config[ 'dot-notation-upper-case' ] ); }
		if( !isNull( config[ 'full-null-support' ] ) ) { setNullSupport( config[ 'full-null-support' ] ); }
		if( !isNull( config[ 'suppress-ws-before-arg' ] ) ) { setSuppressWhitespaceBeforecfargument( config[ 'suppress-ws-before-arg' ] ); }
	}

	private function readCharset( charset ) {
		var config = charset.XMLAttributes;
		if( !isNull( config[ 'template-charset' ] ) ) { setTemplateCharset( config[ 'template-charset' ] ); }
		if( !isNull( config[ 'web-charset' ] ) ) { setWebCharset( config[ 'web-charset' ] ); }
		if( !isNull( config[ 'resource-charset' ] ) ) { setResourceCharset( config[ 'resource-charset' ] ); }
	}

	private function readJava( java ) {
		var config = java.XMLAttributes;
		if( !isNull( config[ 'inspect-template' ] ) ) { setInspectTemplate( config[ 'inspect-template' ] ); }
	}

	private function readRegional( regional ) {
		var config = regional.XMLAttributes;

		if( !isNull( config[ 'locale' ] ) ) { setThisLocale( config[ 'locale' ] ); }
		if( !isNull( config[ 'timeserver' ] ) ) { setTimeServer( config[ 'timeserver' ] ); }
		if( !isNull( config[ 'timezone' ] ) ) { setThisTimeZone( config[ 'timezone' ] ); }
		if( !isNull( config[ 'use-timeserver' ] ) ) { setUseTimeServer( config[ 'use-timeserver' ] ); }
	}

	private function readDatasources( datasources ) {
		var passwordManager = getLuceePasswordManager();

		var config = datasources.XMLAttributes;
		if( !isNull( config[ 'psq' ] ) ) { setDatasourcePreserveSingleQuotes( config[ 'psq' ] ); }

		for( var ds in datasources.XMLChildren ) {
			var params = structNew().append( ds.XMLAttributes );

			if( !isNull( params[ 'custom' ] ) ) {
				var customStruct = datasourceCustomToStruct( params[ 'custom' ] );
				if ( !isNull( customStruct[ 'sendStringParametersAsUnicode' ] ) ) {
					params[ 'sendStringParametersAsUnicode' ] = customStruct[ 'sendStringParametersAsUnicode' ];
				}
			}

			var permissions = translateBitMaskToPermissions( params.allow ?: '' );
			params.append( permissions );

			// Decrypt datasource password
			if( !isNull( params.password ) ) {
				params.password = passwordManager.decryptDataSource( replaceNoCase( params.password, 'encrypted:', '' ) );
			}
			addDatasource( argumentCollection = params );
		}
	}

	private function readApplication( thisApplication ) {
		var config = thisApplication.XMLAttributes;

		if( !isNull( config.requesttimeout ) ) {
			setRequestTimeout( config.requesttimeout );
			setRequestTimeoutEnabled( true );
		}
		if( !isNull( config[ 'allow-url-requesttimeout' ] ) ) { setRequestTimeoutInURL( config[ 'allow-url-requesttimeout' ] ); }
		if( !isNull( config[ 'script-protect' ] ) ) { setScriptProtect( config[ 'script-protect' ] ); }
		if( !isNull( config[ 'listener-type' ] ) ) { setApplicationListener( config[ 'listener-type' ] ); }
		if( !isNull( config[ 'listener-mode' ] ) ) { setApplicationMode( config[ 'listener-mode' ] ); }
		if( !isNull( config[ 'type-checking' ] ) ) { setUDFTypeChecking( config[ 'type-checking' ] ); }
	}

	private function readScope( scope ) {
		var config = scope.XMLAttributes;

		if( !isNull( config.applicationtimeout ) ) { setApplicationTimeout( config.applicationtimeout ); };
		if( !isNull( config[ 'cascade-to-resultset' ] ) ) { setSearchResultsets( config[ 'cascade-to-resultset' ] ); };
		if( !isNull( config.cascading ) ) { setScopeCascading( config.cascading ); };
		if( !isNull( config.clienttimeout ) ) { setClientTimeout( config.clienttimeout ); };
		if( !isNull( config[ 'client-max-age' ] ) ) { setClientTimeout( '#config[ 'client-max-age' ]#,0,0,0' ); };
		if( !isNull( config.clientmanagement ) ) { setClientManagement( config.clientmanagement ); };
		if( !isNull( config[ 'merge-url-form' ] ) ) { setMergeURLAndForm( config[ 'merge-url-form' ] ); };
		if( !isNull( config[ 'cgi-readonly' ] ) ) { setCGIReadOnly( config[ 'cgi-readonly' ] ); };
		if( !isNull( config.requesttimeout ) ) { setRequestTimeout( config.requesttimeout ); };
		if( !isNull( config.sessionmanagement ) ) { setSessionManagement( config.sessionmanagement ); };
		if( !isNull( config.sessiontimeout ) ) { setSessionTimeout( config.sessiontimeout ); };
		if( !isNull( config.setclientcookies ) ) { setClientCookies( config.setclientcookies ); };
		if( !isNull( config.setdomaincookie ) ) { setDomainCookies( config.setdomaincookie ); };
		if( !isNull( config.sessionStorage ) ) { setSessionStorage( config.sessionStorage ); };
		if( !isNull( config.clientStorage ) ) { setClientStorage( config.clientStorage ); };
		if( !isNull( config[ 'local-mode' ] ) ) { setLocalScopeMode( config[ 'local-mode' ] ); };
		if( !isNull( config[ 'session-type' ] ) ) { setSessionType( config[ 'session-type' ] ); };
	}

	private function readMail( mailServers ) {
		var passwordManager = getLuceePasswordManager();

		/* TODO:
		mailDefaultEncoding
		mailSpoolEnable
		mailConnectionTimeout*/

		for( var mailServer in mailServers.XMLChildren ) {
			var params = structNew().append( mailServer.XMLAttributes );
			// Decrypt mail server password
			if( !isNull( params.password ) ) {
				params.password = passwordManager.decryptDataSource( replaceNoCase( params.password, 'encrypted:', '' ) );
			}
			if( !isNull( params.life ) ) {
				params.lifeTimeout = params.life;
			}
			if( !isNull( params.idle ) ) {
				params.idleTimeout = params.idle;
			}
			addMailServer( argumentCollection = params );
		}
	}

	private function readMappings( mappings ) {
		var ignores = [ '/lucee-server/' , '/lucee/', '/lucee/doc', '/lucee/admin' ];

		for( var mapping in mappings.XMLChildren ) {
			var params = structNew().append( mapping.XMLAttributes );

			if( ignores.findNoCase( params.virtual ) ) {
				continue;
			}
			addCFMapping( argumentCollection = params );
		}
	}

	private function readCustomTags( customTags ) {
		for( var customTagPath in customTags.XMLChildren ) {
			var params = structNew().append( customTagPath.XMLAttributes );
			if ( isNull( params.virtual ) ) {
				// The first, reserved key doesn't have a virtual tag, skip it
				continue;
			}
			var virtual = params.virtual;
			StructDelete(params, "virtual");

			// If the virtual is of the form ^/[0-9A-Fa-f]{32}$ then it's a "dynamic" name
			// Otherwise, it's an explicit name starting with /
			if( Len( virtual ) > 1 && not reFindNoCase( "^/[0-9a-f]{32}$", virtual ) ) {
				params.name = Mid(virtual, 2, Len( virtual ));
			}
			addCustomTagPath( argumentCollection = params );

		}
	}

	private function readDebugging( debugging ) {

		if( !isNull( debugging.XmlAttributes.debug ) ) { setDebuggingEnabled( debugging.XmlAttributes.debug ); }
		if( !isNull( debugging.XmlAttributes.database ) ) { setDebuggingDBEnabled( debugging.XmlAttributes.database ); }
		if( !isNull( debugging.XmlAttributes.exception ) ) { setDebuggingExceptionsEnabled( debugging.XmlAttributes.exception ); }
		if( !isNull( debugging.XmlAttributes[ 'query-usage' ] ) ) { setDebuggingQueryUsageEnabled( debugging.XmlAttributes[ 'query-usage' ] ); }
		if( !isNull( debugging.XmlAttributes.tracing ) ) { setDebuggingTracingEnabled( debugging.XmlAttributes.tracing ); }
		if( !isNull( debugging.XmlAttributes.dump ) ) { setDebuggingDumpEnabled( debugging.XmlAttributes.dump ); }
		if( !isNull( debugging.XmlAttributes.timer ) ) { setDebuggingTimerEnabled( debugging.XmlAttributes.timer ); }
		if( !isNull( debugging.XmlAttributes[ 'implicit-access' ] ) ) { setDebuggingImplicitVariableAccessEnabled( debugging.XmlAttributes[ 'implicit-access' ] ); }
		if( !isNull( debugging.XmlAttributes[ 'max-records-logged' ] ) ) { setDebuggingMaxLoggedRequests( debugging.XmlAttributes[ 'max-records-logged' ] ); }

	}

	private function readAuth( config ) {
		var passwordManager = getLuceePasswordManager();

		// See comments in BaseConfig properties for details
		if( !isNull( config.XmlAttributes.hspw ) ) { setHspw( config.XmlAttributes.hspw ); }
		if( !isNull( config.XmlAttributes.pw ) ) { setPw( config.XmlAttributes.pw ); }
		if( !isNull( config.XmlAttributes.salt ) ) { setAdminSalt( config.XmlAttributes.salt ); }
		if( !isNull( config.XmlAttributes[ 'default-hspw' ] ) ) { setDefaultHspw( config.XmlAttributes[ 'default-hspw' ] ); }
		if( !isNull( config.XmlAttributes[ 'default-pw' ] ) ) { setDefaultPw( config.XmlAttributes[ 'default-pw' ] ); }

		// Backwards compat for old, encrypted passwords
		if( !isNull( config.XmlAttributes.password ) ) {
			// Set decrypted password and ensure we have a salt.  It will be salted and hashed the next time we save.
			setAdminPassword( passwordManager.decryptAdministrator( config.XmlAttributes.password ) );
			if( isNull( getAdminSalt() ) ){
				setAdminSalt( createUUID() );
			}
		}
		if( !isNull( config.XmlAttributes[ 'default-password' ] ) ) {
			// Set decrypted default password and ensure we have a salt.  It will be salted and hashed the next time we save.
			setAdminPasswordDefault( passwordManager.decryptAdministrator( config.XmlAttributes[ 'default-password' ] ) );
			if( isNull( getAdminSalt() ) ){
				setAdminSalt( createUUID() );
			}
		}
	}

	private function readConfigChanges( config ) {
		if( !isNull( config.XmlAttributes[ 'check-for-changes' ] ) ) {
			setWatchConfigFilesForChangesEnabled( ( config.XmlAttributes[ 'check-for-changes' ] ? true : false ) );
			setWatchConfigFilesForChangesInterval( 60 );
			setWatchConfigFilesForChangesExtensions( 'xml,properties' );
		}
	}

	private function readSetting( settings ) {
		var config = settings.XMLAttributes;

		if( !isNull( config[ 'allow-compression' ] ) ) { setCompression( config[ 'allow-compression' ] ); }
		if( !isNull( config[ 'cfml-writer' ] ) ) { setWhitespaceManagement( translateWhitespaceFromLucee( config[ 'cfml-writer' ] ) ); }
		if( !isNull( config[ 'buffer-output' ] ) ) { setBufferTagBodyOutput( config[ 'buffer-output' ] ); }
		if( !isNull( config[ 'suppress-content' ] ) ) { setSupressContentForCFCRemoting( config[ 'suppress-content' ] ); }
	}

	private function readCache( thisCache ) {
		var config = thisCache.XMLAttributes;

		if( !isNull( config[ 'default-function' ] ) ) { setCacheDefaultFunction( config[ 'default-function' ] ); }
		if( !isNull( config[ 'default-object' ] ) ) { setCacheDefaultObject( config[ 'default-object' ] ); }
		if( !isNull( config[ 'default-template' ] ) ) { setCacheDefaultTemplate( config[ 'default-template' ] ); }
		if( !isNull( config[ 'default-query' ] ) ) { setCacheDefaultQuery( config[ 'default-query' ] ); }
		if( !isNull( config[ 'default-resource' ] ) ) { setCacheDefaultResource( config[ 'default-resource' ] ); }
		if( !isNull( config[ 'default-include' ] ) ) { setCacheDefaultInclude( config[ 'default-include' ] ); }
		// Only found/used in Lucee 5
		if( !isNull( config[ 'default-file' ] ) ) { setCacheDefaultFile( config[ 'default-file' ] ); }
		if( !isNull( config[ 'default-http' ] ) ) { setCacheDefaultHTTP( config[ 'default-http' ] ); }
		if( !isNull( config[ 'default-webservice' ] ) ) { setCacheDefaultWebservice( config[ 'default-webservice' ] ); }

		for( var connection in thisCache.XMLChildren ) {
			var params = structNew().append( connection.XMLAttributes );

			// Rename read-only to readOnly
			if( !isNull( params[ 'read-only' ] ) ) { params[ 'readOnly' ] = params[ 'read-only' ]; }

			// Turn custom values into struct
			if( !isNull( params[ 'custom' ] ) ) {
				var thisCustom = params[ 'custom' ];
				var thisStruct = {};
				for( var item in thisCustom.listToArray( '&' ) ) {
					// Turn foo=bar&baz=bum&poof= into { foo : 'bar', baz : 'bum', poof : '' }
					// Any "=" or "&" in the key values will be URL encoded.
					thisStruct[ URLDecode( listFirst( item, '=' ) ) ] = ( listLen( item, '=' ) ?  URLDecode( listRest( item, '=' ) ) : '' );
				}
				// Overwrite original string with struct
				params[ 'custom' ] = thisStruct;
			}

			// If we have a class and we recognize it, generate the human-readable type
			if( !isNull( params.class ) && translateCacheClassToType( params.class ).len() ) {
				params.type = translateCacheClassToType( params.class );
			}

			addCache( argumentCollection = params );
		}

	}

	private function readLoggers( loggers ) {
		for ( var logger in loggers.XMLChildren ) {
			var attrStruct = structNew().append( logger.XMLAttributes );
			var params = { };

			for ( var attrName in attrStruct ) {
				// translate from {var}-arguments and {var}-class to {var}Arguments and {var}Class
				var paramKey = REReplace( attrName, '-([ac])', '\U\1' );
				if ( attrName.listLast( '-' ) == 'arguments' ) {
					params[ paramKey ] = { };
					for ( var arg in attrStruct[ attrName ].listToArray( ';' ) ) {
						params[ paramKey ][ arg.listFirst( ':' ) ] = arg.listRest( ':' );
					}
				} else {
					params[ paramKey ] = attrStruct[ attrName ];
				}
			}
			addLogger( argumentCollection = params );
		}
	}

	private function readError( error ) {
	    var config = error.XMLAttributes;
	    if( !isNull( config[ 'status-code' ] ) ) { setErrorStatusCode( config[ 'status-code' ] ); }
	    if( !isNull( config[ 'template-404' ] ) ) { setMissingErrorTemplate( translateLuceeToSharedErrorTemplate( config[ 'template-404' ] ) ); }
	    if( !isNull( config[ 'template-500' ] ) ) { setGeneralErrorTemplate( translateLuceeToSharedErrorTemplate( config[ 'template-500' ] ) ); }
	}

	private function readSystem( system ) {
		var config = system.XMLAttributes;
		if( !isNull( config[ 'out' ] ) ) { setSystemOut( config[ 'out' ] ); }
		if( !isNull( config[ 'err' ] ) ) { setSystemErr( config[ 'err' ] ); }
	}

	/**
	* I write out config
	*
	* @CFHomePath The server home directory
	*/
	function write( string CFHomePath ){
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
		writeApplication( thisConfig );
		writeScope( thisConfig );
		writeMail( thisConfig );
		writeMappings( thisConfig );
		writeCustomTags( thisConfig );
		writeDebugging( thisConfig );
		writeAuth( thisConfig );
		writeCompiler( thisConfig );
		writeCharset( thisConfig );
		writeJava( thisConfig );
		writeRegional( thisConfig );
		writeSetting( thisConfig );
		writeConfigChanges( thisConfig );
		writeCache( thisConfig );
		writeLoggers( thisConfig );
		writeError( thisConfig );
		writeExtensionProviders( thisConfig );
		writeSecurity( thisConfig );
		writeUpdate( thisConfig );
		writeSystem( thisConfig );

		// Ensure the parent directories exist
		directoryCreate( path=getDirectoryFromPath( configFilePath ), createPath=true, ignoreExists=true );
		fileWrite( configFilePath, toString( thisConfig ) );

		return this;
	}


	private function writeSecurity( thisConfig ) {
		var securitySearch = xmlSearch( thisConfig, '/cfLuceeConfiguration/security' );
		if( securitySearch.len() ) {
			var security = securitySearch[1];
		} else {
			var security = xmlElemnew( thisConfig, 'security' );
		}

		var config = security.XMLAttributes;

		if( !isNull( getAdminAccessWrite() ) ) {
			config[ 'access_write' ] = getAdminAccessWrite() == 'closed' ? 'close' : getAdminAccessWrite();
		}
		if( !isNull( getAdminAccessRead() ) ) {
			config[ 'access_read' ] = getAdminAccessRead() == 'closed' ? 'close' : getAdminAccessRead();
		}

		if( !securitySearch.len() ) {
			thisConfig.XMLRoot.XMLChildren.append( security );
		}

	}


	private function writeUpdate( thisConfig ) {
		var updateSearch = xmlSearch( thisConfig, '/cfLuceeConfiguration/update' );
		if( updateSearch.len() ) {
			var update = updateSearch[1];
		} else {
			var update = xmlElemnew( thisConfig, 'update' );
		}

		var config = update.XMLAttributes;

		// Ignore Adobe URLs if transerring from an Adobe server to a Lucee server
		if( !isNull( getUpdateSiteURL() ) && !( getUpdateSiteURL() contains 'adobe' ) ) {
			config[ 'location' ] = getUpdateSiteURL();
		}

		if( !updateSearch.len() ) {
			thisConfig.XMLRoot.XMLChildren.append( update );
		}

	}

	private function writeExtensionProviders( thisConfig ) {

		// Only save if we have something defined
		if( isNull( getExtensionProviders() ) ) {
			return;
		}

		var extensionProviderSearch = xmlSearch( thisConfig, '/cfLuceeConfiguration/extensions' );
		if( extensionProviderSearch.len() ) {
			var extensionProviders = extensionProviderSearch[1];
		} else {
			var extensionProviders = xmlElemnew( thisConfig, 'extensions' );
		}

		var configProviders = extensionProviders;
		// Loop througuh and add missing providers.  We don't blow away the entire array
		// because it's also used to store information about extensions too
		for( var providerURL in getExtensionProviders() ) {
			var extProviderSearch = xmlSearch( configProviders, "//extensions/rhprovider[@url='#providerURL#']" );
			if( !extProviderSearch.len() ) {
				var newProviderElem = xmlElemnew( thisConfig, 'rhprovider' );
				newProviderElem.XMLAttributes[ 'url' ]=providerURL;
				configProviders.XMLChildren.append( newProviderElem );
			}
		}

		if( !extensionProviderSearch.len() ) {
			thisConfig.XMLRoot.XMLChildren.append( extensionProviders );
		} else {
			var validProviders = getExtensionProviders();
			// Since we didn't blow away the array above, clean out any that shouldn't be there
			var len = extensionProviders.XMLChildren.len();
			var i = 0;
			while( ++i <= len ) {
				if( extensionProviders.XMLChildren[ i ].XMLName == 'rhprovider' && !validProviders.contains( extensionProviders.XMLChildren[ i ].XMLAttributes.url ) ) {
					extensionProviders.XMLChildren.deleteAt( i );
					// Moving target
					i--;
					len--;
				}
			}
		}
	}

	private function writeCompiler( thisConfig ) {
		var compilerSearch = xmlSearch( thisConfig, '/cfLuceeConfiguration/compiler' );
		if( compilerSearch.len() ) {
			var compiler = compilerSearch[1];
		} else {
			var compiler = xmlElemnew( thisConfig, 'compiler' );
		}

		var config = compiler.XMLAttributes;

		if( !isNull( getDotNotationUpperCase() ) ) { config[ 'dot-notation-upper-case' ] = getDotNotationUpperCase(); }
		if( !isNull( getNullSupport() ) ) { config[ 'full-null-support' ] = getNullSupport(); }
		if( !isNull( getSuppressWhitespaceBeforecfargument() ) ) { config[ 'suppress-ws-before-arg' ] = getSuppressWhitespaceBeforecfargument(); }

		if( !compilerSearch.len() ) {
			thisConfig.XMLRoot.XMLChildren.append( compiler );
		}
	}

	private function writeCharset( thisConfig ) {
		var charsetSearch = xmlSearch( thisConfig, '/cfLuceeConfiguration/charset' );
		if( charsetSearch.len() ) {
			var charset = charsetSearch[1];
		} else {
			var charset = xmlElemnew( thisConfig, 'charset' );
		}

		var config = charset.XMLAttributes;

		if( !isNull( getTemplateCharset() ) ) { config[ 'template-charset' ] = getTemplateCharset(); }
		if( !isNull( getWebCharset() ) ) { config[ 'web-charset' ] = getWebCharset(); }
		if( !isNull( getResourceCharset() ) ) { config[ 'resource-charset' ] = getResourceCharset(); }

		if( !charsetSearch.len() ) {
			thisConfig.XMLRoot.XMLChildren.append( charset );
		}
	}

	private function writeJava( thisConfig ) {
		var javaSearch = xmlSearch( thisConfig, '/cfLuceeConfiguration/java' );
		if( javaSearch.len() ) {
			var java = javaSearch[1];
		} else {
			var java = xmlElemnew( thisConfig, 'java' );
		}

		var config = java.XMLAttributes;

		if( !isNull( getInspectTemplate() ) ) { config[ 'inspect-template' ] = getInspectTemplate(); }

		if( !javaSearch.len() ) {
			thisConfig.XMLRoot.XMLChildren.append( java );
		}
	}

	private function writeRegional( thisConfig ) {
		var regionalSearch = xmlSearch( thisConfig, '/cfLuceeConfiguration/regional' );
		if( regionalSearch.len() ) {
			var regional = regionalSearch[1];
		} else {
			var regional = xmlElemnew( thisConfig, 'regional' );
		}

		var config = regional.XMLAttributes;

		if( !isNull( getThisLocale() ) ) { config[ 'locale' ] = getThisLocale(); }
		if( !isNull( getTimeServer() ) ) { config[ 'timeserver' ] = getTimeServer(); }
		if( !isNull( getThisTimeZone() ) ) { config[ 'timezone' ] = getThisTimeZone(); }
		if( !isNull( getUseTimeServer() ) ) { config[ 'use-timeserver' ] = getUseTimeServer(); }

		if( !regionalSearch.len() ) {
			thisConfig.XMLRoot.XMLChildren.append( regional );
		}
	}

	private function writeDatasources( thisConfig ) {
		var passwordManager = getLuceePasswordManager();

		var datasources = xmlSearch( thisConfig, '/cfLuceeConfiguration/data-sources' )[ 1 ];
		var config = datasources.XMLAttributes;
		if( !isNull( getDatasourcePreserveSingleQuotes() ) ) { config[ 'psq' ] = getDatasourcePreserveSingleQuotes(); }

		// Only save datasource list if we have some defined in the incoming config.
		if( isNull( getDatasources() ) ) {
			return;
		}

		datasources.XMLChildren = [];

		for( var DSName in getDatasources() ?: {} ) {
			DSStruct = getDatasources()[ dsName ];
			// Search to see if this datasource already exists
			var DSXMLSearch = xmlSearch( thisConfig, "/cfLuceeConfiguration/data-sources/data-source[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='#lcase( DSName )#']" );
			// DS already exists
			if( DSXMLSearch.len() ) {
				DSXMLNode = DSXMLSearch[ 1 ];
				// Wipe out old attributes for this DS
				structClear( DSXMLNode.XMLAttributes );
			// Create new data-source tag
			} else {
				var DSXMLNode = xmlElemnew(thisConfig,"data-source");
			}

			// Populate XML node
			DSXMLNode.XMLAttributes[ 'name' ] = DSName;
			if( !isNull( DSStruct.database ) ) {
				DSXMLNode.XMLAttributes[ 'database' ] = DSStruct.database;
			}
			DSXMLNode.XMLAttributes[ 'allow' ] = translatePermissionsToBitMask( DSStruct );
			if( !isNull( DSStruct.blob ) ) { DSXMLNode.XMLAttributes[ 'blob' ] = DSStruct.blob; }
			if( !isNull( DSStruct.dbdriver ) ) {
				DSXMLNode.XMLAttributes[ 'class' ] = translateDatasourceClassToLucee( translateDatasourceDriverToLucee( DSStruct.dbdriver ), DSStruct.class ?: '' );
			 }
			if( !isNull( DSStruct.dbdriver ) ) {
				DSXMLNode.XMLAttributes[ 'dbdriver' ] = translateDatasourceDriverToLucee( DSStruct.dbdriver );
			}
			if( !isNull( DSStruct.clob ) ) { DSXMLNode.XMLAttributes[ 'clob' ] = DSStruct.clob; }
			if( !isNull( DSStruct.connectionLimit ) ) { DSXMLNode.XMLAttributes[ 'connectionLimit' ] = DSStruct.connectionLimit; }
			if( !isNull( DSStruct.connectionTimeout ) ) { DSXMLNode.XMLAttributes[ 'connectionTimeout' ] = DSStruct.connectionTimeout; }

			// Always set custom, defaulting if neccessary
			DSXMLNode.XMLAttributes[ 'custom' ] = buildDatasourceCustom( DSStruct.dbdriver, DSStruct.custom ?: '', DSStruct );

			if( !isNull( DSStruct.dbdriver ) ) {
				DSXMLNode.XMLAttributes[ 'dsn' ] = translateDatasourceURLToLucee( translateDatasourceDriverToLucee( DSStruct.dbdriver ), DSStruct.dsn ?: '' );
			}

			// Encrypt password again as we write it.
			if( !isNull( DSStruct.password ) ) { DSXMLNode.XMLAttributes[ 'password' ] = 'encrypted:' & passwordManager.encryptDataSource( DSStruct.password ); }
			if( !isNull( DSStruct.host ) ) { DSXMLNode.XMLAttributes[ 'host' ] = DSStruct.host; }
			if( !isNull( DSStruct.metaCacheTimeout ) ) { DSXMLNode.XMLAttributes[ 'metaCacheTimeout' ] = DSStruct.metaCacheTimeout; }
			if( !isNull( DSStruct.port ) ) { DSXMLNode.XMLAttributes[ 'port' ] = DSStruct.port; }
			if( !isNull( DSStruct.storage ) ) { DSXMLNode.XMLAttributes[ 'storage' ] = DSStruct.storage; }
			if( !isNull( DSStruct.username ) ) { DSXMLNode.XMLAttributes[ 'username' ] = DSStruct.username; }
			if( !isNull( DSStruct.validate ) ) { DSXMLNode.XMLAttributes[ 'validate' ] = DSStruct.validate; }
			if( !isNull( DSStruct.requestExclusive ) ) { DSXMLNode.XMLAttributes[ 'request-exclusive' ] = DSStruct.requestExclusive; }
			
			// Insert into doc if this was new.
			if( !DSXMLSearch.len() ) {
				datasources.XMLChildren.append( DSXMLNode );
			}
		}
	}

	private function writeApplication( thisConfig ) {
		// TODO: Add tag if it doesn't exist
		var thisApplication = xmlSearch( thisConfig, '/cfLuceeConfiguration/application' )[ 1 ];
		var config = thisApplication.XMLAttributes;

		if( !isNull( getRequestTimeout() ) ) { config[ 'requesttimeout' ] = getRequestTimeout(); }
		if( !isNull( getRequestTimeoutInURL() ) ) { config[ 'allow-url-requesttimeout' ] = getRequestTimeoutInURL(); }
		if( !isNull( getScriptProtect() ) ) { config[ 'script-protect' ] = getScriptProtect(); }
		if( !isNull( getApplicationListener() ) ) { config[ 'listener-type' ] = getApplicationListener(); }
		// Swap Adobe-only setting of 'curr2driveroot' with 'curr2root'
		if( !isNull( getApplicationMode() ) ) { config[ 'listener-mode' ] = ( getApplicationMode() == 'curr2driveroot' ? 'curr2root' : getApplicationMode() ); }
		if( !isNull( getUDFTypeChecking() ) ) { config[ 'type-checking' ] = getUDFTypeChecking(); }
	}

	private function writeScope( thisConfig ) {
		// TODO: Add tag if it doesn't exist
		var scope = xmlSearch( thisConfig, '/cfLuceeConfiguration/scope' )[ 1 ];
		var config = scope.XMLAttributes;

		if( !isNull( getApplicationTimeout() ) ) { config[ 'applicationtimeout' ] = getApplicationTimeout(); }
		if( !isNull( getSearchResultsets() ) ) { config[ 'cascade-to-resultset' ] = getSearchResultsets(); }
		if( !isNull( getScopeCascading() ) ) { config[ 'cascading' ] = getScopeCascading(); }
		if( !isNull( getClientTimeout() ) ) { config[ 'clienttimeout' ] = getClientTimeout(); }
		if( !isNull( getClientManagement() ) ) { config[ 'clientmanagement' ] = getClientManagement(); }
		if( !isNull( getMergeURLAndForm() ) ) { config[ 'merge-url-form' ] = getMergeURLAndForm(); }
		if( !isNull( getCGIReadOnly() ) ) { config[ 'cgi-readonly' ] = getCGIReadOnly(); }
		if( !isNull( getSessionManagement() ) ) { config[ 'sessionmanagement' ] = getSessionManagement(); }
		if( !isNull( getSessionTimeout() ) ) { config[ 'sessiontimeout' ] = getSessionTimeout(); }
		if( !isNull( getClientCookies() ) ) { config[ 'setclientcookies' ] = getClientCookies(); }
		if( !isNull( getDomainCookies() ) ) { config[ 'setdomaincookie' ] = getDomainCookies(); }
		if( !isNull( getSessionStorage() ) ) {config[ 'sessionstorage' ] = getSessionStorage(); }
		if( !isNull( getClientStorage() ) ) {
			var thisClientStorage = getClientStorage();

			// This Adobe value isn't valid on Lucee, so swap to memory instead
			if( thisClientStorage == 'registry' ) {
				thisClientStorage = 'memory';
			}
			config[ 'clientStorage' ] = thisClientStorage;
		}
		if( !isNull( getLocalScopeMode() ) ) { config[ 'local-mode' ] = getLocalScopeMode(); }
		if( !isNull( getSessionType() ) ) { config[ 'session-type' ] = getSessionType(); }
		structDelete( config, 'client-max-age' );
		structDelete( config, 'requesttimeout' );

	}

	private function writeMail( thisConfig ) {

		// Only save if we have something defined
		if( isNull( getMailServers() ) ) {
			return;
		}

		var passwordManager = getLuceePasswordManager();
		// Get all mail servers
		// TODO: Add tag if it doesn't exist
		var mailServers = xmlSearch( thisConfig, '/cfLuceeConfiguration/mail' )[ 1 ];
		mailServers.XMLChildren = [];

		for( var mailServer in getMailServers() ?: [] ) {
			// Search to see if this datasource already exists
			var mailServerXMLSearch = xmlSearch( thisConfig, "/cfLuceeConfiguration/mail/server[translate(@smtp,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='#lcase( mailServer.smtp )#']" );
			// mail server already exists
			if( mailServerXMLSearch.len() ) {
				mailServerXMLNode = mailServerXMLSearch[ 1 ];
				// Wipe out old attributes for this mail server
				structClear( mailServerXMLNode.XMLAttributes );
			// Create new data-source tag
			} else {
				var mailServerXMLNode = xmlElemnew(thisConfig,"server");
			}

			// Populate XML node
			if( !isNull( mailServer.idleTimeout ) ) { mailServerXMLNode.XMLAttributes[ 'idle' ] = mailServer.idleTimeout; }
			if( !isNull( mailServer.lifeTimeout ) ) { mailServerXMLNode.XMLAttributes[ 'life' ] = mailServer.lifeTimeout; }
			if( !isNull( mailServer.port ) ) { mailServerXMLNode.XMLAttributes[ 'port' ] = mailServer.port; }
			if( !isNull( mailServer.smtp ) ) { mailServerXMLNode.XMLAttributes[ 'smtp' ] = mailServer.smtp; }
			if( !isNull( mailServer.ssl ) ) { mailServerXMLNode.XMLAttributes[ 'ssl' ] = mailServer.ssl; }
			if( !isNull( mailServer.tls ) ) { mailServerXMLNode.XMLAttributes[ 'tls' ] = mailServer.tls; }
			if( !isNull( mailServer.username ) ) { mailServerXMLNode.XMLAttributes[ 'username' ] = mailServer.username; }
			// Encrypt password again as we write it.
			if( !isNull( mailServer.password ) ) { mailServerXMLNode.XMLAttributes[ 'password' ] = 'encrypted:' & passwordManager.encryptDataSource( mailServer.password ); }

			// Insert into doc if this was new.
			if( !mailServerXMLSearch.len() ) {
				mailServers.XMLChildren.append( mailServerXMLNode );
			}
		}
	}

	private function writeMappings( thisConfig ) {

		// Only save if we have something defined
		if( isNull( getCFmappings() ) ) {
			return;
		}
		var ignores = [ '/lucee-server/' , '/lucee/', '/lucee/doc', '/lucee/admin' ];
		// Get all mappings
		// TODO: Add tag if it doesn't exist
		var mappings = xmlSearch( thisConfig, '/cfLuceeConfiguration/mappings' )[ 1 ].XMLChildren;
		var i = 0;
		while( ++i<= mappings.len() ) {
			var thisMapping = mappings[ i ];
			if( !ignores.findNoCase( thisMapping.XMLAttributes.virtual ) ) {
				arrayDeleteAt( mappings, i );
				i--;
			}
		}

		for( var virtual in getCFmappings() ?: {} ) {
			var mappingStruct = getCFmappings()[ virtual ];
			// Search to see if this datasource already exists
			var mappingXMLSearch = xmlSearch( thisConfig, "/cfLuceeConfiguration/mappings/mapping[translate(@virtual,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='#lcase( virtual )#']" );
			// mapping already exists
			if( mappingXMLSearch.len() ) {
				mappingXMLNode = mappingXMLSearch[ 1 ];
				// Wipe out old attributes for this mapping
				structClear( mappingXMLNode.XMLAttributes );
			// Create new data-source tag
			} else {
				var mappingXMLNode = xmlElemnew(thisConfig,"mapping");
			}

			// Populate XML node
			mappingXMLNode.XMLAttributes[ 'virtual' ] = virtual;
			if( !isNull( mappingStruct.physical ) ) { mappingXMLNode.XMLAttributes[ 'physical' ] = mappingStruct.physical; }
			if( !isNull( mappingStruct.archive ) ) { mappingXMLNode.XMLAttributes[ 'archive' ] = mappingStruct.archive; }
			if( !isNull( mappingStruct.inspectTemplate ) ) { mappingXMLNode.XMLAttributes[ 'inspectTemplate' ] = mappingStruct.inspectTemplate; }
			if( !isNull( mappingStruct.listenerMode ) ) { mappingXMLNode.XMLAttributes[ 'listenerMode' ] = mappingStruct.listenerMode; }
			if( !isNull( mappingStruct.listenerType ) ) { mappingXMLNode.XMLAttributes[ 'listenerType' ] = mappingStruct.listenerType; }
			if( !isNull( mappingStruct.primary ) ) { mappingXMLNode.XMLAttributes[ 'primary' ] = mappingStruct.primary; }
			if( !isNull( mappingStruct.readOnly ) ) { mappingXMLNode.XMLAttributes[ 'readOnly' ] = mappingStruct.readOnly; }

			// Insert into doc if this was new.
			if( !mappingXMLSearch.len() ) {
				mappings.append( mappingXMLNode );
			}
		}
	}

	private function writeCustomTags( thisConfig ) {

		// Only save if we have something defined
		if( isNull( getCustomTagPaths() ) ) {
			return;
		}
		// Get all custom tag paths
		// TODO: Add tag if it doesn't exist
		var customTagPaths = xmlSearch( thisConfig, '/cfLuceeConfiguration/custom-tag' )[ 1 ].XMLChildren;
		var i = 0;
		// Clear the deck
		while( ++i<= customTagPaths.len() ) {
			if ( isNull( customTagPaths.XMLAttributes[ 'virtual ']) ) {
				// First one is lucee's reserved, trusted Custom Tag Path
				continue;
			}
			arrayDeleteAt( customTagPaths, i );
			i--;
		}

		for( var customTagPath in getCustomTagPaths() ?: [] ) {
			// We already cleared the deck so the Custom Tag Paths probably won't exist
			// But Just in Case
			var mappingXMLNode = "";
			var found = false;
			var cmpKey1 = _getCustomTagPathKey( argumentCollection = customTagPath );
			for( var j = 1; j < ArrayLen( customTagPaths ); j++ ) {
				var params = structNew().append( customTagPaths[ j ].XMLAttributes );
				if( isNull( params.virtual ) ) {
					// The first, reserved key doesn't have a virtual tag, skip it
					continue;
				}
				var cmpKey2 = _getCustomTagPathKey( argumentCollection = params );
				// You should really be precise in the case of your paths, even if you're on a
				// case insensitive filesystem.
				if( Compare( cmpKey1, cmpKey2 ) EQ 0 ) {
					mappingXMLNode = customTagPaths[ j ];
					structClear( mappingXMLNode.XMLAttributes );
					found = true;
					break;
				}
			}
			if( !found ) {
				// "mapping" is not a typo - Lucee puts "mapping" tags in the custom-tag parent.
				var mappingXMLNode = XMLElemNew( thisConfig, "mapping" );
			}

			// Populate XML node
			var virtual = "";
			if( !isNull( customTagPath.name )) {
				virtual = "/" & customTagPath.name;
			} else {
				virtual = "/" & Replace( CreateUUID(), "-", "", "all" );
			}
			mappingXMLNode.XMLAttributes[ 'virtual' ] = virtual;
			if( !isNull( customTagPath.physical ) ) { mappingXMLNode.XMLAttributes[ 'physical' ] = customTagPath.physical; }
			if( !isNull( customTagPath.archive ) ) { mappingXMLNode.XMLAttributes[ 'archive' ] = customTagPath.archive; }
			if( !isNull( customTagPath.inspectTemplate ) ) { mappingXMLNode.XMLAttributes[ 'inspectTemplate' ] = customTagPath.inspectTemplate; }
			if( !isNull( customTagPath.primary ) ) { mappingXMLNode.XMLAttributes[ 'primary' ] = customTagPath.primary; }
			if( !isNull( customTagPath.trusted ) ) { mappingXMLNode.XMLAttributes[ 'trusted' ] = customTagPath.trusted ? "yes" : "no"; }

			// Insert into doc if this was new.
			if( !found ) {
				customTagPaths.append( mappingXMLNode );
			}
		}
	}

	private function writeDebugging( thisConfig ) {

		// TODO: Add tag if it doesn't exist
		var scope = xmlSearch( thisConfig, '/cfLuceeConfiguration/debugging' )[ 1 ];
		var config = scope.XMLAttributes;

		if( !isNull( getDebuggingEnabled() ) ) { config[ 'debug' ] = getDebuggingEnabled(); }
		if( !isNull( getDebuggingDBEnabled() ) ) { config[ 'database' ] = getDebuggingDBEnabled(); }
		if( !isNull( getDebuggingExceptionsEnabled() ) ) { config[ 'exception' ] = getDebuggingExceptionsEnabled(); }
		if( !isNull( getDebuggingQueryUsageEnabled() ) ) { config[ 'query-usage' ] = getDebuggingQueryUsageEnabled(); }
		if( !isNull( getDebuggingTracingEnabled() ) ) { config[ 'tracing' ] = getDebuggingTracingEnabled(); }
		if( !isNull( getDebuggingDumpEnabled() ) ) { config[ 'dump' ] = getDebuggingDumpEnabled(); }
		if( !isNull( getDebuggingTimerEnabled() ) ) { config[ 'timer' ] = getDebuggingTimerEnabled(); }
		if( !isNull( getDebuggingImplicitVariableAccessEnabled() ) ) { config[ 'implicit-access' ] = getDebuggingImplicitVariableAccessEnabled(); }
		if( !isNull( getDebuggingMaxLoggedRequests() ) ) { config[ 'max-records-logged' ] = getDebuggingMaxLoggedRequests(); }

	}

	private function writeConfigChanges( thisConfig ) {
		var config = thisConfig.XMLRoot.XMLAttributes;

		if( !isNull( getWatchConfigFilesForChangesEnabled() ) ) { config[ 'check-for-changes' ] = getWatchConfigFilesForChangesEnabled(); }
		// Lucee doesn't support watchConfigFilesForChangesInterval or watchConfigFilesForChangesExtensions

	}

	private function writeCache( thisConfig ) {

		// Only save if we have something defined
		if( isNull( getCaches() ) ) {
			return;
		}
		// Get all caches connections
		var cacheConnectionsSearch = xmlSearch( thisConfig, '/cfLuceeConfiguration/cache' );
		if( cacheConnectionsSearch.len() ) {
			var cacheConnections = cacheConnectionsSearch[ 1 ];
		} else {
			var cacheConnections = xmlElemnew( thisConfig, "cache" );
		}
		cacheConnections.XMLChildren = [];

		if( !isNull( getCacheDefaultObject() ) ) { cacheConnections.XMLAttributes[ 'default-object' ] = getCacheDefaultObject(); }
		if( !isNull( getCacheDefaultFunction() ) ) { cacheConnections.XMLAttributes[ 'default-function' ] = getCacheDefaultFunction(); }
		if( !isNull( getCacheDefaultTemplate() ) ) { cacheConnections.XMLAttributes[ 'default-template' ] = getCacheDefaultTemplate(); }
		if( !isNull( getCacheDefaultQuery() ) ) { cacheConnections.XMLAttributes[ 'default-query' ] = getCacheDefaultQuery(); }
		if( !isNull( getCacheDefaultResource() ) ) { cacheConnections.XMLAttributes[ 'default-resource' ] = getCacheDefaultResource(); }
		if( !isNull( getCacheDefaultInclude() ) ) { cacheConnections.XMLAttributes[ 'default-include' ] = getCacheDefaultInclude(); }
		// Only found/used in Lucee 5
		if( !isNull( getCacheDefaultFile() ) ) { cacheConnections.XMLAttributes[ 'default-file' ] = getCacheDefaultFile(); }
		if( !isNull( getCacheDefaultHTTP() ) ) { cacheConnections.XMLAttributes[ 'default-http' ] = getCacheDefaultHTTP(); }
		if( !isNull( getCacheDefaultWebservice() ) ) { cacheConnections.XMLAttributes[ 'default-webservice' ] = getCacheDefaultWebservice(); }

		var thisCaches = getCaches() ?: {};
		for( var cacheName in thisCaches ) {
			var cacheConnection = thisCaches[ cacheName ];
			// Search to see if this datasource already exists
			var cacheConnectionXMLSearch = xmlSearch( thisConfig, "/cfLuceeConfiguration/cache/connection[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='#lcase( cacheName )#']" );
			// mail server already exists
			if( cacheConnectionXMLSearch.len() ) {
				cacheConnectionXMLNode = cacheConnectionXMLSearch[ 1 ];
				// Wipe out old attributes for this cache connection
				structClear( cacheConnectionXMLNode.XMLAttributes );
			// Create new data-source tag
			} else {
				var cacheConnectionXMLNode = xmlElemnew( thisConfig, "connection" );
			}

			// Populate XML node
			cacheConnectionXMLNode.XMLAttributes[ 'name' ] = cacheName;

			if( !isNull( cacheConnection.class ) ) {
				cacheConnectionXMLNode.XMLAttributes[ 'class' ] = cacheConnection.class;
			// If there's no class and we have a type that looks familiar, create the class for them
			} else if( !isNull( cacheConnection.type ) && translateCacheTypeToClass( cacheConnection.type ).len()  ) {
				cacheConnectionXMLNode.XMLAttributes[ 'class' ] = translateCacheTypeToClass( cacheConnection.type );
			}

			if( !isNull( cacheConnection.storage ) ) { cacheConnectionXMLNode.XMLAttributes[ 'storage' ] = cacheConnection.storage; }
			if( !isNull( cacheConnection.readOnly ) ) { cacheConnectionXMLNode.XMLAttributes[ 'read-only' ] = cacheConnection.readOnly; }
			if( !isNull( cacheConnection.custom ) && isStruct( cacheConnection.custom ) ) {
				var customAsString = '';
				// turn { foo : 'bar', baz : 'bum' } into foo=bar&baz=bum
				for( var key in cacheConnection.custom ) {
					customAsString = customAsString.listAppend( '#URLEncode( key )#=#URLEncode( cacheConnection.custom[ key ] )#', '&' );
				}
				cacheConnectionXMLNode.XMLAttributes[ 'custom' ] = customAsString;
			}

			// Insert into doc if this was new.
			if( !cacheConnectionXMLSearch.len() ) {
				cacheConnections.XMLChildren.append( cacheConnectionXMLNode );
			}
		}

		// Insert into doc if this was new.
		if( !cacheConnectionsSearch.len() ) {
			thisConfig.XMLRoot.XMLChildren.append( cacheConnections );
		}

	}

	private function writeAuth( thisConfig ) {
		// See comments in BaseConfig properties for details
		var config = thisConfig.XMLRoot.XMLAttributes;
		var passwordManager = getLuceePasswordManager();

		// We have plain text password and a salt
		if( !isNull( getAdminPassword() ) && !isNull( getAdminSalt() ) ) {
			config[ 'hspw' ] = passwordManager.hashAdministrator( getAdminPassword(), getAdminSalt() );
			structDelete( config, 'pw' );
			structDelete( config, 'password' );
		// Plain text password and salt from XML
		} else if( !isNull( getAdminPassword() ) && !isNull( config[ 'salt' ] ) ) {
			config[ 'hspw' ] = passwordManager.hashAdministrator( getAdminPassword(), config[ 'salt' ] );
			structDelete( config, 'pw' );
			structDelete( config, 'password' );
		// Plain text password and no salt
		} else if( !isNull( getAdminPassword() ) ) {
			config[ 'pw' ] = passwordManager.hashAdministrator( getAdminPassword() );
			structDelete( config, 'hspw' );
			structDelete( config, 'password' );
		// pre-salted hashed password
		} else if( !isNull( getHspw() ) ) {
			config[ 'hspw' ] = getHspw();
			structDelete( config, 'pw' );
			structDelete( config, 'password' );
		// unslated, hashed password
		} else if( !isNull( getPw() ) ) {
			config[ 'pw' ] = getPw();
			structDelete( config, 'hspw' );
			structDelete( config, 'password' );
		}

		// We have plain text default password and a salt
		if( !isNull( getAdminPasswordDefault() ) && !isNull( getAdminSalt() ) ) {
			config[ 'default-hspw' ] = passwordManager.hashAdministrator( getAdminPasswordDefault(), getAdminSalt() );
			structDelete( config, 'default-pw' );
			structDelete( config, 'default-password' );
		// Plain text default password and salt from XML
		} else if( !isNull( getAdminPasswordDefault() ) && !isNull( config[ 'salt' ] ) ) {
			config[ 'default-hspw' ] = passwordManager.hashAdministrator( getAdminPasswordDefault(), config[ 'salt' ] );
			structDelete( config, 'default-pw' );
			structDelete( config, 'default-password' );
		// Plain text default password and no salt
		} else if( !isNull( getAdminPasswordDefault() ) ) {
			config[ 'default-pw' ] = passwordManager.hashAdministrator( getAdminPasswordDefault() );
			structDelete( config, 'default-hspw' );
			structDelete( config, 'default-password' );
		// pre-salted hashed default password
		} else if( !isNull( getDefaultHspw() ) ) {
			config[ 'default-hspw' ] = getDefaultHspw();
			structDelete( config, 'default-pw' );
			structDelete( config, 'default-password' );
		// unslated, hashed default password
		} else if( !isNull( getDefaultPw() ) ) {
			config[ 'default-pw' ] = getDefaultPw();
			structDelete( config, 'default-hspw' );
			structDelete( config, 'default-password' );
		}

		if( !isNull( getAdminSalt() ) ) { config[ 'salt' ] = getAdminSalt(); }
	}

	private function writeSetting( thisConfig ) {
		var settingSearch = xmlSearch( thisConfig, '/cfLuceeConfiguration/setting' );
		if( settingSearch.len() ) {
			var setting = settingSearch[1];
		} else {
			var setting = xmlElemnew( thisConfig, 'setting' );
		}

		var config = setting.XMLAttributes;

		if( !isNull( getCompression() ) ) { config[ 'allow-compression' ] = getCompression(); }
		if( !isNull( getWhitespaceManagement() ) ) { config[ 'cfml-writer' ] = translateWhitespaceToLucee( getWhitespaceManagement() ); }
		if( !isNull( getBufferTagBodyOutput() ) ) { config[ 'buffer-output' ] = getBufferTagBodyOutput(); }
		if( !isNull( getSupressContentForCFCRemoting() ) ) { config[ 'suppress-content' ] = getSupressContentForCFCRemoting(); }

		if( !settingSearch.len() ) {
			thisConfig.XMLRoot.XMLChildren.append( setting );
		}
	}

	private function writeLoggers( thisConfig ) {

		// Only save if we have something defined
		if( isNull( getLoggers() ) ) {
			return;
		}
		var loggers = xmlSearch( thisConfig, '/cfLuceeConfiguration/logging' )[ 1 ];

		for( var name in getLoggers() ?: {} ) {
			var loggerStruct = getLoggers()[ name ];
			// Search to see if this logger already exists
			var loggerXMLSearch = xmlSearch( thisConfig, "/cfLuceeConfiguration/logging/logger[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='#lcase( name )#']" );
			// logger already exists
			if( loggerXMLSearch.len() ) {
				loggerXMLNode = loggerXMLSearch[ 1 ];
				// Wipe out old attributes for this logging
				structClear( loggerXMLNode.XMLAttributes );
			// Create new logger tag
			} else {
				var loggerXMLNode = xmlElemnew( thisConfig, "logger" );
			}

			// Populate XML node
			loggerXMLNode.XMLAttributes[ 'name' ] = name;
			for ( var key in [ 'appender', 'appenderClass', 'layout', 'layoutClass', 'level' ] ) {
				if ( !isNull( loggerStruct[ key ] ) ) {
                    // replace() translates {var}Class to {var}-class
					loggerXMLNode.XMLAttributes[ key.replace( 'C', '-c' ) ] = loggerStruct[ key ];
				}
			}
			for ( var key in [ 'appenderArguments', 'layoutArguments' ] ) {
				if ( !isNull( loggerStruct[ key ] ) && isStruct( loggerStruct[ key ] ) ) {
					var args = [ ];
					for ( var argName in loggerStruct[ key ] ) {
						args.append( argName & ':' & loggerStruct[ key ][ argName ] );
					}
                    // replace() translates {var}Arguments to {var}-arguments
					loggerXMLNode.XMLAttributes[ key.replace( 'A', '-a' ) ] = args.toList( ';' );
				}
			}

			// Insert into doc if this was new.
			if( !loggerXMLSearch.len() ) {
				loggers.XMLChildren.append( loggerXMLNode );
			}
		}
	}

	private function writeError( thisConfig ) {
	    var errorSearch = xmlSearch( thisConfig, '/cfLuceeConfiguration/error' );
	    if( errorSearch.len() ) {
	    	var error = errorSearch[1];
	    } else {
	    	var error = xmlElemnew( thisConfig, 'error' );
	    }

	    var config = error.XMLAttributes;

	    if( !isNull( getErrorStatusCode() ) ) { config[ 'status-code' ] = getErrorStatusCode(); }
	    if( !isNull( getMissingErrorTemplate() ) ) { config[ 'template-404' ] = translateSharedErrorTemplateToLucee( getMissingErrorTemplate() ); }
	    if( !isNull( getGeneralErrorTemplate() ) ) { config[ 'template-500' ] = translateSharedErrorTemplateToLucee( getGeneralErrorTemplate() ); }

	    if( !errorSearch.len() ) {
	    	thisConfig.XMLRoot.XMLChildren.append( error );
	    }
	}

	private function writeSystem( thisConfig ) {
		var systemSearch = xmlSearch( thisConfig, '/cfLuceeConfiguration/system' );
		if( systemSearch.len() ) {
			var system = systemSearch[1];
		} else {
			var system = xmlElemnew( thisConfig, 'system' );
		}

		if( !isNull( getSystemOut() ) ) { system.XMLAttributes[ 'out' ] = getSystemOut(); }
		if( !isNull( getSystemErr() ) ) { system.XMLAttributes[ 'err' ] = getSystemErr(); }

		if( !systemSearch.len() ) {
			thisConfig.XMLRoot.XMLChildren.append( system );
		}
	}

	/**
	* I find the actual Lucee 4.x context config file
	*/
	function locateConfigFile(){
		var thisCFHomePath = getCFHomePath();
		var thisConfigFileName = getConfigFileName();

		// If the path ends with the same extension as the config file name, just use it
		if( right( thisCFHomePath, 4 ) == right( thisConfigFileName, 4 ) ) {
			return thisCFHomePath;
		}

		// This is where the file _should_ be.
		return thisCFHomePath & getConfigRelativePathWithinServerHome() & thisConfigFileName;
	}

	private function translateDatasourceDriverToLucee( required string driverName ) {

		if( listFindNoCase( 'MSSQL,PostgreSQL,Oracle,MySQL,DB2Firebird,H2,H2Server,HSQLDB,ODBC,Sybase', arguments.driverName ) ) {
			return arguments.driverName;
		} else if (arguments.driverName == 'MSSQL2') {
			return 'JTDS';
		} else {
			// Adobe stores arbitrary text here
			return 'Other';
		}

	}

	private function translateDatasourceClassToLucee( required string driverName, required string className ) {

		switch( driverName ) {
			case 'MSSQL' :
				return 'com.microsoft.jdbc.sqlserver.SQLServerDriver';
			case 'JTDS' :
				return 'net.sourceforge.jtds.jdbc.Driver';
			case 'Oracle' :
				return 'oracle.jdbc.driver.OracleDriver';
			case 'MySQL' :
				// If one of the known Lucee MySQL class names are in use, stick with it
				if( listFindNoCase( 'com.mysql.jdbc.Driver,org.gjt.mm.mysql.Driver', className ) ) {
					return className;
				}
				// If the class name wasn't recognized, default to this one.
				// This assumes an earlier version of the MySQL JDBC extension
				// But have I no way to know what the user will have installed.
				return 'com.mysql.jdbc.Driver';
			case 'H2' :
				return 'org.h2.Driver';
			default :
				return arguments.className;
		}

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

	private function translateDatasourceURLToLucee( required string driverName, required string JDBCUrl ) {

		switch( driverName ) {
			case 'MySQL' :
				return 'jdbc:mysql://{host}:{port}/{database}';
			case 'Oracle' :
				return 'jdbc:oracle:{drivertype}:@{host}:{port}:{database}';
			case 'PostgreSql' :
				return 'jdbc:postgresql://{host}:{port}/{database}';
			case 'MSSQL' :
				return 'jdbc:sqlserver://{host}:{port}';
			case 'JTDS' :
				return 'jdbc:jtds:sqlserver://{host}:{port}/{database}';
			case 'H2' :
				return 'jdbc:h2:{path}{database};MODE={mode}';
			default :
				return arguments.JDBCUrl;
		}

	}

	private struct function datasourceCustomToStruct( required string custom) {
		var thisCustom = decodeForHTML( arguments.custom );
		var thisStruct = {};
		for( var item in thisCustom.listToArray( '&' ) ) {
			// Turn foo=bar&baz=bum&poof= into { foo : 'bar', baz : 'bum', poof : '' }
			// Any "=" or "&" in the key values will be URL encoded.
			thisStruct[ URLDecode( listFirst( item, '=' ) ) ] = ( listLen( item, '=' ) ?  URLDecode( listRest( item, '=' ) ) : '' );
		}

		return thisStruct;
	}

	private string function buildDatasourceCustom( required string driverName, required string custom, required struct datasourceData ) {
		// first deconstruct the custom sting into a struct
		var customStruct = datasourceCustomToStruct( arguments.custom );

		// update and add values to the custom struct
		switch( driverName ) {
			case 'MySQL' :
				// TODO: make these actually dynamic and stored!
				customStruct['useUnicode']=true;
				customStruct['characterEncoding']='UTF8';
				customStruct['useLegacyDatetimeCode']=true;
				break;
			case 'Oracle' :
				// TODO: make this actually dynamic and stored!
				customStruct['drivertype']='thin';
				break;
			case 'PostgreSql' :
				break;
			case 'MSSQL' :
				// Add in datasource if it's there
				if( !isNull( datasourceData.database ) && datasourceData.database.len() ) {
					customStruct['DATABASENAME']=datasourceData.database;
				}
				if( !isNull( datasourceData.sendStringParametersAsUnicode ) ) {
					// set specified value
					customStruct['sendStringParametersAsUnicode']=datasourceData.sendStringParametersAsUnicode;
				} else {
					// set default value
					customStruct['sendStringParametersAsUnicode']=false;
				}
				customStruct['SelectMethod']='direct';
				break;
			default :
				// do nothing
		}

		// reconstruct the custom string
		var returnString='';
		for (var key in customStruct) {
			returnString=listAppend(returnString, key & "=" & customStruct[key], "&");
		}

		return returnString;
	}

	private function translateSharedErrorTemplateToLucee( required string templateName ) {

		switch( templateName ) {
			case 'default' :
				return '/lucee/templates/error/error.cfm';
			case 'secure' :
				return '/lucee/templates/error/error-public.cfm';
			case 'neo' :
				return '/lucee/templates/error/error-neo.cfm';
			default :
				return arguments.templateName;
		}

	}

	private function translateLuceeToSharedErrorTemplate( required string templateName ) {

		switch( templateName ) {
			case '/lucee/templates/error/error.cfm' :
				return 'default';
			case '/lucee/templates/error/error-public.cfm' :
				return 'secure';
			case '/lucee/templates/error/error-neo.cfm' :
				return 'neo';
			default :
				return arguments.templateName;
		}

	}

	/**
	* 0 Select 1
	* 1 delete 2
	* 2 update 4
	* 3 insert 8
	* 4 create 16
	* 5 grant 32
	* 6 revoke 64
	* 7 drop 128
	* 8 alter 256
	* 9 Stored procs 512
	*/
	private function translatePermissionsToBitMask( required struct ds ) {
		var bitMask = 0;

	    if( ds.allowSelect ?: true ) { bitMask = bitMaskSet( bitMask, 1, 0, 1 ); }
	    if( ds.allowDelete ?: true ) { bitMask = bitMaskSet( bitMask, 1, 1, 1 ); }
	    if( ds.allowUpdate ?: true ) { bitMask = bitMaskSet( bitMask, 1, 2, 1 ); }
	    if( ds.allowInsert ?: true ) { bitMask = bitMaskSet( bitMask, 1, 3, 1 ); }
	    if( ds.allowCreate ?: true ) { bitMask = bitMaskSet( bitMask, 1, 4, 1 ); }
	    if( ds.allowGrant ?: true ) { bitMask = bitMaskSet( bitMask, 1, 5, 1 ); }
	    if( ds.allowRevoke ?: true ) { bitMask = bitMaskSet( bitMask, 1, 6, 1 ); }
	    if( ds.allowDrop ?: true ) { bitMask = bitMaskSet( bitMask, 1, 7, 1 ); }
	    if( ds.allowAlter ?: true ) { bitMask = bitMaskSet( bitMask, 1, 8, 1 ); }
	    // Lucee doesn't support stored proc
	    // if( ds.allowStoredproc ?: true ) { bitMask = bitMaskSet( bitMask, 1, 9, 1 ); }

	    return bitMask;
	}

	private function translateBitMaskToPermissions( required bitMask ) {
		// Defaulting to true and then turning off in case a datasource doesn't have anything stored for
		// "allow", this will give the default behavior.
		var ds = {
			'allowSelect' = true,
		    'allowDelete' = true,
		    'allowUpdate' = true,
		    'allowInsert' = true,
		    'allowCreate' = true,
		    'allowGrant' = true,
		    'allowRevoke' = true,
		    'allowDrop' = true,
		    'allowAlter' = true,
		    'allowStoredproc' = true
		  };

		// If there's no setting, just assume it's all "on".
		if( bitMask == '' ) {
			return ds;
		}

		if( !bitMaskRead( bitMask, 0, 1 ) ) { ds.allowSelect = false; }
	    if( !bitMaskRead( bitMask, 1, 1 ) ) { ds.allowDelete = false; }
	    if( !bitMaskRead( bitMask, 2, 1 ) ) { ds.allowUpdate = false; }
	    if( !bitMaskRead( bitMask, 3, 1 ) ) { ds.allowInsert = false; }
	    if( !bitMaskRead( bitMask, 4, 1 ) ) { ds.allowCreate = false; }
	    if( !bitMaskRead( bitMask, 5, 1 ) ) { ds.allowGrant = false; }
	    if( !bitMaskRead( bitMask, 6, 1 ) ) { ds.allowRevoke = false; }
	    if( !bitMaskRead( bitMask, 7, 1 ) ) { ds.allowDrop = false; }
	    if( !bitMaskRead( bitMask, 8, 1 ) ) { ds.allowAlter = false; }
	    // Lucee doesn't support stored proc
	    // if( !bitMaskRead( bitMask, 9, 1 ) ) { ds.allowStoredproc = false; }

	    return ds;
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

}
