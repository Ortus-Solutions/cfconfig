/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Mark Drew
* 
* I represent the behavior of reading and writing CF engine config in the format compatible with a Railo 4.x server context
* I extend the BaseConfig class, which represents the data itself.
*/
component accessors=true extends='cfconfig-services.models.BaseRailo' {
		
	/**
	* Constructor
	*/
	function init() {
		super.init();
		
		// Used when writing out a Lucee server context config file from the generic config
		setConfigFileTemplate( expandPath( '/cfconfig-services/resources/railo4/railo-server-base.xml' ) );
		
		// This is the file name used by this config file
		setConfigFileName( 'railo-server.xml' );
		// This is where said config file is stored inside the server home
		setConfigRelativePathWithinServerHome( '/context/' );

		setFormat( 'railoServer' );
		setVersion( '4' );
		
		return this;
	}	
}