/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
*
* I represent the behavior of reading and writing CF engine config in the format compatible with a Lucee 5.x web context
* I extend the BaseConfig class, which represents the data itself.
*/
component accessors=true extends='cfconfig-services.models.providers.Lucee6Server' {

	/**
	* Constructor
	*/
	function init() {
		// Call super first, then override
		super.init();

		// This is where said config file is stored inside the server home
		setConfigRelativePathWithinServerHome( '/' );
		setFormat( 'luceeWeb' );
		setVersion( '6' );

		return this;
	}

}