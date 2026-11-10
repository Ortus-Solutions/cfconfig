/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* Lucee 7 server context. Lucee 7 has no web context tests.
*/
component extends="tests.BaseTest" appMapping="/tests" {

	function run(){

		describe( "Lucee 7 Server config", function(){

			beforeEach(function(currentSpec, data){
				if( directoryExists( expandPath( '/tests/resources/tmp' ) ) ){
					directoryDelete( expandPath( '/tests/resources/tmp' ), true );
				}
			});

			it( "can read config", function() {

				var Lucee7ServerConfig = getInstance( 'Lucee7Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee7/serverHome/lucee-server' ) );

				var config = Lucee7ServerConfig.getMemento();
				expect( config ).toBeStruct();
				// Make sure the stock fixture was actually found and read
				expect( config ).toHaveKey( "loggers" );
				expect( config.loggers ).toHaveKey( "datasource" );
			});

			it( "can write config", function() {

				getInstance( 'Lucee7Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee7/serverHome/lucee-server' ) )
					.write( expandPath( '/tests/resources/tmp' ) );

				expect( fileExists( '/tests/resources/tmp/context/.CFConfig.json' ) ).toBeTrue();
				expect( isJson( fileRead( '/tests/resources/tmp/context/.CFConfig.json' ) ) ).toBeTrue();
			});

			it( "writes logger appenderArguments as a struct", function() {

				getInstance( 'Lucee7Server@cfconfig-services' )
					.setMemento( {
						"loggers" : {
							"application" : {
								"appender" : "resource",
								"appenderArguments" : "path:{lucee-config}/logs/application.log;maxfiles:10",
								"layout" : "classic",
								"level" : "info"
							}
						}
					} )
					.write( expandPath( '/tests/resources/tmp' ) );

				var output = deserializeJSON( fileRead( expandPath( '/tests/resources/tmp/context/.CFConfig.json' ) ) );

				expect( output.loggers.application.appenderArguments ).toBeStruct();
				expect( output.loggers.application.appenderArguments.path ).toBe( "{lucee-config}/logs/application.log" );
				expect( output.loggers.application.appenderArguments.maxfiles ).toBe( "10" );
			});

		});

		describe( "Lucee 7 Server config - cache settings", function(){

			beforeEach(function(currentSpec, data){
				if( directoryExists( expandPath( '/tests/resources/tmp' ) ) ){
					directoryDelete( expandPath( '/tests/resources/tmp' ), true );
				}
			});

			// A stock Lucee install has no cache connections, and EHCache isn't bundled since Lucee 7,
			// so these specs build their own caches with the core RamCache.
			it( "can read default cache configs (CFCONFIG-68)", function() {

				directoryCreate( expandPath( '/tests/resources/tmp/context' ), true, true );
				fileWrite( expandPath( '/tests/resources/tmp/context/.CFConfig.json' ), serializeJSON( {
					"caches" : {
						"default-object" : { "class" : "lucee.runtime.cache.ram.RamCache", "storage" : false, "custom" : "timeToIdleSeconds=0&timeToLiveSeconds=0" },
						"default-query" : { "class" : "lucee.runtime.cache.ram.RamCache", "storage" : false, "custom" : "timeToIdleSeconds=0&timeToLiveSeconds=0" }
					},
					"cache" : {
						"defaultObject" : "default-object",
						"defaultQuery" : "default-query"
					}
				} ) );

				var config = getInstance( 'Lucee7Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/tmp' ) )
					.getMemento();

				expect( config ).toHaveKey( "caches" );
				expect( config.caches ).toHaveKey( "default-object" );
				expect( config.caches ).toHaveKey( "default-query" );
				expect( config.caches[ "default-object" ].type ).toBe( "RAM" );
				expect( config.caches[ "default-object" ].custom ).toBeStruct();

				expect( config.cacheDefaultObject ).toBe( "default-object" );
				expect( config.cacheDefaultQuery ).toBe( "default-query" );
			});

			it( "can write default cache configs (CFCONFIG-68)", function() {

				getInstance( 'Lucee7Server@cfconfig-services' )
					.setMemento( {
						"caches" : {
							"default-object" : { "type" : "RAM", "storage" : false, "custom" : { "timeToIdleSeconds" : 0, "timeToLiveSeconds" : 0 } },
							"default-query" : { "type" : "RAM", "storage" : false, "custom" : { "timeToIdleSeconds" : 0, "timeToLiveSeconds" : 0 } }
						},
						"cacheDefaultObject" : "default-object",
						"cacheDefaultQuery" : "default-query"
					} )
					.write( expandPath( '/tests/resources/tmp' ) );

				var config = deserializeJSON( fileRead( '/tests/resources/tmp/context/.CFConfig.json' ) );

				expect( config.caches ).toHaveKey( "default-object" );
				expect( config.caches ).toHaveKey( "default-query" );
				expect( config.caches[ "default-object" ].class ).toBe( "lucee.runtime.cache.ram.RamCache" );

				expect( config.cache[ "defaultObject" ] ).toBe( "default-object" );
				expect( config.cache[ "defaultQuery" ] ).toBe( "default-query" );
			});

			it( "should write correct DSN for each datasource driver without switch fall-through", function() {

				getInstance( 'Lucee7Server@cfconfig-services' )
					.setMemento( {
						datasources: {
							"testMySQL": { dbdriver: "MySQL", host: "127.0.0.1", port: "3306", database: "mydb", username: "root", password: "pass", class: "com.mysql.cj.jdbc.Driver" },
							"testOracle": { dbdriver: "Oracle", host: "127.0.0.1", port: "1521", database: "orcl", username: "sys", password: "pass", class: "oracle.jdbc.OracleDriver", SID: "ORCL" },
							"testOracleServiceName": { dbdriver: "Oracle", host: "127.0.0.1", port: "1521", database: "orcl", username: "sys", password: "pass", class: "oracle.jdbc.OracleDriver", SID: "", serviceName: "myservice" },
							"testPostgreSQL": { dbdriver: "PostgreSQL", host: "127.0.0.1", port: "5432", database: "pgdb", username: "postgres", password: "pass", class: "org.postgresql.Driver" },
							"testMSSQL": { dbdriver: "MSSQL", host: "127.0.0.1", port: "1433", database: "msdb", username: "sa", password: "pass", class: "com.microsoft.sqlserver.jdbc.SQLServerDriver" },
							"testMSSQL2": { dbdriver: "MSSQL2", host: "127.0.0.1", port: "1433", database: "msdb", username: "sa", password: "pass", class: "net.sourceforge.jtds.jdbc.Driver" },
							"testH2": { dbdriver: "H2", host: "127.0.0.1", port: "9092", database: "h2db", username: "sa", password: "", class: "org.h2.Driver" }
						}
					} )
					.write( expandPath( '/tests/resources/tmp' ) );

				var output = deserializeJSON( fileRead( expandPath( '/tests/resources/tmp/context/.CFConfig.json' ) ) );

				expect( output.datasources[ "testMySQL" ].dsn ).toBe( "jdbc:mysql://{host}:{port}/{database}" );
				expect( output.datasources[ "testOracle" ].dsn ).toBe( "jdbc:oracle:{drivertype}:@{host}:{port}:ORCL" );
				expect( output.datasources[ "testOracleServiceName" ].dsn ).toBe( "jdbc:oracle:{drivertype}:@{host}:{port}/myservice" );
				expect( output.datasources[ "testPostgreSQL" ].dsn ).toBe( "jdbc:postgresql://{host}:{port}/{database}" );
				expect( output.datasources[ "testMSSQL" ].dsn ).toBe( "jdbc:sqlserver://{host}:{port};databaseName={database}" );
				expect( output.datasources[ "testMSSQL2" ].dsn ).toBe( "jdbc:jtds:sqlserver://{host}:{port}/{database}" );
				expect( output.datasources[ "testH2" ].dsn ).toBe( "jdbc:h2:{path}{database};MODE={mode}" );
			});

			it( "should export scheduledTasks as array and gateways as struct (CFCONFIG-64)", function() {

				getInstance( 'Lucee7Server@cfconfig-services' )
					.setMemento( {
						eventGatewaysLucee: { "eventTest": { CFCPath: "local/test" } },
						scheduledTasks: { "task": { interval: "daily", task: "task" } }
					} )
					.write( expandPath( '/tests/resources/tmp' ) );

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
