/**
* I represent the behavior of reading and writing CF engine config in the format compatible with a Lucee 4.x server context
* I extend the BaseConfig class, which represents the data itself.
*/
component accessors=true extends='BaseConfig' {
	
	property name='configFileTemplate' type='string';
	property name='configFileName' type='string';
	property name='luceePasswordManager';
	
	
	/**
	* Constructor
	*/
	function init() {
		// Used when writing out a Lucee server context config file from the generic config
		setConfigFileTemplate( expandPath( '/resources/lucee4/lucee-server-base.xml' ) );
		
		// This is the file name used by this config file
		setConfigFileName( 'lucee-server.xml' );
		setLuceePasswordManager( new LuceePasswordManager() );
		
		super.init();
	}
	
	/**
	* I read in config from a base JSON format
	*
	* @CFHomePath The JSON file to read from
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
		
		readAuth( thisConfig.XMLRoot );
		
		return this;
	}
	
	private function readDatasources( datasources ) {
		for( var ds in datasources.XMLChildren ) {
			var params = {}.append( ds.XMLAttributes );
			addDatasource( argumentCollection = params );
		}
	}

	private function readApplication( thisApplication ) {
		var config = thisApplication.XMLAttributes;
		
		if( !isNull( config.requesttimeout ) ) { setRequestTimeout( config.requesttimeout ) };	
		if( !isNull( config[ 'allow-url-requesttimeout' ] ) ) { setRequestTimeoutInURL( config[ 'allow-url-requesttimeout' ] ) };
		if( !isNull( config[ 'script-protect' ] ) ) { setScriptProtect( config[ 'script-protect' ] ) };
		if( !isNull( config[ 'listener-type' ] ) ) { setApplicationListener( config[ 'listener-type' ] ) };
		if( !isNull( config[ 'listener-mode' ] ) ) { setApplicationMode( config[ 'listener-mode' ] ) };
	}
	
	private function readScope( scope ) {
		var config = scope.XMLAttributes;
		
		if( !isNull( config.applicationtimeout ) ) { setApplicationTimeout( config.applicationtimeout ) };
		if( !isNull( config[ 'cascade-to-resultset' ] ) ) { setSearchResultsets( config[ 'cascade-to-resultset' ] ) };
		if( !isNull( config.cascading ) ) { setScopeCascading( config.cascading ) };
		if( !isNull( config.clienttimeout ) ) { setClientTimeout( config.clienttimeout ) };
		if( !isNull( config[ 'client-max-age' ] ) ) { setClientTimeout( '#config.client-max-age#,0,0,0' ) };
		if( !isNull( config.clientmanagement ) ) { setClientManagement( config.clientmanagement ) };
		if( !isNull( config[ 'merge-url-form' ] ) ) { setMergeURLAndForm( config[ 'merge-url-form' ] ) };
		if( !isNull( config[ 'cgi-readonly' ] ) ) { setCGIReadOnly( config[ 'cgi-readonly' ] ) };
		if( !isNull( config.requesttimeout ) ) { setRequestTimeout( config.requesttimeout ) };
		if( !isNull( config.sessionmanagement ) ) { setSessionMangement( config.sessionmanagement ) };
		if( !isNull( config.sessiontimeout ) ) { setSessionTimeout( config.sessiontimeout ) };
		if( !isNull( config.setclientcookies ) ) { setClientCookies( config.setclientcookies ) };
		if( !isNull( config.setdomaincookie ) ) { setDomainCookies( config.setdomaincookie ) };
		if( !isNull( config.sessionStorage ) ) { setSessionStorage( config.sessionStorage ) };
		if( !isNull( config.clientStorage ) ) { setClientStorage( config.clientStorage ) };
		if( !isNull( config[ 'local-mode' ] ) ) { setLocalScopeMode( config[ 'local-mode' ] ) };
		if( !isNull( config[ 'session-type' ] ) ) { setSessionType( config[ 'session-type' ] ) };
	}
	
	private function readMail( mail ) {
	}
	
	private function readMappings( mappings ) {
		var ignores = [ '/lucee-server/' , '/lucee/' ];
		
		for( var mapping in mappings.XMLChildren ) {
			var params = {}.append( mapping.XMLAttributes );
			
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
		writeApplication( thisConfig );
		writeScope( thisConfig );
		writeMail( thisConfig );
		writeMappings( thisConfig );
		writeCustomTags( thisConfig );
		writeDebugging( thisConfig );
		writeAuth( thisConfig );
		
		// Ensure the parent directories exist
		directoryCreate( path=getDirectoryFromPath( configFilePath ), createPath=true, ignoreExists=true )
		fileWrite( configFilePath, toString( thisConfig ) );
		
		return this;
	}

	
	private function writeDatasources( thisConfig ) {
		// Get all datasources
		// TODO: Add tag if it doesn't exist
		var datasources = xmlSearch( thisConfig, '/cfLuceeConfiguration/data-sources' )[ 1 ];
		
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
			DSXMLNode.XMLAttributes[ 'name' ] = DSName;;
			if( !isNull( DSStruct.database ) ) { DSXMLNode.XMLAttributes[ 'database' ] = DSStruct.database; }
			if( !isNull( DSStruct.allow ) ) { DSXMLNode.XMLAttributes[ 'allow' ] = DSStruct.allow; }
			if( !isNull( DSStruct.blob ) ) { DSXMLNode.XMLAttributes[ 'blob' ] = DSStruct.blob; }
			if( !isNull( DSStruct.class ) ) { DSXMLNode.XMLAttributes[ 'class' ] = DSStruct.class; }
			if( !isNull( DSStruct.dbdriver ) ) { DSXMLNode.XMLAttributes[ 'dbdriver' ] = DSStruct.dbdriver; }
			if( !isNull( DSStruct.clob ) ) { DSXMLNode.XMLAttributes[ 'clob' ] = DSStruct.clob; }
			if( !isNull( DSStruct.connectionLimit ) ) { DSXMLNode.XMLAttributes[ 'connectionLimit' ] = DSStruct.connectionLimit; }
			if( !isNull( DSStruct.connectionTimeout ) ) { DSXMLNode.XMLAttributes[ 'connectionTimeout' ] = DSStruct.connectionTimeout; }
			if( !isNull( DSStruct.custom ) ) { DSXMLNode.XMLAttributes[ 'custom' ] = DSStruct.custom; }
			if( !isNull( DSStruct.dsn ) ) { DSXMLNode.XMLAttributes[ 'dsn' ] = DSStruct.dsn; }
			if( !isNull( DSStruct.password ) ) { DSXMLNode.XMLAttributes[ 'password' ] = DSStruct.password; }
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
		if( !isNull( getRequestTimeout() ) ) { config[ 'allow-url-requesttimeout' ] = getRequestTimeoutInURL(); }
		if( !isNull( getRequestTimeout() ) ) { config[ 'script-protect' ] = getScriptProtect(); }
		if( !isNull( getRequestTimeout() ) ) { config[ 'listener-type' ] = getApplicationListener(); }
		if( !isNull( getRequestTimeout() ) ) { config[ 'listener-mode' ] = getApplicationMode(); }
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
		if( !isNull( getSessionStorage() ) ) { config[ 'sessionStorage' ] = getSessionStorage(); }
		if( !isNull( getClientStorage() ) ) { config[ 'clientStorage' ] = getClientStorage(); }
		if( !isNull( getLocalScopeMode() ) ) { config[ 'local-mode' ] = getLocalScopeMode(); }
		if( !isNull( getSessionType() ) ) { config[ 'session-type' ] = getSessionType(); }
		structDelete( config, 'client-max-age' );
		structDelete( config, 'requesttimeout' );
		
	}
	
	private function writeMail( thisConfig ) {
	}
	
	private function writeMappings( thisConfig ) {
		// Get all mappings
		// TODO: Add tag if it doesn't exist
		var mappings = xmlSearch( thisConfig, '/cfLuceeConfiguration/mappings' )[ 1 ];
		
		for( var virtual in getCFmappings() ?: {} ) {
			mappingStruct = getCFmappings()[ virtual ];
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
				mappings.XMLChildren.append( mappingXMLNode );
			}			
		}
	}
	
	private function writeCustomTags( thisConfig ) {
	}
	
	private function writeDebugging( thisConfig ) {
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
	
	/**
	* I find the actual Lucee 4.x server context config file
	*/
	function locateConfigFile(){
		var thisCFHomePath = getCFHomePath();
		var thisConfigFileName = getConfigFileName();
		
		// If the path ends with .xml, just use it
		if( right( thisCFHomePath, 4 ) == '.xml' ) {
			return thisCFHomePath;
		}
		
		// This is where the file _should_ be.
		return thisCFHomePath & '/context/' & thisConfigFileName;		
	}

}