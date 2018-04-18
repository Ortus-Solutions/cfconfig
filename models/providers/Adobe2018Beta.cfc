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
component accessors=true extends='cfconfig-services.models.providers.Adobe2018' {
	
	/**
	* Constructor
	*/
	function init() {		
		super.init();
		
		setVersion( '2018-beta' );
		
		return this;
	}
		
}