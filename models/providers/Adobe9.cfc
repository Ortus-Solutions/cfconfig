
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
		setSeedPropertiesPath( '' );
		setLicensePropertiesTemplate( expandPath( '/cfconfig-services/resources/adobe9/license.properties' ) );
		setJettyConfigTemplate( expandPath( '/cfconfig-services/resources/adobe9/jetty.xml' ) );
		setDotNetConfigTemplate( expandPath( '/cfconfig-services/resources/adobe9/neo-dotnet.xml' ) );
		setLoggingConfigTemplate( expandPath( '/cfconfig-services/resources/adobe9/neo-logging.xml' ) );
		setUpdateConfigTemplate( expandPath( '/cfconfig-services/resources/adobe9/neo_updates.xml' ) );
		
		// CF9 stores this as a boolean whereas CF10+ is a string
		setAdminRDSLoginRequiredBoolean( true );
		
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
		
		// ensureSeedProperties( getCFHomePath().listAppend( getSeedPropertiesPath(), '/' ) );
		
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
	
	
	/**
	* Writes a WDDX file to disk with a CF9 fix in place
	*/
	private function writeWDDXConfigFile( required any data, required string configFilePath ) {

		// Fix to strip out keys CF9 doesn't like
		if( configFilePath.findNoCase( 'neo-datasource.xml' ) ) {
			for( var dsName in data[ 1 ] ) {
				var ds = data[ 1 ][ dsName ];
				// CF9 chokes if these are present
				ds.delete( 'clientInfo' );
				ds.delete( 'validateConnection' );				
			}			
		}
		
		// As you were...
		super.writeWDDXConfigFile( data, configFilePath );
	}
	
}