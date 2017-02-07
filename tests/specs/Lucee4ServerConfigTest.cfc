component extends="tests.BaseTest" appMapping="/tests" {
		
	function run(){

		describe( "Lucee 4 Server config", function(){
			
			it( "can read config", function() {
				
				var Lucee4ServerConfig = getInstance( 'Lucee4ServerConfig@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee4/ServerHome/Lucee-Server' ) );
				
				expect( Lucee4ServerConfig.getMemento() ).toBeStruct();				
			});
			
			it( "can write config", function() {
				
				var Lucee4ServerConfig = getInstance( 'Lucee4ServerConfig@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee4/ServerHome/Lucee-Server' ) )
					.write( expandPath( '/tests/resources/tmp' ) );
					
				expect( fileExists( '/tests/resources/tmp/context/Lucee-Server.xml' ) ).toBeTrue();
				expect( isXML( fileRead( '/tests/resources/tmp/context/Lucee-Server.xml' ) ) ).toBeTrue();
			});
		
		});

	}

}
