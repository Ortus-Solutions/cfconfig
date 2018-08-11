
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
		
		setRuntimeConfigTemplate( expandPath( '/cfconfig-services/resources/adobe10/neo-runtime.xml' ) );		
		setClientStoreConfigTemplate( expandPath( '/cfconfig-services/resources/adobe10/neo-clientstore.xml' ) );		
		setWatchConfigTemplate( expandPath( '/cfconfig-services/resources/adobe10/neo-watch.xml' ) );		
		setMailConfigTemplate( expandPath( '/cfconfig-services/resources/adobe10/neo-mail.xml' ) );		
		setDatasourceConfigTemplate( expandPath( '/cfconfig-services/resources/adobe10/neo-datasource.xml' ) );
		setSecurityConfigTemplate( expandPath( '/cfconfig-services/resources/adobe10/neo-security.xml' ) );
		setDebugConfigTemplate( expandPath( '/cfconfig-services/resources/adobe10/neo-debug.xml' ) );
		setSchedulerConfigTemplate( expandPath( '/cfconfig-services/resources/adobe10/neo-cron.xml' ) );
		setEventGatewayConfigTemplate( expandPath( '/cfconfig-services/resources/adobe10/neo-event.xml' ) );
		setWebsocketConfigTemplate( expandPath( '/cfconfig-services/resources/adobe10/neo-websocket.xml' ) );
		setSeedPropertiesPath( '/lib/seed.properties' );
		setLicensePropertiesTemplate( expandPath( '/cfconfig-services/resources/adobe10/license.properties' ) );
		setJettyConfigTemplate( expandPath( '/cfconfig-services/resources/adobe10/jetty.xml' ) );
		setDotNetConfigTemplate( expandPath( '/cfconfig-services/resources/adobe10/neo-dotnet.xml' ) );
		setVersion( '10' );
		
		return this;
	}

	
	private function writeSecurity() {
		
		// CF10 expects secureprofile.enabled to be a STRING!
		if( !isNull( getSecureProfileEnabled() ) ) {
						
			// Back up and remove the setting entirely since CF10 doesn't even use it.
			var secureProfileEnabled = getSecureProfileEnabled();
			variables.delete( 'secureProfileEnabled' );
			
			super.writeSecurity();
			
			// Put it back just in case the base config object is used elsewhere
			getSecureProfileEnabled( secureProfileEnabled );
			
		} else {
			super.writeSecurity();			
		}
		
	}
		
}