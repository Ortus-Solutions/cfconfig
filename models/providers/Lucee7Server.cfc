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
		setVersion( '7' );

		return this;
	}
	
	// Override Lucee 6 this and force struct
	function normalizeAppenderArgumentsForWrite( required struct configData ) {
		// loop over loggers, if the appenderArguments is a css encoded string, make it a struct
		if( configData.keyExists( 'loggers' ) ) {
			for( var loggerName in configData.loggers ) {
				var logger = configData.loggers[ loggerName ];
				if ( logger.keyExists( 'appenderArguments' ) && isSimpleValue( logger.appenderArguments ) ) {
					logger.appenderArguments = translateCSSCodedPairsToStruct( logger.appenderArguments );
				}
			}
		}
	}

}