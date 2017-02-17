component extends="tests.BaseTest" appMapping="/tests" {
		
	function run(){

		describe( "Lucee 5 Server config", function(){
			
			it( "can read config", function() {
				
				var Lucee5ServerConfig = getInstance( 'Lucee5Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee5/ServerHome/Lucee-Server' ) );
				
				expect( Lucee5ServerConfig.getMemento() ).toBeStruct();				
			});
			
			it( "can write config", function() {
				
				var Lucee5ServerConfig = getInstance( 'Lucee5Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee5/ServerHome/Lucee-Server' ) )
					.write( expandPath( '/tests/resources/tmp' ) );
					
				expect( fileExists( '/tests/resources/tmp/context/Lucee-Server.xml' ) ).toBeTrue();
				expect( isXML( fileRead( '/tests/resources/tmp/context/Lucee-Server.xml' ) ) ).toBeTrue();
			});
		
		});

	}

}
