/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
* 
* I represent the behavior of reading and writing CF engine config in the format compatible with an Adobe 2016.x server
* I extend the BaseConfig class, which represents the data itself.
*/
component accessors=true extends='cfconfig-services.models.BaseAdobe' {
	
	/**
	* Constructor
	*/
	function init() {		
		super.init();
		
		setRuntimeConfigTemplate( expandPath( '/cfconfig-services/resources/adobe2016/neo-runtime.xml' ) );		
		setClientStoreConfigTemplate( expandPath( '/cfconfig-services/resources/adobe2016/neo-clientstore.xml' ) );		
		setWatchConfigTemplate( expandPath( '/cfconfig-services/resources/adobe2016/neo-watch.xml' ) );		
		setMailConfigTemplate( expandPath( '/cfconfig-services/resources/adobe2016/neo-mail.xml' ) );
		setDatasourceConfigTemplate( expandPath( '/cfconfig-services/resources/adobe2016/neo-datasource.xml' ) );
		setSecurityConfigTemplate( expandPath( '/cfconfig-services/resources/adobe2016/neo-security.xml' ) );
		setDebugConfigTemplate( expandPath( '/cfconfig-services/resources/adobe2016/neo-debug.xml' ) );
		setSchedulerConfigTemplate( expandPath( '/cfconfig-services/resources/adobe2016/neo-cron.xml' ) );
		setEventGatewayConfigTemplate( expandPath( '/cfconfig-services/resources/adobe2016/neo-event.xml' ) );
		setWebsocketConfigTemplate( expandPath( '/cfconfig-services/resources/adobe2016/neo-websocket.xml' ) );
		setSeedPropertiesPath( '/lib/seed.properties' );
		setLicensePropertiesTemplate( expandPath( '/cfconfig-services/resources/adobe2016/license.properties' ) );
		setVersion( '2016' );
		
		return this;
	}
		
}