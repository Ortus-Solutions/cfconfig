<cfscript>
/*	baseConfig = new models.baseConfig();
	baseConfig.setNullSupport( true );
	baseConfig.setUseTimeServer( true );
	baseConfig.setDatasources( { foo:{}, bum:{} } );
	baseConfig.addDatasource( 'brad', 'wood', true, 15 );
	baseConfig.setCFMappings( [4,5,6] );
	baseConfig.setErrorStatusCode( 501 );
	writeDump(baseConfig.getMemento() );
	baseConfig.setCFHomePath( expandPath( '/' ) );
	baseConfig.write();
	
	
	baseConfig2 = new models.baseConfig()
		.setCFHomePath( expandPath( '/' ) )
		.read();
	
	writeDump(baseConfig2.getMemento() );
	writeDump(baseConfig2.toString() );*/
	
	Lucee4ServerConfig = new models.Lucee4ServerConfig()
		.setCFHomePath( expandPath( '/tests/resources/lucee4ServerHome/lucee-server' ) )
		.read();
		
	writeDump(Lucee4ServerConfig.getMemento() );
	Lucee4ServerConfig.write( expandPath( '/lucee-server-new.xml' ) );
	
</cfscript>