/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
*/
component extends="tests.BaseTest" appMapping="/tests" {
		
	function run(){

		describe( "Railo 4 Web config", function(){
			
			it( "can read config", function() {
				
				var Railo4WebConfig = getInstance( 'Railo4Web@cfconfig-services' );
					Railo4WebConfig.read( expandPath( '/tests/resources/railo4/WebHome' ) );
				expect( Railo4WebConfig.getMemento() ).toBeStruct();				
			});
			
			it( "can write config", function() {
				
				var Railo4WebConfig = getInstance( 'Railo4Web@cfconfig-services' )
					.read( expandPath( '/tests/resources/railo4/WebHome' ) )
					.write( expandPath( '/tests/resources/tmp' ) );
					
				expect( fileExists( '/tests/resources/tmp/railo-web.xml.cfm' ) ).toBeTrue();
				expect( isXML( fileRead( '/tests/resources/tmp/railo-web.xml.cfm' ) ) ).toBeTrue();
			});
			it( "can export to JSON", function(){
				var configService = getInstance( 'CFConfigService@cfconfig-services' );
					configService.transfer(
					from		= '/tests/resources/railo4/WebHome',
					to			= '/tests/resources/tmp/Railo4Config.json',
					fromFormat	= 'railoWeb',
					toFormat	= 'JSON',
					fromVersion	= '4'
				 );	

				expect( fileExists( '/tests/resources/tmp/Railo4Config.json' ) ).toBeTrue();

				var outfile = deserializeJSON(FileRead('/tests/resources/tmp/Railo4Config.json'));

				
				expect(outfile.datasources).toHaveKey( "LogDB");
				expect(outfile.datasources.LogDB).toHaveKey( "password");
				expect(outfile.datasources.LogDB.password).ToBe( "example");

				
			});
		
		});

	}

}
