component extends="coldbox.system.testing.BaseTestCase" appMapping="/tests" {
	
	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		structDelete( application, getColdboxAppKey() );
		super.beforeAll();
		//ApplicationStop();
		if( directoryExists( '/tests/resources/tmp' ) ) {
			directoryDelete( '/tests/resources/tmp', true );
			directoryCreate( '/tests/resources/tmp' );
			fileWrite( '/tests/resources/tmp/.gitignore', '*#chr( 10 )#!/.gitignore' );	
		}
		controller.getModuleService().registerAndActivateModule( 'cfconfig', 'root' );
	}
	
}
