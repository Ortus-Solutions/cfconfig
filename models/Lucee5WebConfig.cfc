/**
* I represent the behavior of reading and writing CF engine config in the format compatible with a Lucee 5.x web context
*/
component accessors=true extends='Lucee4WebConfig' {
	
	/**
	* Constructor
	*/
	function init() {
		// Call super first, then override
		super.init();
		
		// Used when writing out a Lucee server context config file from the generic config
		setConfigFileTemplate( expandPath( '/resources/lucee5/lucee-web-base.xml' ) );		
	}
	
}