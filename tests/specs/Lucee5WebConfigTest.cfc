/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
*/
component extends="tests.BaseTest" appMapping="/tests" {
		
	function run(){

		describe( "Lucee 5 Web config", function(){
			
			it( "can read config", function() {
				
				var Lucee5WebConfig = getInstance( 'Lucee5Web@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee5/WebHome' ) );
				
				expect( Lucee5WebConfig.getMemento() ).toBeStruct();				
			});
			
			it( "can write config", function() {
				
				var Lucee5WebConfig = getInstance( 'Lucee5Web@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee5/WebHome' ) )
					.write( expandPath( '/tests/resources/tmp' ) );
					
				expect( fileExists( '/tests/resources/tmp/lucee-web.xml.cfm' ) ).toBeTrue();
				expect( isXML( fileRead( '/tests/resources/tmp/lucee-web.xml.cfm' ) ) ).toBeTrue();
			});
		
		});

		describe( "Lucee 5 Web Debugging config", function(){

			it( "can read debugging config", function() {
				
				var Lucee5WebConfig = getInstance( 'Lucee5Web@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee5/WebHome' ) );
				
				debug(Lucee5WebConfig.getMemento());
				debug(Lucee5WebConfig);
				expect( Lucee5WebConfig.getMemento() ).toBeStruct();				

				var stConfig = Lucee5WebConfig.getMemento();

				expect( stConfig.debuggingDBEnabled ).toBeTypeOf("boolean");
				expect( stConfig.debuggingDumpEnabled ).toBeTypeOf("boolean");
				expect( stConfig.debuggingEnabled ).toBeTypeOf("boolean");
				expect( stConfig.debuggingExceptionsEnabled ).toBeTypeOf("boolean");
				expect( stConfig.debuggingImplicitVariableAccessEnabled ).toBeTypeOf("boolean");
				expect( stConfig.debuggingQueryUsageEnabled ).toBeTypeOf("boolean");
				expect( stConfig.debuggingTimerEnabled ).toBeTypeOf("boolean");
				expect( stConfig.debuggingTracingEnabled ).toBeTypeOf("boolean");
				expect( stConfig ).toHaveKey("debuggingTemplates");

				expect( stConfig.debuggingTemplates ).toBeTypeOf("struct");


			});

			it( "can write debugging config", function() {
				
				var Lucee5WebConfig = getInstance( 'Lucee5Web@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee5/WebHome' ) )
					.write( expandPath( '/tests/resources/tmp' ) );
					
				expect( fileExists( '/tests/resources/tmp/lucee-web.xml.cfm' ) ).toBeTrue();
				
				var configFile =  fileRead( '/tests/resources/tmp/lucee-web.xml.cfm' ) ;
				expect( isXML( configFile ) ).toBeTrue();
				var xmlConfig = XMLParse(configFile);

				var aDebugging = xmlSearch(xmlConfig, "//debugging");
				expect( aDebugging ).toBeTypeOf("array");
				expect( aDebugging.Len() ).toBeTrue();

				var debugging = aDebugging[1];
				debug(debugging);
				expect( debugging.XmlChildren ).toBeTypeOf("array");
				expect( debugging.Len() ).toBeTrue();
				
			});

		});


	}

}
