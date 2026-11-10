/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
*/
component extends="tests.BaseTest" appMapping="/tests" {
		
	function run(){

		describe( "Railo 4 Server config", function(){
			
			it( "can read config", function() {
				
				var Railo4ServerConfig = getInstance( 'Railo4Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/railo4/serverHome/Railo-Server' ) );
				
				expect( Railo4ServerConfig.getMemento() ).toBeStruct();				
			});
			
			it( "can write config", function() {
				
				var Railo4ServerConfig = getInstance( 'Railo4Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/railo4/serverHome/Railo-Server' ) )
					.write( expandPath( '/tests/resources/tmp' ) );
					
				expect( fileExists( '/tests/resources/tmp/context/Railo-Server.xml' ) ).toBeTrue();
				expect( isXML( fileRead( '/tests/resources/tmp/context/Railo-Server.xml' ) ) ).toBeTrue();
			});
			
			it( "can write watchConfigFilesForChangesEnabled", function() {
				
				// Write to tmp, not back over the fixture
				var Railo4ServerConfig = getInstance( 'Railo4Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/railo4/serverHome/Railo-Server' ) )
					.setWatchConfigFilesForChangesEnabled( true )
					.write( expandPath( '/tests/resources/tmp' ) );

				expect( XMLParse( fileRead( '/tests/resources/tmp/context/Railo-Server.xml' ) ).XMLRoot.XMLAttributes[ 'check-for-changes' ] ).toBeTrue();
			});
			it( "can export to JSON", function(){
				var configService = getInstance( 'CFConfigService@cfconfig-services' );
					configService.transfer(
					from		= '/tests/resources/railo4/serverHome/railo-server/',
					to			= '/tests/resources/tmp/Railo4ServerConfig.json',
					fromFormat	= 'railoServer',
					toFormat	= 'JSON',
					fromVersion	= '4'
				 );	

				expect( fileExists( '/tests/resources/tmp/Railo4ServerConfig.json' ) ).toBeTrue();

				var outfile = deserializeJSON(FileRead('/tests/resources/tmp/Railo4ServerConfig.json'));
				
			});
			it( "can import from JSON", function(){
				var configService = getInstance( 'CFConfigService@cfconfig-services' );
					configService.transfer(
					from		= '/tests/resources/.CFConfig.json',
					// Import into tmp, not over the railo4 fixture
					to			= '/tests/resources/tmp/railo4/',
					fromFormat	= 'JSON',
					toFormat	= 'railoServer',
					toVersion	= '4'
				 );

				expect( fileExists( '/tests/resources/tmp/railo4/context/railo-server.xml' ) ).toBeTrue();
				expect( isXML( fileRead( '/tests/resources/tmp/railo4/context/railo-server.xml' ) ) ).toBeTrue();
			});
		
		});

	}

}
