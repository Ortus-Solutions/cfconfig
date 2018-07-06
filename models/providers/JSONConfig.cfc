/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
* 
* I represent the behavior of reading and writing CF engine config in JSON format
* I extend the BaseConfig class, which represents the data itself.
*/
component accessors=true extends='cfconfig-services.models.BaseConfig' {
	
	/**
	* Constructor
	*/
	function init() {		
		super.init();
		
		setFormat( 'JSON' );
		setVersion( '*' );
		
		return this;
	}

	/**
	* I read in config from a base JSON format
	*
	* @CFHomePath The JSON file to read from
	*/
	function read( string CFHomePath ){
		// Override what's set if a path is passed in
		setCFHomePath( arguments.CFHomePath ?: getCFHomePath() );
		var thisCFHomePath = getCFHomePath();
		
		if( !len( thisCFHomePath ) ) {
			throw 'No CF home specified to read from';
		}
		
		// If the path doesn't end with .json and doesn't point to a JSON file, assume it's just the directory
		if( right( thisCFHomePath, 5 ) != '.json' && !( fileExists( thisCFHomePath ) && isJSON( fileRead( thisCFHomePath ) ) ) ) {
			thisCFHomePath = thisCFHomePath.listAppend( '.CFConfig.json', '/' );
		}		
		
		if( !fileExists( thisCFHomePath ) ) {
			throw "CF home doesn't exist [#thisCFHomePath#]";
		}
		
		var thisConfigRaw = fileRead( thisCFHomePath );
		
		if( !isJSON( thisConfigRaw ) ) {
			throw "Config file doesn't contain JSON [#thisCFHomePath#]";
		}
		
		var thisConfig = deserializeJSON( thisConfigRaw );
		setMemento( thisConfig );
		return this;
	}

	/**
	* I write out config from a base JSON format
	*
	* @CFHomePath The JSON file to write to
	*/
	function write( string CFHomePath ){
		// Override what's set if a path is passed in
		setCFHomePath( arguments.CFHomePath ?: getCFHomePath() );
		var thisCFHomePath = getCFHomePath();
		
		if( !len( thisCFHomePath ) ) {
			throw 'No CF home specified to write to';
		}
		
		// If the path doesn't end with .json and doesn't point to a JSON file, assume it's just the directory
		if( right( thisCFHomePath, 5 ) != '.json' && !( fileExists( thisCFHomePath ) && isJSON( fileRead( thisCFHomePath ) ) ) ) {
			thisCFHomePath = thisCFHomePath.listAppend( '.CFConfig.json', '/' );
		}
		
		var thisConfigRaw = serializeJSON( getMemento() );
		// Ensure the parent directories exist
		directoryCreate( path=getDirectoryFromPath( thisCFHomePath ), createPath=true, ignoreExists=true );
		fileWrite( thisCFHomePath, JSONPrettyPrint.formatJson( thisConfigRaw ) );
		return this;
	}
		
}