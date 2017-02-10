component extends="tests.BaseTest" appMapping="/tests" {
		
	function run(){

		describe( "Adobe 11 Server config", function(){
			
			it( "can read config", function() {
				
				var Adobe11Config = getInstance( 'Adobe11@cfconfig-services' )
					.read( expandPath( '/tests/resources/adobe11/ServerHome/WEB-INF/cfusion' ) );
				
				expect( Adobe11Config.getMemento() ).toBeStruct();				
			});
			
			it( "can write config", function() {
				
				var Adobe11Config = getInstance( 'Adobe11@cfconfig-services' )
					.read( expandPath( '/tests/resources/Adobe11/ServerHome/WEB-INF/cfusion' ) )
					.write( expandPath( '/tests/resources/tmp' ) );
					
				expect( fileExists( '/tests/resources/tmp/lib/neo-runtime.xml' ) ).toBeTrue();
				expect( isXML( fileRead( '/tests/resources/tmp/lib/neo-runtime.xml' ) ) ).toBeTrue();
			});
		
		});

	}

}
