/**
	I am a utility for managing Adobe ColdFusion passwords for data sources and mail servers
*/
component accessors='true'  {

    property name='seed';
    property name='Algorithm';

	function init() {		
    	// Seed from the Adobe CF source.  Hard-coded in CF9, but dynamic on CF10+
		setSeed( '0yJ!@1$r8p0L@r1$6yJ!@1rj' );
    	setAlgorithm( 'DESede' );
    	return this;
	}
	
	// In CF10+ the seed and encryption algorithm can be different on each server.  This is so an encryted password by itself is useless
	// without the seed used encrypt it.  Read the current seen and algorithm from a properties file in the CF install home.
	function setSeedProperties( required string seedpropertiesPath ) {
		if( !fileExists( seedpropertiesPath ) ) {
			throw "Seed.properties file doesn't exist. Cannot decrypt passwords";
		}
		
		var fis = CreateObject( 'java', 'java.io.FileInputStream' ).init( seedpropertiesPath );
		var propertyFile = CreateObject( 'java', 'java.util.Properties' ).init();
		propertyFile.load( fis );
		fis.close();
		
		setSeed( propertyFile.getProperty( 'seed', '' ) );
    	setAlgorithm( propertyFile.getProperty( 'algorithm', '' ) );
    	
    	return this;
	}
	

    public string function encryptDataSource( required string pass ) {
    	var secretKey = _generate3DesKey( seed );
		return encrypt( pass, secretKey, getAlgorithm(), "Base64");
    }

    public string function decryptDataSource( required string pass ) {
		return encryptDataSource( pass );
    }	

	// Same as data source for now
    public string function encryptMailServer( required string pass ) {
		return decryptDataSource( pass );
    }

	// Same as data source for now
    public string function decryptMailServer( required string pass ) {
    	var secretKey = _generate3DesKey( seed );
		return decrypt( pass, secretKey, getAlgorithm(), "Base64");
    }

	// **************************************************************************************************************
    // Internal private methods
	// **************************************************************************************************************
	
	// Adobe CF has this as a built-in function, but not Lucee. Credit to Paul Klinkenberg 
	// http://www.lucee.nl/post.cfm/cf-function-generate3deskey
	private function _generate3DesKey( string fromString ) {
		if( !structKeyExists( arguments, 'fromString' ) ){
			return generateSecretKey( 'DESEDE' );
		}
		var secretKeySpec = createObject( 'java', 'javax.crypto.spec.SecretKeySpec' ).init( arguments.fromString.getBytes(), 'DESEDE' );
		return toBase64( secretKeySpec.getEncoded() );
	}
}


