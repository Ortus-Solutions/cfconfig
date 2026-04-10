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

			it( "should write correct DSN for each datasource driver without switch fall-through", function() {
				var Lucee6ServerConfig = getInstance( 'Lucee6Server@cfconfig-services' );
				var testConfig = {
					datasources: {
						"testMySQL": {
							dbdriver: "MySQL",
							host: "127.0.0.1",
							port: "3306",
							database: "mydb",
							username: "root",
							password: "pass",
							class: "com.mysql.cj.jdbc.Driver"
						},
						"testOracle": {
							dbdriver: "Oracle",
							host: "127.0.0.1",
							port: "1521",
							database: "orcl",
							username: "sys",
							password: "pass",
							class: "oracle.jdbc.OracleDriver",
							SID: "ORCL"
						},
						"testOracleServiceName": {
							dbdriver: "Oracle",
							host: "127.0.0.1",
							port: "1521",
							database: "orcl",
							username: "sys",
							password: "pass",
							class: "oracle.jdbc.OracleDriver",
							SID: "",
							serviceName: "myservice"
						},
						"testPostgreSQL": {
							dbdriver: "PostgreSQL",
							host: "127.0.0.1",
							port: "5432",
							database: "pgdb",
							username: "postgres",
							password: "pass",
							class: "org.postgresql.Driver"
						},
						"testMSSQL": {
							dbdriver: "MSSQL",
							host: "127.0.0.1",
							port: "1433",
							database: "msdb",
							username: "sa",
							password: "pass",
							class: "com.microsoft.sqlserver.jdbc.SQLServerDriver"
						},
						"testMSSQL2": {
							dbdriver: "MSSQL2",
							host: "127.0.0.1",
							port: "1433",
							database: "msdb",
							username: "sa",
							password: "pass",
							class: "net.sourceforge.jtds.jdbc.Driver"
						},
						"testH2": {
							dbdriver: "H2",
							host: "127.0.0.1",
							port: "9092",
							database: "h2db",
							username: "sa",
							password: "",
							class: "org.h2.Driver"
						}
					}
				};
				Lucee6ServerConfig.setMemento( testConfig );
				Lucee6ServerConfig.write( expandPath( '/tests/resources/tmp' ) );

				var output = deserializeJSON( fileRead( expandPath( '/tests/resources/tmp/context/.CFConfig.json' ) ) );

				expect( output.datasources[ "testMySQL" ].dsn ).toBe( "jdbc:mysql://{host}:{port}/{database}" );
				expect( output.datasources[ "testOracle" ].dsn ).toBe( "jdbc:oracle:{drivertype}:@{host}:{port}:ORCL" );
				expect( output.datasources[ "testOracleServiceName" ].dsn ).toBe( "jdbc:oracle:{drivertype}:@{host}:{port}/myservice" );
				expect( output.datasources[ "testPostgreSQL" ].dsn ).toBe( "jdbc:postgresql://{host}:{port}/{database}" );
				expect( output.datasources[ "testMSSQL" ].dsn ).toBe( "jdbc:sqlserver://{host}:{port}:databaseName={database}" );
				expect( output.datasources[ "testMSSQL2" ].dsn ).toBe( "jdbc:jtds:sqlserver://{host}:{port}/{database}" );
				expect( output.datasources[ "testH2" ].dsn ).toBe( "jdbc:h2:{path}{database};MODE={mode}" );
			});

			it( "should export scheduledTasks as array and gateways as struct (CFCONFIG-64)", function() {
				var Lucee6ServerConfig = getInstance( 'Lucee6Server@cfconfig-services' );
				var testConfig = {
					eventGatewaysLucee: {
						"eventTest": {
							CFCPath: "local/test"
						}
					},
					scheduledTasks: {
						"task": {
							interval: "daily",
							task: "task"
						}
					}
				};
				Lucee6ServerConfig.setMemento( testConfig );
				Lucee6ServerConfig.write( expandPath( '/tests/resources/tmp' ) );

				var output = deserializeJSON( fileRead( expandPath( '/tests/resources/tmp/context/.CFConfig.json' ) ) );
				expect( isArray( output.scheduledTasks ) ).toBeTrue();
				expect( arrayLen( output.scheduledTasks ) ).toBe( 1 );
				expect( output.scheduledTasks[1].name ).toBe( "task" );
				expect( isStruct( output.gateways ) ).toBeTrue();
				expect( output.gateways[ "eventTest" ].cfcPath ).toBe( "local/test" );
			});
	
		});

	}

}
