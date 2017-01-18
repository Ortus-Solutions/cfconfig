<cfscript>

	Lucee4ServerConfig = new models.Lucee4ServerConfig()
		.setCFHomePath( expandPath( '/tests/resources/lucee4ServerHome/lucee-server' ) )
		.read();
		
	writeDump(Lucee4ServerConfig.getMemento() );
	Lucee4ServerConfig.write( expandPath( '/lucee-server-new.xml' ) );
	
	baseConfig = new models.baseConfig()
		.setMemento( Lucee4ServerConfig.getMemento() )
		.write( expandPath( '/' ) );
		
	baseConfig2 = new models.baseConfig()
		.read( expandPath( '/.CFConfig.json' ) );
	
	Lucee4ServerConfig2 = new models.Lucee4ServerConfig()
		.setMemento( baseConfig2.getMemento() )		
		.write( expandPath( '/lucee-server-new2.xml' ) );
	
	
</cfscript>