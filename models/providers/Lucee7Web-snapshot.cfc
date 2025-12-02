/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
*
* I represent the behavior of reading and writing CF engine config in the format compatible with a Lucee 7.x web context
* I extend the BaseConfig class, which represents the data itself.
*/
component accessors=true extends='cfconfig-services.models.providers.Lucee7Server' {

	/**
	* Constructor
	*/
	function init() {
		// Call super first, then override
		super.init();

		// This is where said config file is stored inside the server home
		setConfigRelativePathWithinServerHome( '/' );
		setFormat( 'luceeWeb' );
		setVersion( '7-snapshot' );

		return this;
	}

	
	/**
	* I read in config
	*
	* @CFHomePath The JSON file to read from
	*/
	function read( string CFHomePath ){
		// no-op.  Lucee 7 has no web config.  This is just to not blow up builds having env vars or JSON files for the web context
		return this;
	}

	/**
	* I write out config from a base JSON format
	*
	* @CFHomePath The JSON file to write to
	*/
	function write( string CFHomePath, pauseTasks=false ){
		// no-op.  Lucee 7 has no web config.  This is just to not blow up builds having env vars or JSON files for the web context
		return this;
	}

}