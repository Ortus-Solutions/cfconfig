component extends="tests.BaseTest" appMapping="/tests" {

	function beforeAll(){
		super.beforeAll();
		
		variables.configService = getInstance( 'CFConfigService@cfconfig-services' );
	}
		
	function run(){

		describe( "ConfigService", function(){
			
			it( "can read register providers", function() {			
				expect( configService.getProviderRegistry() ).toBeArray();
				expect( configService.getProviderRegistry().len() ).toBeGT( 1 );				
			});
			
			it( "can determine a Lucee provider", function() {
				expect( configService.determineProvider( 'LuceeWeb', '4' ) ).toBeInstanceOf( 'Lucee4Web' );
				expect( configService.determineProvider( 'LuceeWeb', '4.5' ) ).toBeInstanceOf( 'Lucee4Web' );
				expect( configService.determineProvider( 'LuceeServer', '4' ) ).toBeInstanceOf( 'Lucee4Server' );
				expect( configService.determineProvider( 'LuceeServer', '4.5' ) ).toBeInstanceOf( 'Lucee4Server' );	
			});
			
			it( "can determine an Adobe provider", function() {
				expect( configService.determineProvider( 'adobe', '11' ) ).toBeInstanceOf( 'adobe11' );
				expect( configService.determineProvider( 'adobe', '11.0.10' ) ).toBeInstanceOf( 'adobe11' );	
			});
			
			it( "Throw an error for unsupported engine", function() {
				expect( function() {
					configService.determineProvider( 'fobar', '99' );
				} ).toThrow( 'cfconfigNoProviderFound' );	
			});
			
			it( "Throw an error for unsupported version", function() {
				expect( function() {
					configService.determineProvider( 'adobe', '3' );
				} ).toThrow( 'cfconfigNoProviderFound' );
			});
			
		
		});

	}

}
