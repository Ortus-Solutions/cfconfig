/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
*/
component extends="tests.BaseTest" appMapping="/tests" {
		
	function run(){

		describe( "Lucee 5 Web config", function(){
			
			it( "can read config", function() {
				
				var Lucee5WebConfig = getInstance( 'Lucee5Web@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee5/WebHome' ) );
				
				expect( Lucee5WebConfig.getMemento() ).toBeStruct();				
			});
			
			it( "can write config", function() {
				
				var Lucee5WebConfig = getInstance( 'Lucee5Web@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee5/WebHome' ) )
					.write( expandPath( '/tests/resources/tmp' ) );
					
				expect( fileExists( '/tests/resources/tmp/lucee-web.xml.cfm' ) ).toBeTrue();
				expect( isXML( fileRead( '/tests/resources/tmp/lucee-web.xml.cfm' ) ) ).toBeTrue();
			});
		
		});

	}

}
