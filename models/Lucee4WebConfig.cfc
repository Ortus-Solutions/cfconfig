/**
* I represent the behavior of reading and writing CF engine config in the format compatible with a Lucee 4.x web context
*/
component accessors=true extends='Lucee4ServerConfig' {
	
	/**
	* Constructor
	*/
	function init() {
		// Call super first, then override
		super.init();
		
		// Used when writing out a Lucee server context config file from the generic config
		setConfigFileTemplate( expandPath( '/resources/lucee4/lucee-web-base.xml' ) );
		
		// Ex: lucee-web/lucee-web.xml.cfm
		
		// This is the file name used by this config file
		setConfigFileName( 'lucee-web.xml.cfm' );
		// This is where said config file is stored inside the server home
		setConfigRelativePathWithinServerHome( '/' );		
	}
	
}