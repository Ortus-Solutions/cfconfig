/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
*/
component extends="tests.BaseTest" appMapping="/tests" {
		
	function run(){

		describe( "Adobe 2018 Server config", function(){
			
			it( "can read config", function() {
				
				var Adobe2018Config = getInstance( 'Adobe2018@cfconfig-services' )
					.read( expandPath( '/tests/resources/adobe2018/ServerHome/WEB-INF/cfusion' ) );
				
				expect( Adobe2018Config.getMemento() ).toBeStruct();				
			});
			
			it( "can write config", function() {
				
				var Adobe2018Config = getInstance( 'Adobe2018@cfconfig-services' )
					.read( expandPath( '/tests/resources/Adobe2018/ServerHome/WEB-INF/cfusion' ) )
					.write( expandPath( '/tests/resources/tmp' ) );
					
				expect( fileExists( '/tests/resources/tmp/lib/neo-runtime.xml' ) ).toBeTrue();
				expect( isXML( fileRead( '/tests/resources/tmp/lib/neo-runtime.xml' ) ) ).toBeTrue();
			});
		
		});

	}

}
