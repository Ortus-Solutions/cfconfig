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
				
				var Railo4ServerConfig = getInstance( 'Railo4Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/railo4/serverHome/Railo-Server' ) )
					.setWatchConfigFilesForChangesEnabled( true )
					.write();
					
				expect( XMLParse( fileRead( '/tests/resources/railo4/serverHome/Railo-Server/context/Railo-Server.xml' ) ).XMLRoot.XMLAttributes[ 'check-for-changes' ] ).toBeTrue();
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

				
				expect(outfile.CFMappings['/railo-context/'].PHYSICAL).ToBe( "{railo-config}/context/");
	
				
			});
		
		});

	}

}
