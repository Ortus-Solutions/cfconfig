/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Zac Spitzer
*/
component extends="tests.BaseTest" appMapping="/tests" {

	function run(){

		describe( "Lucee 6 Server config", function(){

			it( "can read config", function() {

				var Lucee6ServerConfig = getInstance( 'Lucee6Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee6/ServerHome/lucee-Server' ) );

				expect( Lucee6ServerConfig.getMemento() ).toBeStruct();
			});

			it( "can write config", function() {

				var Lucee6ServerConfig = getInstance( 'Lucee6Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee6/ServerHome/lucee-Server' ) )
					.write( expandPath( '/tests/resources/tmp' ) );

				expect( fileExists( '/tests/resources/tmp/context/.CFconfig.json' ) ).toBeTrue();
				expect( isJson( fileRead( '/tests/resources/tmp/context/.CFconfig.json' ) ) ).toBeTrue();
			});

		});

		describe( "Lucee 6 Server config - cache settings", function(){

			beforeEach(function(currentSpec, data){

				if( directoryExists( expandPath( '/tests/resources/tmp' )) ){
					DirectoryDelete( expandPath( '/tests/resources/tmp' ), true );
				}
			});

			it( "can read default cache configs (CFCONFIG-68)", function() {

				var Lucee6ServerConfig = getInstance( 'Lucee6Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee6/serverHome/lucee-server' ) );

				expect( Lucee6ServerConfig.getMemento() ).toBeStruct();

				var config = Lucee6ServerConfig.getMemento();

				expect( config ).toHaveKey( "caches" );
				expect( config.caches ).toHaveKey( "default-object" );
				expect( config.caches ).toHaveKey( "default-query" );

				expect( config ).toHaveKey( "cacheDefaultObject" );
				expect( config ).toHaveKey( "cacheDefaultQuery" );

			});

			it( "can write default cache configs (CFCONFIG-68)", function() {

				var Lucee6ServerConfig = getInstance( 'Lucee6Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee6/serverHome/lucee-server' ) );

				var config = Lucee6ServerConfig.getMemento();

				expect( config ).toHaveKey( "cacheDefaultObject" );
				expect( config ).toHaveKey( "cacheDefaultQuery" );

				// Write it back out.
				Lucee6ServerConfig.write( expandPath( '/tests/resources/tmp' ) );

				expect( fileExists( '/tests/resources/tmp/context/.CFConfig.json' ) ).toBeTrue();
				expect( isJson( fileRead( '/tests/resources/tmp/context/.CFConfig.json' ) ) ).toBeTrue();

				var config = deserializeJSON( fileRead( '/tests/resources/tmp/context/.CFConfig.json' ) );

				expect( config ).toHaveKey( "caches" );
				expect( config.caches ).toHaveKey( "default-object" );
				expect( config.caches ).toHaveKey( "default-query" );

				expect( config ).toHaveKey( "cache" );
				expect( config.cache ).toHaveKey( "defaultObject" );
				expect( config.cache ).toHaveKey( "defaultQuery" );

				expect( config.cache[ "defaultObject" ] ).toBe( "default-object" );
				expect( config.cache[ "defaultQuery" ] ).toBe( "default-query" );

			});

		});

	}

}
