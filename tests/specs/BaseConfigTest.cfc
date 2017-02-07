component extends="tests.BaseTest" appMapping="/tests" {
		
	function run(){

		describe( "The base config object", function(){
			
			describe( "can read config", function(){
			
				it( "via setter", function() {
					var JSONConfig = getInstance( 'BaseConfig@cfconfig-services' )
						.setCFHomePath( expandPath( '/tests/resources/.CFConfig.json' ) )
						.read();
					
					expect( JSONConfig.getMemento() ).toBeStruct();				
				});
				
				it( "from specific config file", function() {
					var JSONConfig = getInstance( 'BaseConfig@cfconfig-services' )
						.read( expandPath( '/tests/resources/.CFConfig.json' ) );
					
					expect( JSONConfig.getMemento() ).toBeStruct();				
				});
				
				it( "from the default config file", function() {
					var JSONConfig = getInstance( 'BaseConfig@cfconfig-services' )
						.read( expandPath( '/tests/resources' ) );
					
					expect( JSONConfig.getMemento() ).toBeStruct();				
				});
			
			});
			
			describe( "can write config", function(){
				
				it( "from scratch", function() {
					var JSONConfig = getInstance( 'BaseConfig@cfconfig-services' )
						.setInspectTemplate( 'once' )
						.setSaveClassFiles( true )
						.setAdminPassword( 'foo' )
						.write( expandPath( '/tests/resources/tmp/.CFConfig.json' ) );
					
					expect( fileRead( expandPath( '/tests/resources/tmp/.CFConfig.json' ) ) ).toBeJSON();				
				});
				
				it( "from existing", function() {
					var JSONConfig = getInstance( 'BaseConfig@cfconfig-services' )
						.read( expandPath( '/tests/resources/.CFConfig.json' ) )
						.write( expandPath( '/tests/resources/tmp/.CFConfig.json' ) );
					
					expect( fileRead( expandPath( '/tests/resources/tmp/.CFConfig.json' ) ) ).toBeJSON();				
				});
						
			});
			
			describe( "can import memento", function(){
				
				it( "from another config object", function() {
					var JSONConfig1 = getInstance( 'BaseConfig@cfconfig-services' )
						.read( expandPath( '/tests/resources/.CFConfig.json' ) );
						
					var JSONConfig2 = getInstance( 'BaseConfig@cfconfig-services' )
						.setMemento( JSONConfig1.getMemento() );
						
					expect( JSONConfig2.getMemento() ).toBeStruct();					
				});					
			});
						
		});

	}

}
