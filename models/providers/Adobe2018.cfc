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
		
		setRuntimeConfigTemplate( expandPath( '/cfconfig-services/resources/adobe2018/neo-runtime.xml' ) );		
		setClientStoreConfigTemplate( expandPath( '/cfconfig-services/resources/adobe2018/neo-clientstore.xml' ) );		
		setWatchConfigTemplate( expandPath( '/cfconfig-services/resources/adobe2018/neo-watch.xml' ) );		
		setMailConfigTemplate( expandPath( '/cfconfig-services/resources/adobe2018/neo-mail.xml' ) );		
		setDatasourceConfigTemplate( expandPath( '/cfconfig-services/resources/adobe2018/neo-datasource.xml' ) );
		setSeedPropertiesPath( '/lib/seed.properties' );
		setLicensePropertiesTemplate( expandPath( '/cfconfig-services/resources/adobe2018/license.properties' ) );
		setVersion( '2018' );
		
		return this;
	}
		
}