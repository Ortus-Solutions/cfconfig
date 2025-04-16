/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
*
* I represent the behavior of reading and writing CF engine config in the format compatible with a Lucee 7.x server context
* I extend the Lucee6Server class, which is when the JSON format started. 
*/
component accessors=true extends='cfconfig-services.models.providers.Lucee6Server' {

	/**
	* Constructor
	*/
	function init() {
		super.init();

		setFormat( 'luceeServer' );
		setVersion( '7-snapshot' );

		return this;
	}

}