<cfscript>

	Adobe11Config = new models.Adobe11Config()
		.setCFHomePath( expandPath( '/tests/resources/adobe11/ServerHome/WEB-INF/cfusion' ) )
		.read();
		
	writeDump( Adobe11Config.getMemento() );
	
	
</cfscript>