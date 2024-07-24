
/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
*
* I represent the behavior of reading and writing CF engine config in the format compatible with a BoxLang 1.x server
*/
component accessors=true extends='cfconfig-services.models.BaseConfig' {

	/**
	* Constructor
	*/
	function init() {
		super.init();

		setFormat( 'boxlang' );
		setVersion( '1' );

		return this;
	}


	/**
	* I read in config
	*
	* @CFHomePath The JSON file to read from
	*/
	function read( string CFHomePath ){
		// Override what's set if a path is passed in
		setCFHomePath( arguments.CFHomePath ?: getCFHomePath() );

		if( !len( getCFHomePath() ) ) {
			throw 'No CF home specified to read from';
		}

		var configFilePath = getCFHomePath() & '/boxlang.json';
		configData = readJSONC( configFilePath );

		// Escape any BoxLang system settings like ${user-dir} that CommandBox shouldn't bother with
		configData = escapeDeepSystemSettings( configData );

		// Transformations for any place BoxLang doesn't directly follow the CFConfig spec

		// Convert mappings to CFMappings and each mapping becomes a struct of data
		if( configData.keyExists( 'mappings' ) ) {
			// BoxLang uses a different key for mappings
			configData.CFMappings = configData.mappings.map( function( virtual, physical ) {
				return {
					'physical' : physical
				};
			} );
			configData.delete( 'mappings' );
		}

		// Convert customTagsDirectory to CustomTagPaths  and each mapping becomes a struct of data
		if( configData.keyExists( 'customTagsDirectory' ) ) {
			// BoxLang uses a different key for mappings
			configData.CustomTagPaths = configData.customTagsDirectory.map( function( physical ) {
				return {
					'physical' : physical
				};
			} );
			configData.delete( 'customTagsDirectory' );
		}

		// Convert timezone to thisTimezone
		if( configData.keyExists( 'timezone' ) ) {
			configData[ 'thisTimezone' ] = configData.timezone;
			configData.delete( 'timezone' );
		}

		// Convert locale to thisLocale
		if( configData.keyExists( 'locale' ) ) {
			configData[ 'thisLocale' ] = configData.locale;
			configData.delete( 'locale' );
		}
		
		
		setMemento( configData );
		return this;
	}

	/**
	* I write out config from a base JSON format
	*
	* @CFHomePath The JSON file to write to
	*/
	function write( string CFHomePath, pauseTasks=false ){
		setCFHomePath( arguments.CFHomePath ?: getCFHomePath() );
		var thisCFHomePath = getCFHomePath();

		// Check to see if this mapping exists so we are compat with older versions of CommandBox
		if( wirebox.getBinder().mappingExists( 'SystemSettings' ) ) {
			var systemSettings = wirebox.getInstance( 'SystemSettings' );
			// Swap out stuff like ${foo}
			setMemento( systemSettings.expandDeepSystemSettings( getMemento() ) );
		}

		if( !len( thisCFHomePath ) ) {
			throw 'No CF home specified to write to';
		}

		var configFilePath = getCFHomePath() & '/boxlang.json';
		var configData = getMemento();

		// Transformations for any place BoxLang doesn't directly follow the CFConfig spec

		// Convert CFMappings to mappings and each mapping struct becomes a string
		if( configData.keyExists( 'CFMappings' ) ) {
			// BoxLang uses a different key for mappings
			configData[ 'mappings' ] = configData.CFMappings
				.filter( (virtual, mappingStruct) => mappingStruct.keyExists( 'physical' ) )	
				.map( ( virtual, mappingStruct ) => mappingStruct.physical );
			configData.delete( 'CFMappings' );
		}

		// Convert CustomTagPaths to customTagsDirectory and each mapping struct becomes a string
		if( configData.keyExists( 'CustomTagPaths' ) ) {
			// BoxLang uses a different key for customTagsDirectory
			configData[ 'customTagsDirectory' ] = configData.CustomTagPaths
				.filter( ( mappingStruct) => mappingStruct.keyExists( 'physical' ) )
				.map( ( mappingStruct ) => mappingStruct.physical );
			configData.delete( 'CustomTagPaths' );
		}
	
		// Convert thisTimezone to timezone
		if( configData.keyExists( 'thisTimezone' ) ) {
			configData[ 'timezone' ] = configData.thisTimezone;
			configData.delete( 'thisTimezone' );
		}

		// Convert thisLocale to locale
		if( configData.keyExists( 'thisLocale' ) ) {
			configData[ 'locale' ] = configData.thisLocale;
			configData.delete( 'thisLocale' );
		}

		// Ensure the parent directories exist
		directoryCreate( path=getDirectoryFromPath( configFilePath ), createPath=true, ignoreExists=true );
		var existingData = {};
		// merge with existing data
		if( fileExists( configFilePath ) ) {
			existingData = readJSONC( configFilePath );
			mergeMemento( configData, existingData )
		} else {
			existingData = configData;
		}
		
		// Make sure this never makes it to the hard drive
		structDelete( existingData, 'adminPassword' );
		fileWrite( configFilePath, JSONPrettyPrint.formatJson( serializeJSON( existingData ) ) );

		return this;
	}

}