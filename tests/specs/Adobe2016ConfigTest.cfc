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

				expect( Adobe2016Config.getMemento() ).toBeStruct();
			});
			
			it( "can write config", function() {
				
				var Adobe2016Config = getInstance( 'Adobe2016@cfconfig-services' )
					.read( expandPath( '/tests/resources/Adobe2016/ServerHome/WEB-INF/cfusion' ) )
					.write( expandPath( '/tests/resources/tmp' ) );
					
				expect( fileExists( '/tests/resources/tmp/lib/neo-runtime.xml' ) ).toBeTrue();
				expect( isXML( fileRead( '/tests/resources/tmp/lib/neo-runtime.xml' ) ) ).toBeTrue();
			});


			it( "can export to JSON", function(){
				var configService = getInstance( 'CFConfigService@cfconfig-services' );
				configService.transfer(
					from		= '/tests/resources/Adobe2016/ServerHome/WEB-INF/cfusion',
					to			= '/tests/resources/tmp/Adobe2016Config.json',
					toFormat	= 'JSON',
					fromFormat	= 'adobe',
					fromVersion	= '2016'
					);

					expect( fileExists( '/tests/resources/tmp/Adobe2016Config.json' ) ).toBeTrue();

				var outfile = deserializeJSON(FileRead('/tests/resources/tmp/Adobe2016Config.json'));
					expect(outfile).toBeStruct();
			});

			it( "can read from JSON", function(){
				var configService = getInstance( 'CFConfigService@cfconfig-services' );
				configService.transfer(
					to			= '/tests/resources/tmp/Adobe2016/',
					from		= '/tests/resources/tmp/Adobe2016Config.json',
					fromFormat	= 'JSON',
					toFormat	= 'adobe',
					toVersion	= '2016'
					);

					expect( fileExists( '/tests/resources/tmp/Adobe2016/lib/neo-runtime.xml' ) ).toBeTrue();
					expect( isXML( fileRead( '/tests/resources/tmp/Adobe2016/lib/neo-runtime.xml' ) ) ).toBeTrue();
			});



		});

	}

}
