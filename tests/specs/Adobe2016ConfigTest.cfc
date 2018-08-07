/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
*/
component extends="tests.BaseTest" appMapping="/tests" {
		
	function run(){

		describe( "Adobe 2016 Server config", function(){
			
			it( "can read config", function() {
				
				var Adobe2016Config = getInstance( 'Adobe2016@cfconfig-services' )
					.read( expandPath( '/tests/resources/adobe2016/ServerHome/WEB-INF/cfusion' ) );
				var stMemento = Adobe2016Config.getMemento();
				debug(stMemento);
				expect( stMemento ).toBeStruct();
			});
			
			it( "can write config", function() {
				
				var Adobe2016Config = getInstance( 'Adobe2016@cfconfig-services' )
					.read( expandPath( '/tests/resources/Adobe2016/ServerHome/WEB-INF/cfusion' ) )
					.write( expandPath( '/tests/resources/tmp' ) );
					
				expect( fileExists( '/tests/resources/tmp/lib/neo-runtime.xml' ) ).toBeTrue();
				expect( isXML( fileRead( '/tests/resources/tmp/lib/neo-runtime.xml' ) ) ).toBeTrue();
			});
		
		});

	}

}
