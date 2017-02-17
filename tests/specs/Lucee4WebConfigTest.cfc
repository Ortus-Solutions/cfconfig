component extends="tests.BaseTest" appMapping="/tests" {
		
	function run(){

		describe( "Lucee 4 Web config", function(){
			
			it( "can read config", function() {
				
				var Lucee4WebConfig = getInstance( 'Lucee4Web@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee4/WebHome' ) );
				
				expect( Lucee4WebConfig.getMemento() ).toBeStruct();				
			});
			
			it( "can write config", function() {
				
				var Lucee4WebConfig = getInstance( 'Lucee4Web@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee4/WebHome' ) )
					.write( expandPath( '/tests/resources/tmp' ) );
					
				expect( fileExists( '/tests/resources/tmp/lucee-web.xml.cfm' ) ).toBeTrue();
				expect( isXML( fileRead( '/tests/resources/tmp/lucee-web.xml.cfm' ) ) ).toBeTrue();
			});
		
		});

	}

}
