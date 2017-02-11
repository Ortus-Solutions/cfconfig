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
			
			it( "Throw an error for unsupported format", function() {
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

		describe( "ConfigService transfer functionality", function(){
			
			it( "can export config from Lucee Server to JSON with default file name", function() {
				configService.transfer(
					from		= '/tests/resources/lucee4/ServerHome/Lucee-Server',
					to			= '/tests/resources/tmp/',
					fromFormat	= 'luceeServer',
					toFormat	= 'JSON',
					fromVersion	= '4'
				 );
				expect( fileRead( expandPath( '/tests/resources/tmp/.CFConfig.json' ) ) ).toBeJSON();
			});
			
			it( "can export config from Lucee Server to JSON with specific file name", function() {
				configService.transfer(
					from		= '/tests/resources/lucee4/ServerHome/Lucee-Server',
					to			= '/tests/resources/tmp/foo.json',
					fromFormat	= 'luceeServer',
					toFormat	= 'JSON',
					fromVersion	= '4'
				 );
				expect( fileRead( expandPath( '/tests/resources/tmp/foo.json' ) ) ).toBeJSON();
			});
			
			it( "can export config from Adobe to JSON", function() {
				configService.transfer(
					from		= '/tests/resources/Adobe11/ServerHome/WEB-INF/cfusion',
					to			= '/tests/resources/tmp/AdobeConfig.json',
					fromFormat	= 'adobe',
					toFormat	= 'JSON',
					fromVersion	= '11'
				 );
				expect( fileRead( expandPath( '/tests/resources/tmp/AdobeConfig.json' ) ) ).toBeJSON();
			});
			
			it( "can import config from JSON to Lucee Server", function() {
				configService.transfer(
					from		= '/tests/resources/.CFConfig.json',
					to			= '/tests/resources/tmp/lucee',
					fromFormat	= 'JSON',
					toFormat	= 'luceeServer',
					toVersion	= '4'
				 );
			});
			
			it( "can export config from JSON to Adobe", function() {
				configService.transfer(
					from		= '/tests/resources/.CFConfig.json',
					to			= '/tests/resources/tmp/adobe',
					fromFormat	= 'JSON',
					toFormat	= 'adobe',
					toVersion	= '11'
				 );
				expect( fileRead( expandPath( '/tests/resources/tmp/AdobeConfig.json' ) ) ).toBeJSON();
			});
			
			it( "can transer config from adobe to Lucee", function() {
				
				configService.transfer(
					from		= '/tests/resources/.CFConfig.json',
					to			= '/tests/resources/tmp/adobe',
					fromFormat	= 'JSON',
					toFormat	= 'adobe',
					toVersion	= '11'
				 );
				
				configService.transfer(
					from		= '/tests/resources/tmp/adobe',
					to			= '/tests/resources/tmp/lucee2',
					fromFormat	= 'adobe',
					toFormat	= 'luceeServer',
					fromVersion	= '11',
					toVersion	= '4'
				 );
			});
			
			it( "can transer config from Lucee to adobe ", function() {
				
				configService.transfer(
					from		= '/tests/resources/.CFConfig.json',
					to			= '/tests/resources/tmp/lucee',
					fromFormat	= 'JSON',
					toFormat	= 'luceeServer',
					toVersion	= '4'
				 );
				
				configService.transfer(
					from		= '/tests/resources/tmp/lucee',
					to			= '/tests/resources/tmp/adobe2',
					fromFormat	= 'luceeServer',
					toFormat	= 'adobe',
					fromVersion	= '4',
					toVersion	= '11'
				 );
			});
		
		});
	}

}
