/*
	I am a utility for managing Lucee or Railo passwords for the administrator and data sources.
	Normally, you won't need me, but sometimes you need to edit the config files directly.
	
	
	hashAdministrator - When passing a salt, use this to mimic the same SHA-256 hashing that the Lucee administrator uses for server and web context passwords. You can't duplicate this
						with the CFML hash() function.  
						Values created by this method would go in one of the following XML files:
						lucee-server.xml
							In the root <lucee-configuration> tag as the "hspw" attribute.  Applies to the web administrator for the entire server
							In the root <lucee-configuration> tag as the "default-hspw" attribute.  Set's the default password for any new web contexts
							In the root <lucee-configuration> tag as the "salt" attribute.  Set's the salt to use for all passwords
						lucee-web.xml.cfm
							In the root <lucee-configuration> tag as the "hspw" attribute.  Applies to the web administrator for that context.
							In the root <lucee-configuration> tag as the "salt" attribute.  Set's the salt to use for all passwords
							
	hashAdministrator - [DEPRECATED. use hash with salt instead] Use this to mimic the same SHA-256 hashing that the Lucee or Railo administrator uses for server and web context passwords. You can't duplicate this
						with the CFML hash() function.  
						Values created by this method would go in one of the following XML files:
						lucee-server.xml
							In the root <lucee-configuration> tag as the "pw" attribute.  Applies to the web administrator for the entire server
							In the root <lucee-configuration> tag as the "default-pw" attribute.  Set's the default password for any new web contexts
						lucee-web.xml.cfm
							In the root <lucee-configuration> tag as the "pw" attribute.  Applies to the web administrator for that context.
							
	encryptAdministrator - [DEPRECATED, use hash with salt instead] Used to encrypt a string using the BlowFish algorithm with the same salt used for the Lucee or Railo administrator.  
	decryptAdministrator - [DEPRECATED, use hash with salt instead] Used to decrypt a string using the BlowFish algorithm with the same salt used for the Lucee or Railo administrator.  
						lucee-server.xml
							In the root <lucee-configuration> tag as the "password" attribute.  Applies to the web administrator for the entire server
							In the root <lucee-configuration> tag as the "default-password" attribute.  Set's the default password for any new web contexts
						lucee-web.xml.cfm
							In the root <lucee-configuration> tag as the "password" attribute.  Applies to the web administrator for that context.
	
	encryptDataSource - Used to encrypt a string using the BlowFish algorithm with the same salt used for data source passwords in the Lucee or Railo administrator.
	decryptDataSource - Used to decrypt a string using the BlowFish algorithm with the same salt used for data source passwords in the Lucee or Railo administrator.
						Values created by this method would go in one of the following files:
						lucee-server.xml
							In a <data-source> tag's password attribute, preceded by the string "encrypted:"
							 
								 <data-source 
								 	username="root"
								 	name="myDS" 
								 	dsn="jdbc:mysql://localhost:3306/myDB" 
								 	class="org.gjt.mm.mysql.Driver"
								  	password="encrypted:3448cf390fa78e1cbb7745607a68ff6e282d60c044ad09ed" />
					  	
						lucee-web.xml.cfm
							In a <data-source> tag same as above
						Application.cfc
							In the datasources struct like so:
							
						        this.datasources.myDS={
    					            class:"org.gjt.mm.mysql.Driver",
                					connectionString:"jdbc:mysql://localhost:3306/myDB",
                					username:"root",
                					password:"encrypted:3448cf390fa78e1cbb7745607a68ff6e282d60c044ad09ed"
	
*/
component {

        // Salts from the Lucee or Railo java source
        variables.administratorSalt = 'tpwisgh';
        variables.dataSourceSalt = 'sdfsdfs';

        // Administrator passwords (server and web)
        
		// Use this for pw and default-pw.
        public string function hashAdministrator(required string pass, string salt='') {

				// If this is a salted hash, append the salt
				if( len( arguments.salt) ) {
					arguments.pass &= ':' & arguments.salt;
				}
				
                MessageDigest = createObject('java','java.security.MessageDigest');

                for(i=1; i<=5; i++) {
                        md = MessageDigest.getInstance('SHA-256');
                        md.update(pass.getBytes('UTF-8'));
                        pass = enc(md.digest());
                }
                return pass;
        }
        
        // This is deprecated. Use hasAdminstrator instead.
        public string function encryptAdministrator(required string pass) {
                return _encrypt(arguments.pass,variables.administratorSalt);
        }

        // This is deprecated. 
        public string function decryptAdministrator(required string pass) {
                return _decrypt(arguments.pass,variables.administratorSalt);
        }

        // Data source passwords
        public string function encryptDataSource(required string pass) {
                return _encrypt(arguments.pass,variables.dataSourceSalt);
        }

        public string function decryptDataSource(required string pass) {
                return _decrypt(arguments.pass,variables.dataSourceSalt);
        }

		// **************************************************************************************************************
        // Internal private methods
		// **************************************************************************************************************
		
        private string function _encrypt(required string pass, required string salt) {
                var cypher = createobject("java", "lucee.runtime.crypt.BlowfishEasy").init(arguments.salt);
                return cypher.encryptString(arguments.pass);
        }

        private string function _decrypt(required string pass, required string salt) {
                var cypher = createobject("java", "lucee.runtime.crypt.BlowfishEasy").init(arguments.salt);
                return cypher.decryptString(arguments.pass);
        }
        
		// Encode a string as lowercase hex
        private string function enc(strArr) {
                //local.strArr = str.getBytes('UTF-8');
                local.hex = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'];

                savecontent variable="local.out" {
                        for (local.item in strArr) {
                                writeOutput(hex[bitshrn(bitAnd(240,local.item),4)+1]);
                                writeOutput(hex[bitAnd(15,local.item)+1]);
                        }
                };
                return local.out;
        }


}


