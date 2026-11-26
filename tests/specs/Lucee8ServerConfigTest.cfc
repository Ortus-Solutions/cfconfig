/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* Lucee 8 server context. Lucee 8 has no web context.
* See https://docs.lucee.org/recipes/breaking-changes-8-0.html#configuration-cfconfig-json
*/
component extends="tests.BaseTest" appMapping="/tests" {

	function run(){

		var tmpConfigFile = '/tests/resources/tmp/context/.CFConfig.json';

		var resetTmp = () => {
			if( directoryExists( expandPath( '/tests/resources/tmp' ) ) ){
				directoryDelete( expandPath( '/tests/resources/tmp' ), true );
			}
		};

		// Write a raw Lucee 8 config file into tmp so it can be read or merged into
		var writeTmpConfig = ( required struct data ) => {
			directoryCreate( expandPath( '/tests/resources/tmp/context' ), true, true );
			fileWrite( expandPath( tmpConfigFile ), serializeJSON( data ) );
		};

		var readTmpOutput = () => deserializeJSON( fileRead( expandPath( tmpConfigFile ) ) );

		describe( "Lucee 8 Server config", function(){

			beforeEach( () => resetTmp() );

			it( "can read config", function() {

				var config = getInstance( 'Lucee8Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee8/serverHome/lucee-server' ) )
					.getMemento();

				expect( config ).toBeStruct();
				// Make sure the stock fixture was actually found and read
				expect( config ).toHaveKey( "loggers" );
				expect( config.loggers ).toHaveKey( "datasource" );
				// Lucee 8 stores this as { "span" : "0,0,0,50" }
				expect( config.requestTimeout ).toBe( "0,0,0,50" );
			});

			it( "can write config", function() {

				getInstance( 'Lucee8Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee8/serverHome/lucee-server' ) )
					.write( expandPath( '/tests/resources/tmp' ) );

				expect( fileExists( tmpConfigFile ) ).toBeTrue();
				expect( isJson( fileRead( tmpConfigFile ) ) ).toBeTrue();
				expect( readTmpOutput().requestTimeout ).toBe( { "span" : "0,0,0,50" } );
			});

			it( "merges requestTimeout into an existing Lucee 8 file that uses a span struct", function() {

				writeTmpConfig( { "requestTimeout" : { "span" : "0,0,0,50" } } );

				getInstance( 'Lucee8Server@cfconfig-services' )
					.setMemento( { "requestTimeout" : "0,0,1,0" } )
					.write( expandPath( '/tests/resources/tmp' ) );

				expect( readTmpOutput().requestTimeout ).toBe( { "span" : "0,0,1,0" } );
			});

			it( "keeps the empty proxy section from a stock install", function() {

				// Merge into a copy of the stock file so its sections are preserved
				writeTmpConfig( deserializeJSON( fileRead( expandPath( '/tests/resources/lucee8/serverHome/lucee-server/context/.CFConfig.json' ) ) ) );

				getInstance( 'Lucee8Server@cfconfig-services' )
					.setMemento( { "requestTimeout" : "0,0,0,50" } )
					.write( expandPath( '/tests/resources/tmp' ) );

				var output = readTmpOutput();
				expect( output ).toHaveKey( "proxy" );
				expect( output.proxy ).toBeStruct();
			});

			it( "writes logger appenderArguments as a struct", function() {

				getInstance( 'Lucee8Server@cfconfig-services' )
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

				var output = readTmpOutput();
				expect( output.loggers.application.appenderArguments ).toBeStruct();
				expect( output.loggers.application.appenderArguments.path ).toBe( "{lucee-config}/logs/application.log" );
				expect( output.loggers.application.appenderArguments.maxfiles ).toBe( "10" );
			});

		});

		describe( "Lucee 8 Server config - monitoring section", function(){

			beforeEach( () => resetTmp() );

			it( "writes debugging settings inside monitoring, not at the top level", function() {

				getInstance( 'Lucee8Server@cfconfig-services' )
					.setMemento( {
						"debuggingEnabled" : true,
						"debuggingDBEnabled" : true,
						"debuggingExceptionsEnabled" : false,
						"debuggingDumpEnabled" : true,
						"debuggingTracingEnabled" : true,
						"debuggingTimerEnabled" : false,
						"debuggingImplicitVariableAccessEnabled" : true,
						"debuggingQueryUsageEnabled" : true,
						"debuggingTemplate" : true
					} )
					.write( expandPath( '/tests/resources/tmp' ) );

				var output = readTmpOutput();

				expect( output ).toHaveKey( "monitoring" );
				expect( output.monitoring.showDebug ).toBeTrue();
				expect( output.monitoring.debuggingDatabase ).toBeTrue();
				expect( output.monitoring.debuggingException ).toBeFalse();
				expect( output.monitoring.debuggingDump ).toBeTrue();
				expect( output.monitoring.debuggingTracing ).toBeTrue();
				expect( output.monitoring.debuggingTimer ).toBeFalse();
				expect( output.monitoring.debuggingImplicitAccess ).toBeTrue();
				expect( output.monitoring.debuggingQueryUsage ).toBeTrue();
				expect( output.monitoring.debuggingTemplate ).toBeTrue();

				// Lucee 8 silently ignores these at the top level
				for( var key in [ "debuggingEnabled", "debuggingDBEnabled", "debuggingExceptionsEnabled", "debuggingDumpEnabled",
					"debuggingTracingEnabled", "debuggingTimerEnabled", "debuggingImplicitVariableAccessEnabled",
					"debuggingQueryUsageEnabled", "debuggingTemplate", "showDebug", "debuggingDatabase" ] ) {
					expect( output ).notToHaveKey( key );
				}
			});

			it( "drops a non-boolean debuggingTemplate (Adobe template path)", function() {

				getInstance( 'Lucee8Server@cfconfig-services' )
					.setMemento( { "debuggingTemplate" : "classic.cfm", "debuggingDBEnabled" : true } )
					.write( expandPath( '/tests/resources/tmp' ) );

				var output = readTmpOutput();
				expect( output ).notToHaveKey( "debuggingTemplate" );
				expect( output.monitoring ).notToHaveKey( "debuggingTemplate" );
				expect( output.monitoring.debuggingDatabase ).toBeTrue();
			});

			it( "reads monitoring settings and Lucee 7.1 top level aliases back to CFConfig names", function() {

				writeTmpConfig( {
					"monitoring" : {
						"showDebug" : true,
						"debuggingDatabase" : true,
						"debuggingTemplate" : true
					},
					// Lucee 7.1 style top level alias
					"debuggingShowException" : true
				} );

				var config = getInstance( 'Lucee8Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/tmp' ) )
					.getMemento();

				expect( config.debuggingEnabled ).toBeTrue();
				expect( config.debuggingDBEnabled ).toBeTrue();
				expect( config.debuggingTemplate ).toBeTrue();
				expect( config.debuggingExceptionsEnabled ).toBeTrue();
			});

			it( "prefers the value inside monitoring over a stale top level key", function() {

				writeTmpConfig( {
					"monitoring" : { "debuggingDatabase" : true },
					"debuggingDatabase" : false
				} );

				var config = getInstance( 'Lucee8Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/tmp' ) )
					.getMemento();

				expect( config.debuggingDBEnabled ).toBeTrue();
			});

			it( "merges into an existing monitoring section and moves legacy top level keys", function() {

				writeTmpConfig( {
					"monitoring" : { "showDoc" : true, "debuggingDatabase" : false },
					// Left over from a Lucee 7.1 config
					"debuggingShowTimer" : true
				} );

				getInstance( 'Lucee8Server@cfconfig-services' )
					.setMemento( { "debuggingDBEnabled" : true } )
					.write( expandPath( '/tests/resources/tmp' ) );

				var output = readTmpOutput();

				// Unknown/unmanaged key in the section is kept
				expect( output.monitoring.showDoc ).toBeTrue();
				// New value wins over the existing one
				expect( output.monitoring.debuggingDatabase ).toBeTrue();
				// Legacy top level alias is moved into the section
				expect( output.monitoring.debuggingTimer ).toBeTrue();
				expect( output ).notToHaveKey( "debuggingShowTimer" );
			});

		});

		describe( "Lucee 8 Server config - proxy section", function(){

			beforeEach( () => resetTmp() );

			it( "writes update proxy settings inside proxy", function() {

				getInstance( 'Lucee8Server@cfconfig-services' )
					.setMemento( {
						"updateProxyHost" : "proxy.example.com",
						"updateProxyPort" : 8080,
						"updateProxyUsername" : "proxyuser",
						"updateProxyPassword" : "proxypass"
					} )
					.write( expandPath( '/tests/resources/tmp' ) );

				var output = readTmpOutput();

				expect( output.proxy.server ).toBe( "proxy.example.com" );
				expect( output.proxy.port ).toBe( 8080 );
				expect( output.proxy.username ).toBe( "proxyuser" );
				expect( output.proxy.password ).toBe( "proxypass" );

				for( var key in [ "updateProxyHost", "updateProxyPort", "updateProxyUsername", "updateProxyPassword" ] ) {
					expect( output ).notToHaveKey( key );
				}
			});

			it( "reads proxy settings back to CFConfig names", function() {

				writeTmpConfig( {
					"proxy" : { "server" : "proxy.example.com", "port" : 8080, "username" : "proxyuser", "password" : "proxypass" }
				} );

				var config = getInstance( 'Lucee8Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/tmp' ) )
					.getMemento();

				expect( config.updateProxyHost ).toBe( "proxy.example.com" );
				expect( config.updateProxyPort ).toBe( 8080 );
				expect( config.updateProxyUsername ).toBe( "proxyuser" );
				expect( config.updateProxyPassword ).toBe( "proxypass" );
			});

			it( "replaces a legacy top level proxy host when writing", function() {

				writeTmpConfig( { "updateProxyHost" : "old.example.com" } );

				getInstance( 'Lucee8Server@cfconfig-services' )
					.setMemento( { "updateProxyHost" : "new.example.com" } )
					.write( expandPath( '/tests/resources/tmp' ) );

				var output = readTmpOutput();
				expect( output.proxy.server ).toBe( "new.example.com" );
				expect( output ).notToHaveKey( "updateProxyHost" );
			});

		});

		describe( "Lucee 8 Server config - extension providers", function(){

			beforeEach( () => resetTmp() );

			it( "keeps Maven group IDs and drops URL based providers", function() {

				getInstance( 'Lucee8Server@cfconfig-services' )
					.setMemento( { "extensionProviders" : [ "https://extension.lucee.org", "org.lucee", "https://www.forgebox.io", "com.example" ] } )
					.write( expandPath( '/tests/resources/tmp' ) );

				var output = readTmpOutput();
				expect( output.extensionProviders ).toBe( [ "org.lucee", "com.example" ] );
			});

			it( "removes extensionProviders when only URLs were given so Lucee uses its default", function() {

				getInstance( 'Lucee8Server@cfconfig-services' )
					.setMemento( { "extensionProviders" : [ "https://extension.lucee.org", "http://www.forgebox.io" ] } )
					.write( expandPath( '/tests/resources/tmp' ) );

				expect( readTmpOutput() ).notToHaveKey( "extensionProviders" );
			});

		});

		describe( "Lucee 8 Server config - cache settings", function(){

			beforeEach( () => resetTmp() );

			// A stock Lucee install has no cache connections, and EHCache isn't bundled since Lucee 7,
			// so these specs build their own caches with the core RamCache.
			it( "can read default cache configs (CFCONFIG-68)", function() {

				writeTmpConfig( {
					"caches" : {
						"default-object" : { "class" : "lucee.runtime.cache.ram.RamCache", "storage" : false, "custom" : "timeToIdleSeconds=0&timeToLiveSeconds=0" },
						"default-query" : { "class" : "lucee.runtime.cache.ram.RamCache", "storage" : false, "custom" : "timeToIdleSeconds=0&timeToLiveSeconds=0" }
					},
					"cache" : {
						"defaultObject" : "default-object",
						"defaultQuery" : "default-query"
					}
				} );

				var config = getInstance( 'Lucee8Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/tmp' ) )
					.getMemento();

				expect( config.caches ).toHaveKey( "default-object" );
				expect( config.caches ).toHaveKey( "default-query" );
				expect( config.caches[ "default-object" ].type ).toBe( "RAM" );
				expect( config.caches[ "default-object" ].custom ).toBeStruct();

				expect( config.cacheDefaultObject ).toBe( "default-object" );
				expect( config.cacheDefaultQuery ).toBe( "default-query" );
			});

			it( "can write default cache configs (CFCONFIG-68)", function() {

				getInstance( 'Lucee8Server@cfconfig-services' )
					.setMemento( {
						"caches" : {
							"default-object" : { "type" : "RAM", "storage" : false, "custom" : { "timeToIdleSeconds" : 0, "timeToLiveSeconds" : 0 } },
							"default-query" : { "type" : "RAM", "storage" : false, "custom" : { "timeToIdleSeconds" : 0, "timeToLiveSeconds" : 0 } }
						},
						"cacheDefaultObject" : "default-object",
						"cacheDefaultQuery" : "default-query"
					} )
					.write( expandPath( '/tests/resources/tmp' ) );

				var output = readTmpOutput();

				expect( output.caches[ "default-object" ].class ).toBe( "lucee.runtime.cache.ram.RamCache" );
				expect( output.cache[ "defaultObject" ] ).toBe( "default-object" );
				expect( output.cache[ "defaultQuery" ] ).toBe( "default-query" );
				expect( output ).notToHaveKey( "cacheDefaultObject" );
				expect( output ).notToHaveKey( "cacheDefaultQuery" );
			});

			it( "moves a stale top level cacheDefault key into cache without overriding a new value", function() {

				writeTmpConfig( {
					"cacheDefaultQuery" : "old-query",
					"cacheDefaultObject" : "old-object"
				} );

				getInstance( 'Lucee8Server@cfconfig-services' )
					.setMemento( { "cacheDefaultQuery" : "new-query" } )
					.write( expandPath( '/tests/resources/tmp' ) );

				var output = readTmpOutput();
				expect( output.cache.defaultQuery ).toBe( "new-query" );
				expect( output.cache.defaultObject ).toBe( "old-object" );
				expect( output ).notToHaveKey( "cacheDefaultQuery" );
				expect( output ).notToHaveKey( "cacheDefaultObject" );
			});

			it( "should write correct DSN for each datasource driver without switch fall-through", function() {

				getInstance( 'Lucee8Server@cfconfig-services' )
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

				var output = readTmpOutput();

				expect( output.datasources[ "testMySQL" ].dsn ).toBe( "jdbc:mysql://{host}:{port}/{database}" );
				expect( output.datasources[ "testOracle" ].dsn ).toBe( "jdbc:oracle:{drivertype}:@{host}:{port}:ORCL" );
				expect( output.datasources[ "testOracleServiceName" ].dsn ).toBe( "jdbc:oracle:{drivertype}:@{host}:{port}/myservice" );
				expect( output.datasources[ "testPostgreSQL" ].dsn ).toBe( "jdbc:postgresql://{host}:{port}/{database}" );
				expect( output.datasources[ "testMSSQL" ].dsn ).toBe( "jdbc:sqlserver://{host}:{port};databaseName={database}" );
				expect( output.datasources[ "testMSSQL2" ].dsn ).toBe( "jdbc:jtds:sqlserver://{host}:{port}/{database}" );
				expect( output.datasources[ "testH2" ].dsn ).toBe( "jdbc:h2:{path}{database};MODE={mode}" );
			});

			it( "should export scheduledTasks as array and gateways as struct (CFCONFIG-64)", function() {

				getInstance( 'Lucee8Server@cfconfig-services' )
					.setMemento( {
						eventGatewaysLucee: { "eventTest": { CFCPath: "local/test" } },
						scheduledTasks: { "task": { interval: "daily", task: "task" } }
					} )
					.write( expandPath( '/tests/resources/tmp' ) );

				var output = readTmpOutput();
				expect( isArray( output.scheduledTasks ) ).toBeTrue();
				expect( arrayLen( output.scheduledTasks ) ).toBe( 1 );
				expect( output.scheduledTasks[1].name ).toBe( "task" );
				expect( isStruct( output.gateways ) ).toBeTrue();
				expect( output.gateways[ "eventTest" ].cfcPath ).toBe( "local/test" );
			});

		});

	}

}
