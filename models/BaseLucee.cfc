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

		readAuth( thisConfig.XMLRoot );
		
		readConfigChanges( thisConfig.XMLRoot );
		
		return this;
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
		for( var ds in datasources.XMLChildren ) {
			var params = structNew().append( ds.XMLAttributes );
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
		if( !isNull( config.sessionmanagement ) ) { setSessionMangement( config.sessionmanagement ); };
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
	}
	
	private function readDebugging( debugging ) {
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
		if( !isNull( config[ 'cfml-writer' ] ) ) { setWhitespaceManagement( config[ 'cfml-writer' ] ); }
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
			
			// Turn cusom values into struct
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
		
		// Ensure the parent directories exist
		directoryCreate( path=getDirectoryFromPath( configFilePath ), createPath=true, ignoreExists=true );
		fileWrite( configFilePath, toString( thisConfig ) );
		
		return this;
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
		// Get all datasources
		// TODO: Add tag if it doesn't exist
		var datasources = xmlSearch( thisConfig, '/cfLuceeConfiguration/data-sources' )[ 1 ];
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
			if( !isNull( DSStruct.database ) ) { DSXMLNode.XMLAttributes[ 'database' ] = DSStruct.database; }
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
			if( !isNull( DSStruct.custom ) ) { DSXMLNode.XMLAttributes[ 'custom' ] = DSStruct.custom; }
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
		if( !isNull( getSessionMangement() ) ) { config[ 'sessionmanagement' ] = getSessionMangement(); }
		if( !isNull( getSessionTimeout() ) ) { config[ 'sessiontimeout' ] = getSessionTimeout(); }
		if( !isNull( getClientCookies() ) ) { config[ 'setclientcookies' ] = getClientCookies(); }
		if( !isNull( getDomainCookies() ) ) { config[ 'setdomaincookie' ] = getDomainCookies(); }
		if( !isNull( getSessionStorage() ) ) {config[ 'sessionStorage' ] = getSessionStorage(); }
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
	}
	
	private function writeDebugging( thisConfig ) {
	}
	
	private function writeConfigChanges( thisConfig ) {
		var config = thisConfig.XMLRoot.XMLAttributes;
		
		if( !isNull( getWatchConfigFilesForChangesEnabled() ) ) { config[ 'check-for-changes' ] = getWatchConfigFilesForChangesEnabled(); }
		// Lucee doesn't support watchConfigFilesForChangesInterval or watchConfigFilesForChangesExtensions
		
	}
	
	private function writeCache( thisConfig ) {
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
		if( !isNull( getWhitespaceManagement() ) ) { config[ 'cfml-writer' ] = getWhitespaceManagement(); }
		if( !isNull( getBufferTagBodyOutput() ) ) { config[ 'buffer-output' ] = getBufferTagBodyOutput(); }
		if( !isNull( getSupressContentForCFCRemoting() ) ) { config[ 'suppress-content' ] = getSupressContentForCFCRemoting(); }

		if( !settingSearch.len() ) {
			thisConfig.XMLRoot.XMLChildren.append( setting );
		}
	}
	
	private function writeLoggers( thisConfig ) {
		var loggers = xmlSearch( thisConfig, '/cfLuceeConfiguration/logging' )[ 1 ];
		loggers.XMLChildren = [];
		
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
		} else {
			// Adobe stores arbitrary text here
			return 'Other';
		}
		
	}
	
	private function translateDatasourceClassToLucee( required string driverName, required string className ) {
		
		switch( driverName ) {
			case 'MSSQL' :
				return 'com.microsoft.jdbc.sqlserver.SQLServerDriver';
			case 'Oracle' :
				return 'oracle.jdbc.driver.OracleDriver';
			case 'MySQL' :
				return 'org.gjt.mm.mysql.Driver';
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
			case 'H2' :
				return 'jdbc:h2:{path}{database};MODE={mode}';
			default :
				return arguments.JDBCUrl;
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
	
}