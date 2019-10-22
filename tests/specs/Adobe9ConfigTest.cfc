/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
*/
component extends="tests.BaseTest" appMapping="/tests" {
		
	function run(){

		describe( "Adobe 9 Server config", function(){
			
			it( "can read config", function() {
				
				var Adobe9Config = getInstance( 'Adobe9@cfconfig-services' )
					.read( expandPath( '/tests/resources/adobe9/ServerHome/WEB-INF/cfusion' ) );
				
				expect( Adobe9Config.getMemento() ).toBeStruct();				
			});
			
			it( "can write config", function() {
				
				var Adobe9Config = getInstance( 'Adobe9@cfconfig-services' )
					.read( expandPath( '/tests/resources/adobe9/ServerHome/WEB-INF/cfusion' ) )
					.write( expandPath( '/tests/resources/tmp' ) );
					
				expect( fileExists( '/tests/resources/tmp/lib/neo-runtime.xml' ) ).toBeTrue();
				expect( isXML( fileRead( '/tests/resources/tmp/lib/neo-runtime.xml' ) ) ).toBeTrue();
			});

			it("can write the JSON config", function(){
				var Adobe9Config = getInstance( 'Adobe9@cfconfig-services' )
					.read( expandPath( '/tests/resources/adobe9/ServerHome/WEB-INF/cfusion' ))
					.write( expandPath( '/tests/resources/tmp' ) );

				expect( fileExists( '/tests/resources/tmp/lib/neo-runtime.xml' ) ).toBeTrue();
				expect( isXML( fileRead( '/tests/resources/tmp/lib/neo-runtime.xml' ) ) ).toBeTrue();


			});

			it( "can export to JSON", function(){
				var configService = getInstance( 'CFConfigService@cfconfig-services' );
					configService.transfer(
					from		= expandPath ( '/tests/resources/adobe9/ServerHome/WEB-INF/cfusion' ),
					to			= expandPath ( '/tests/resources/tmp/Adobe9Config.json' ),
					fromFormat	= 'adobe',
					toFormat	= 'JSON',
					fromVersion	= '9'
				 );	

				expect( fileExists( '/tests/resources/tmp/Adobe9Config.json' ) ).toBeTrue();

				var outfile = deserializeJSON(FileRead('/tests/resources/tmp/Adobe9Config.json'));
				expect(outfile.debuggingTemplate).Tobe("/WEB-INF/debug/classic.cfm");
				expect(outfile.datasources).toHaveKey( "LogDB");
				expect(outfile.datasources.LogDB).toHaveKey( "password");
				expect(outfile.datasources.LogDB.password).ToBe( "example");

				
			});
		
		});

	}

}
