<cfscript>
	baseConfig = new models.baseConfig();
	baseConfig.setNullSupport( true );
	baseConfig.setUseTimeServer( true );
	baseConfig.setDatasources( { foo:{}, bum:{} } );
	baseConfig.addDatasource( 'brad', 'wood', true, 15 );
	baseConfig.setCFMappings( [4,5,6] );
	baseConfig.setErrorStatusCode( 501 );
	writeDump(baseConfig.getMemento() );
	baseConfig.setConfigFile( 'test.json' );
	baseConfig.write();
	
	
	baseConfig2 = new models.baseConfig()
		.setConfigFile( 'test.json' )
		.read();
	
	writeDump(baseConfig2.getMemento() );
	
</cfscript>