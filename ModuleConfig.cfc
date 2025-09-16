/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
* 
*/
component {
	
	this.title 				= "CFConfig Services";
	this.modelNamespace		= "cfconfig-services";
	this.cfmapping			= "cfconfig-services";
	this.autoMapModels		= true;
	// Need these loaded up first so I can do my job.
	this.dependencies 		= [ 'PropertyFile','lucee-password-util','adobe-password-util' ];

	function configure() {
		settings = {
			"redisCachePasswordAlwaysPlainText" : false
		};
	}
}