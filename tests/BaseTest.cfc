/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
*/
component extends="coldbox.system.testing.BaseTestCase" appMapping="/tests" {
	
	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		// ColdBox 8 removed getColdboxAppKey(); the virtual test app always uses "cbController"
		structDelete( application, 'cbController' );
		super.beforeAll();
		//ApplicationStop();
		if( directoryExists( '/tests/resources/tmp' ) ) {
			directoryDelete( '/tests/resources/tmp', true );
			directoryCreate( '/tests/resources/tmp' );
			fileWrite( '/tests/resources/tmp/.gitignore', '*#chr( 10 )#!/.gitignore' );	
		}
		controller.getModuleService().registerAndActivateModule( 'cfconfig', 'root' );
		// The module folder is "cfconfig" here, but in CommandBox it's installed as "cfconfig-services".
		// Alias it so box:moduleSettings:cfconfig-services injections resolve in the tests.
		var modules = controller.getSetting( 'modules' );
		if( !modules.keyExists( 'cfconfig-services' ) ) {
			modules[ 'cfconfig-services' ] = modules[ 'cfconfig' ];
		}
	}
	
}
