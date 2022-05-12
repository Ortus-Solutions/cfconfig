/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
*/
component extends="tests.BaseTest" appMapping="/tests" {
		
	function run(){

		describe( "Lucee 5 Server config", function(){
			
			it( "can read config", function() {
				
				var Lucee5ServerConfig = getInstance( 'Lucee5Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee5/ServerHome/Lucee-Server' ) );
				
				expect( Lucee5ServerConfig.getMemento() ).toBeStruct();				
			});
			
			it( "can write config", function() {
				
				var Lucee5ServerConfig = getInstance( 'Lucee5Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee5/ServerHome/Lucee-Server' ) )
					.write( expandPath( '/tests/resources/tmp' ) );
					
				expect( fileExists( '/tests/resources/tmp/context/Lucee-Server.xml' ) ).toBeTrue();
				expect( isXML( fileRead( '/tests/resources/tmp/context/Lucee-Server.xml' ) ) ).toBeTrue();
			});
		
		});


		describe( "Lucee 5 Server config - ComponentPaths", function(){
			
			it( "can read ComponentPaths config", function() {
				
				var Lucee5ServerConfig = getInstance( 'Lucee5Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee5/ServerHome/Lucee-Server' ) );
				
				expect( Lucee5ServerConfig.getMemento() ).toBeStruct();				

				var config = Lucee5ServerConfig.getMemento();
				debug(config);

				expect( config ).toHaveKey( "componentPaths" );
				expect( config.componentPaths ).toBeTypeOf( "struct" );

				expect( config.componentPaths ).toHaveKey( "exampleComponentPath" );
				
				var exampleComponent = config.componentPaths.exampleComponentPath;
				
				expect( exampleComponent ).toHaveKey( "name" );
				expect( exampleComponent ).toHaveKey( "physical" );
				expect( exampleComponent ).toHaveKey( "archive" );
				expect( exampleComponent ).toHaveKey( "primary" );
				expect( exampleComponent ).toHaveKey( "inspectTemplate" );
				expect( exampleComponent ).toHaveKey( "readonly" );
			

			});
			
			it( "can write ComponentPaths config", function() {
				
				var Lucee5ServerConfig = getInstance( 'Lucee5Server@cfconfig-services' )
					.read( expandPath( '/tests/resources/lucee5/ServerHome/Lucee-Server' ) );

					expect( Lucee5ServerConfig.getMemento()  ).toHaveKey("componentPaths");
					debug( Lucee5ServerConfig.getMemento() );

					// Write it back out. 
					Lucee5ServerConfig.write(  expandPath( '/tests/resources/tmp' ) );

				expect( fileExists( '/tests/resources/tmp/context/Lucee-Server.xml' ) ).toBeTrue();
				expect( isXML( fileRead( '/tests/resources/tmp/context/Lucee-Server.xml' ) ) ).toBeTrue();

				var config = XMLParse( fileRead( '/tests/resources/tmp/context/Lucee-Server.xml' ) );
				debug( config.XmlRoot.component );
				expect( config.XmlRoot.component.XMLChildren.len() ).toBe( 3 );

			});
		
		});

	}

}
