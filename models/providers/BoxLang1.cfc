
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
		var configData = readJSONC( configFilePath );

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

		// Convert customComponentsDirectory to CustomTagPaths  and each mapping becomes a struct of data
		if( configData.keyExists( 'customComponentsDirectory' ) ) {
			// BoxLang uses a different key for mappings
			configData.CustomTagPaths = configData.customComponentsDirectory.map( function( physical ) {
				return {
					'physical' : physical
				};
			} );
			configData.delete( 'customComponentsDirectory' );
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

		// Convert validTemplateExtensions to compileExtForCFInclude
		if( configData.keyExists( 'validTemplateExtensions' ) ) {
			configData[ 'compileExtForCFInclude' ] = arrayToList( configData.validTemplateExtensions );
			configData.delete( 'validTemplateExtensions' );
		}

		// Convert debugMode to debuggingEnabled
		if( configData.keyExists( 'debugMode' ) ) {
			configData[ 'debuggingEnabled' ] = configData.debugMode;
			configData.delete( 'debugMode' );
		}

		// Convert whitespaceCompressionEnabled to whitespaceManagement
		if( configData.keyExists( 'whitespaceCompressionEnabled' ) ) {
			configData[ 'whitespaceManagement' ] = translateWhitespaceFromBoxLang( configData.whitespaceCompressionEnabled );
			configData.delete( 'whitespaceCompressionEnabled' );
		}

		// Convert disallowedFileOperationExtensions to blockedExtForFileUpload
		if( configData.keyExists( 'disallowedFileOperationExtensions' ) ) {
			configData[ 'blockedExtForFileUpload' ] = arrayToList( configData.disallowedFileOperationExtensions );
			configData.delete( 'disallowedFileOperationExtensions' );
		}

		if ( configData.keyExists( 'logging' )) {
			// Convert logsDirectory to logDirectory
			if( configData.logging.keyExists( 'logsDirectory' ) ) {
				configData[ 'logDirectory' ] = configData.logging.logsDirectory;
			}
			// Convert maxFileSize to logMaxFileSize
			if( configData.logging.keyExists( 'maxFileSize' ) ) {
				configData[ 'logMaxFileSize' ] = convertFileSizeToKB( configData.logging.maxFileSize );
			}
		}

		// Check if 'experimental' struct exists and map specific properties
		if ( configData.keyExists( 'experimental' )) {
			// Map experimental.compiler to experimentalCompiler
			if ( configData.experimental.keyExists( 'compiler' )) {
				configData[ 'experimentalCompiler' ] = configData.experimental[ 'compiler' ];
			}
			// Map experimental.ASTCapture to experimentalASTCapture
			if ( configData.experimental.keyExists( 'ASTCapture' ) ) {
				configData['experimentalASTCapture'] = configData.experimental[ 'ASTCapture' ];
			}

			// Remove the experimental struct from configData to avoid redundancy
			configData.delete( 'experimental' );
		}

		// handle trusted cache, but the opposite of below
		if( configData.keyExists( 'trustedCache' ) ) {
			if( configData.trustedCache ) {
				configData[ 'inspectTemplate' ] = 'never';
			} else {
				configData[ 'inspectTemplate' ] = 'always';
			}
			configData.delete( 'trustedCache' );
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

		// Convert CustomTagPaths to customComponentsDirectory and each mapping struct becomes a string
		if( configData.keyExists( 'CustomTagPaths' ) ) {
			// BoxLang uses a different key for customComponentsDirectory
			configData[ 'customComponentsDirectory' ] = configData.CustomTagPaths
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

		// Convert compileExtForCFInclude to validTemplateExtensions
		if( configData.keyExists( 'compileExtForCFInclude' ) ) {
			configData[ 'validTemplateExtensions' ] = listToArray( configData.compileExtForCFInclude );
			configData.delete( 'compileExtForCFInclude' );
		}

		// Convert debuggingEnabled to debugMode
		if( configData.keyExists( 'debuggingEnabled' ) ) {
			configData[ 'debugMode' ] = configData.debuggingEnabled;
			configData.delete( 'debuggingEnabled' );
		}

		// Convert whitespaceCompressionEnabled to whitespaceCompressionEnabled
		if( configData.keyExists( 'whitespaceManagement' ) ) {
			configData[ 'whitespaceCompressionEnabled' ] = translateWhitespaceToBoxLang( configData.whitespaceManagement );
			configData.delete( 'whitespaceManagement' );
		}

		// Convert blockedExtForFileUpload to disallowedFileOperationExtensions
		if( configData.keyExists( 'blockedExtForFileUpload' ) ) {
			configData[ 'disallowedFileOperationExtensions' ] = listToArray( configData.blockedExtForFileUpload );
			configData.delete( 'blockedExtForFileUpload' );
		}

		// Convert logDirectory to logging.logsDirectory
		if( configData.keyExists( 'logDirectory' ) ) {
			configData[ 'logging' ] [ 'logsDirectory' ] = configData[ 'logDirectory' ];
			configData.delete( 'logDirectory' );
		}
		// Convert logMaxFileSize to maxFileSize
		if( configData.keyExists( 'logMaxFileSize' ) ) {
			configData[ 'logging' ] [ 'maxFileSize' ] = convertFileSizeKBToMB( configData.logMaxFileSize );
			configData.delete( 'logMaxFileSize' );
		}

		// Check for experimental settings
		if ( configData.keyExists( 'experimentalCompiler' ) ) {
			configData[ 'experimental' ] [ 'compiler' ] = configData[ 'experimentalCompiler' ];
			// Remove to avoid duplication
			configData.delete( 'experimentalCompiler' ); 
		}
		if (configData.keyExists( 'experimentalASTCapture' )) {
			configData[ 'experimental' ] [ 'ASTCapture' ] = configData[ 'experimentalASTCapture' ];
			// Remove to avoid duplication
			configData.delete( 'experimentalASTCapture' ); 
		}

		// One of the strings "never", "once", "always"
		if( configData.keyExists( 'inspectTemplate') ) {
			if( configData.inspectTemplate eq 'never' ) {
				configData[ 'trustedCache' ] = true;
			} else {
				configData[ 'trustedCache' ] = false;
			}
			configData.delete( 'inspectTemplate' );
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

	/**
	 * I translate the whitespace management setting from the CFConfig format to the BoxLang format
	 * 
	 * @whitespaceManagement The whitespace management setting from the CFConfig format
	 */
	private function translateWhitespaceToBoxLang( required string whitespaceManagement ) {
		switch( whitespaceManagement ) {
			case 'off' :
			case 'regular' :
				return false;
			case 'simple' :
			case 'white-space' :
				return true;
			case 'smart' :
			case 'white-space-pref' :
				return true;
			default :
				return false;
		}
	}

	private function translateWhitespaceFromBoxLang( required string whitespaceManagement ) {
		switch( whitespaceManagement ) {
			case false :
				return 'off';
			case true :
				return 'smart';
			default :
				return 'off';
		}
	}

	/**
	 * Converts a file size string (e.g., "100MB") to KB.
	 * @param {string} fileSize - The file size string, e.g., "100MB", "2GB", "500KB".
	 * @return {numeric} - The file size in KB.
	 */
	private function convertFileSizeToKB( fileSize ) {
		// Validate input
		if (!len( fileSize ) or !refind( "^\d+(KB|MB|GB)$", fileSize ) ) {
			throw( "InvalidFormat: #fileSize#", "File size must be in the format: <number><unit> (e.g., 100MB, 2GB, 500KB)" );
		}
	
		// Extract number and unit
		var size = val( reReplace( fileSize, "[^\d]", "", "ALL" ) );
		var unit = uCase( reReplace( fileSize, "\d", "", "ALL" ) );
	
		// Conversion factors
		var conversionFactors = {
			"KB": 1,
			"MB": 1024,
			"GB": 1024 * 1024
		};
	
		// Calculate file size in KB
		if ( !structKeyExists( conversionFactors, unit ) ) {
			throw( "InvalidUnit", "Unsupported unit: " & unit );
		}
	
		return size * conversionFactors[ unit ];
	}

	/**
	 * Converts file size from KB to MB which is the default format in BoxLang
	 * @param {numeric} fileSizeKB - The file size in KB
	 * @return {string} - The file size in MB
	 */
	function convertFileSizeKBToMB( fileSizeKB ) {
		if ( !isNumeric( fileSizeKB ) or fileSizeKB lt 0 ) {
			throw( "InvalidValue", "File size in KB must be a non-negative number." );
		}
	
		return round(fileSizeKB / 1024) & "MB";
	}

}