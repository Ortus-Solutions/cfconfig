<cfscript>

	Lucee4WebConfig = new models.Lucee4WebConfig()
		.setCFHomePath( expandPath( '/tests/resources/lucee4WebHome/' ) )
		.read();
		
	writeDump(Lucee4WebConfig.getMemento() );
	Lucee4WebConfig.write( expandPath( '/lucee-web-new.xml' ) );
	
	baseConfig = new models.baseConfig()
		.setMemento( Lucee4WebConfig.getMemento() )
		.write( expandPath( '/' ) );
		
	baseConfig2 = new models.baseConfig()
		.read( expandPath( '/.CFConfig.json' ) );
	
	Lucee4WebConfig2 = new models.Lucee4WebConfig()
		.setMemento( baseConfig2.getMemento() )		
		.write( expandPath( '/lucee-web-new2.xml' ) );
	
	
</cfscript>