<cfscript>

	Lucee5ServerConfig = new models.Lucee5ServerConfig()
		.setCFHomePath( expandPath( '/tests/resources/lucee5/ServerHome/lucee-server' ) )
		.read();
		
	writeDump(Lucee5ServerConfig.getMemento() );
	Lucee5ServerConfig.write( expandPath( '/lucee-Server-new.xml' ) );
	
	baseConfig = new models.baseConfig()
		.setMemento( Lucee5ServerConfig.getMemento() )
		.write( expandPath( '/' ) );
		
	baseConfig2 = new models.baseConfig()
		.read( expandPath( '/.CFConfig.json' ) );
	
	Lucee5ServerConfig2 = new models.Lucee5ServerConfig()
		.setMemento( baseConfig2.getMemento() )		
		.write( expandPath( '/lucee-Server-new2.xml' ) );
	
	
</cfscript>