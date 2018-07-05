
/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
* 
* I represent the behavior of reading and writing CF engine config in the format compatible with an Adobe 10.x server
* I extend the BaseConfig class, which represents the data itself.
*/
component accessors=true extends='cfconfig-services.models.BaseAdobe' {
	
	/**
	* Constructor
	*/
	function init() {		
		super.init();
		
		setRuntimeConfigTemplate( expandPath( '/cfconfig-services/resources/adobe9/neo-runtime.xml' ) );		
		setClientStoreConfigTemplate( expandPath( '/cfconfig-services/resources/adobe9/neo-clientstore.xml' ) );		
		setWatchConfigTemplate( expandPath( '/cfconfig-services/resources/adobe9/neo-watch.xml' ) );		
		setMailConfigTemplate( expandPath( '/cfconfig-services/resources/adobe9/neo-mail.xml' ) );		
		setDatasourceConfigTemplate( expandPath( '/cfconfig-services/resources/adobe9/neo-datasource.xml' ) );
		setSecurityConfigTemplate( expandPath( '/cfconfig-services/resources/adobe9/neo-security.xml' ) );
		setDebugConfigTemplate( expandPath( '/cfconfig-services/resources/adobe9/neo-debug.xml' ) );
		setSchedulerConfigTemplate( expandPath( '/cfconfig-services/resources/adobe9/neo-cron.xml' ) );
		setEventGatewayConfigTemplate( expandPath( '/cfconfig-services/resources/adobe9/neo-event.xml' ) );
		setWebsocketConfigTemplate( expandPath( '/cfconfig-services/resources/adobe9/neo-websocket.xml' ) );
		setSeedPropertiesPath( '/lib/password.properties' );
		setLicensePropertiesTemplate( expandPath( '/cfconfig-services/resources/adobe9/license.properties' ) );
		setJettyConfigTemplate( expandPath( '/cfconfig-services/resources/adobe9/jetty.xml' ) );
		setDotNetConfigTemplate( expandPath( '/cfconfig-services/resources/adobe9/neo-dotnet.xml' ) );
		setVersion( '9' );
		
		return this;
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
		readAuth();
		readLicense();
		readSecurity();
		readDebug();
		readScheduler();
		readEventGateway();
		readScheduler();
		readJetty();
		readDotNet();
			
		return this;
	}

	/**
	* I write out config from a base JSON format
	*
	* @CFHomePath The JSON file to write to
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
		writeSecurity();
		writeDebug();
		writescheduler( pauseTasks );
		writeEventGateway();
		writeJetty();
		writeDotNet();
		
		return this;
	}

	private function readDatasource() {



		
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
				password = getAdobePasswordManager().decryptDataSource(ds.password ),
				port = ds.urlmap.port,
				username = ds.username,
				validate = ds.keyExists("validateConnection")?ds.validateConnection:false,
				SID = ds.urlmap.SID ?: '',
				maintainConnections = ds.pooling ?: false,
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
				custom = ds.urlmap.args ?: ''				
			);
		}
	}
	
	private function writeDatasource() {
		
		if( isNull( getDatasources() ) || !structCount( getDatasources() ) ) {
			return;
		}
		
		var configFilePath = getCFHomePath().listAppend( getDatasourceConfigPath(), '/' );
		
		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getDatasourceConfigTemplate() );
		}
		
		thisConfig[ 1 ] = {};
		
		var datasources = getDatasources();
		
		for( var datasource in datasources ) {
			// For brevity
			var incomingDS = datasources[ datasource ];
			thisConfig[ 1 ][ datasource ] = thisConfig[ 1 ][ datasource ] ?: DSNUtil.getDefaultDatasourceStruct( DSNUtil.translateDatasourceDriverToAdobe( incomingDS.dbdriver ?: 'Other'  ) );
			var savingDS = thisConfig[ 1 ][ datasource ];
			
			savingDS.name = datasource;



			// Only use the incoming JDBC URL if this is a datasource of type other.  This is to prevent a Lucee
			// JDBC URL from getting imported into Adobe.  Instead, the URL will be pulled from  getDefaultDatasourceStruct() above.
			if( ( incomingDS.dbdriver ?: 'Other' ) == 'Other' || !savingDS.url.len() 
					&& incomingDS.keyExists("dsn")) {
					// ^^^ the above has been added to stop most errors but not sure if the whole logic is correct as it is.

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
			}
			// Normalize names
			if( !isNull( incomingDS.dbdriver ) ) { savingDS.driver = DSNUtil.translateDatasourceDriverToAdobe( incomingDS.dbdriver ); }
			if( !isNull( incomingDS.host ) ) {
				savingDS.urlmap.host = incomingDS.host;
				savingDS.urlmap.connectionprops.host = incomingDS.host;
				savingDS.url = savingDS.url.replaceNoCase( '{host}', incomingDS.host );
			}
			if( !isNull( incomingDS.password ) ) { savingDS.password = getAdobePasswordManager().encryptDataSource( incomingDS.password ); }
			if( !isNull( incomingDS.port ) ) {
				savingDS.urlmap.port = incomingDS.port;
				savingDS.urlmap.connectionprops.port = incomingDS.port;
				savingDS.url = savingDS.url.replaceNoCase( '{port}', incomingDS.port );
			}
			if( !isNull( incomingDS.username ) ) { savingDS.username = incomingDS.username; }
			if( !isNull( incomingDS.validate ) ) { savingDS.validateConnection = !!incomingDS.validate; }
			if( !isNull( incomingDS.SID ) ) {
				savingDS.urlmap.SID = incomingDS.SID;
				savingDS.urlmap.connectionprops.SID = incomingDS.SID;
				savingDS.url = savingDS.url.replaceNoCase( '{SID}', incomingDS.SID );
			} else {
				// I think SID may be optional for Oracle, so completely remove if there isn't one.
				// This shouldn't affect other datasources at all
				savingDS.url = savingDS.url.replaceNoCase( 'SID={SID};', '' );				
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
			}
			if( !isNull( incomingDS.connectionTimeoutInterval ) ) { savingDS.interval = incomingDS.connectionTimeoutInterval+0; }
			if( !isNull( incomingDS.queryTimeout ) ) {
				savingDS.urlmap.qTimeout = incomingDS.queryTimeout+0;
				savingDS.urlmap.connectionprops.qTimeout = incomingDS.queryTimeout+0;
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
				savingDS.urlmap.args = incomingDS.custom;
				// Also save to savingDS.urlmap.connectionProps 
				// need to parse values and break out brad=wood as savingDS.urlmap.connectionProps.brad=wood
			}
			
		}
		
		writeWDDXConfigFile( thisConfig, configFilePath );	
	}	
}