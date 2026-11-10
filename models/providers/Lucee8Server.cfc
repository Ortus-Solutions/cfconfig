/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
*
* I represent the behavior of reading and writing CF engine config in the format compatible with a Lucee 8.x server context
* I extend the Lucee7Server class. Lucee 8 has no web context, so there is no Lucee8Web provider.
*
* Lucee 8 changes to .CFConfig.json (https://docs.lucee.org/recipes/breaking-changes-8-0.html#configuration-cfconfig-json):
* - Debugging/monitoring keys are only read from inside the "monitoring" section
* - Default cache keys are only read from inside the "cache" section (without the "cacheDefault" prefix)
* - Update proxy keys are only read from inside the "proxy" section (server, port, username, password)
* - extensionProviders are Maven group IDs. URL based providers are ignored.
* Lucee 8 silently ignores these keys at the top level, so we nest them on write and flatten them on read.
*/
component accessors=true extends='cfconfig-services.models.providers.Lucee7Server' {

	/**
	* Constructor
	*/
	function init() {
		super.init();

		setVersion( '8' );

		// Keys that Lucee 8 only reads from inside a section.
		// section: the Lucee 8 section name
		// lucee: the key name Lucee 8 uses inside the section
		// cfconfig: the CFConfig property name
		// aliases: other names Lucee 7.1 accepted for the same setting (top level or inside the section)
		variables.sectionKeys = [
			// Monitoring / debugging
			{ section : 'monitoring', lucee : 'showDebug', cfconfig : 'debuggingEnabled', aliases : [ 'showDebug' ] },
			{ section : 'monitoring', lucee : 'debuggingDatabase', cfconfig : 'debuggingDBEnabled', aliases : [ 'debuggingDatabase', 'debuggingShowDatabase' ] },
			{ section : 'monitoring', lucee : 'debuggingException', cfconfig : 'debuggingExceptionsEnabled', aliases : [ 'debuggingException', 'debuggingShowException' ] },
			{ section : 'monitoring', lucee : 'debuggingTemplate', cfconfig : 'debuggingTemplate', aliases : [ 'debuggingShowTemplate' ] },
			{ section : 'monitoring', lucee : 'debuggingDump', cfconfig : 'debuggingDumpEnabled', aliases : [ 'debuggingDump', 'debuggingShowDump' ] },
			{ section : 'monitoring', lucee : 'debuggingTracing', cfconfig : 'debuggingTracingEnabled', aliases : [ 'debuggingTracing', 'debuggingShowTracing', 'debuggingShowTrace' ] },
			{ section : 'monitoring', lucee : 'debuggingTimer', cfconfig : 'debuggingTimerEnabled', aliases : [ 'debuggingTimer', 'debuggingShowTimer' ] },
			{ section : 'monitoring', lucee : 'debuggingImplicitAccess', cfconfig : 'debuggingImplicitVariableAccessEnabled', aliases : [ 'debuggingImplicitAccess', 'debuggingImplicitVariableAccess', 'debuggingShowImplicitAccess' ] },
			{ section : 'monitoring', lucee : 'debuggingQueryUsage', cfconfig : 'debuggingQueryUsageEnabled', aliases : [ 'debuggingQueryUsage', 'debuggingShowQueryUsage' ] },
			{ section : 'monitoring', lucee : 'debuggingThread', cfconfig : 'debuggingThread', aliases : [ 'debuggingShowThread' ] },
			{ section : 'monitoring', lucee : 'showDoc', cfconfig : 'showDoc', aliases : [ 'doc', 'documentation', 'showReference', 'reference' ] },
			{ section : 'monitoring', lucee : 'showMetric', cfconfig : 'showMetric', aliases : [ 'showMetrics', 'metric', 'metrics' ] },
			{ section : 'monitoring', lucee : 'showTest', cfconfig : 'showTest', aliases : [ 'showTests', 'test' ] },
			// Update proxy
			{ section : 'proxy', lucee : 'server', cfconfig : 'updateProxyHost', aliases : [] },
			{ section : 'proxy', lucee : 'port', cfconfig : 'updateProxyPort', aliases : [] },
			{ section : 'proxy', lucee : 'username', cfconfig : 'updateProxyUsername', aliases : [] },
			{ section : 'proxy', lucee : 'password', cfconfig : 'updateProxyPassword', aliases : [] }
		];
		// Default caches
		for( var cacheType in getCacheTypes() ) {
			variables.sectionKeys.append( { section : 'cache', lucee : 'default' & cacheType, cfconfig : 'cacheDefault' & cacheType, aliases : [] } );
		}

		// Timespans Lucee 8 stores as { "span" : "d,h,m,s" } instead of a plain "d,h,m,s" string
		variables.spanKeys = [ 'requestTimeout' ];

		return this;
	}

	/**
	* Every Lucee 8 JSON file we read gets its sectioned keys flattened back to top level CFConfig names.
	* This covers both read() and the merge with the existing file inside write().
	*/
	any function readJSONC( string configFilePath ) {
		var configData = super.readJSONC( arguments.configFilePath );
		if( isStruct( configData ) ) {
			flattenSectionKeys( configData );
			unwrapSpans( configData );
		}
		return configData;
	}

	/**
	* I write out config from a base JSON format
	*
	* @CFHomePath The JSON file to write to
	*/
	function write( string CFHomePath, pauseTasks=false ){
		// Let Lucee 6/7 logic do the heavy lifting, then fix up the file for Lucee 8
		super.write( argumentCollection=arguments );

		var configFilePath = calculateConfigFilePath();
		// readJSONC() flattens, nestSectionKeys() puts everything where Lucee 8 expects it
		var configData = readJSONC( configFilePath );
		nestSectionKeys( configData );
		wrapSpans( configData );
		normalizeExtensionProvidersForWrite( configData );

		fileWrite( configFilePath, JSONPrettyPrint.formatJson( serializeJSON( configData ) ) );

		return this;
	}

	/**
	* Move sectioned Lucee 8 keys (and any legacy top level aliases) to their top level CFConfig name.
	* Precedence: value inside the section, then the CFConfig name at top level, then top level aliases.
	*/
	private function flattenSectionKeys( required struct configData ) {
		for( var keyDef in variables.sectionKeys ) {
			var found = false;
			var value = '';

			// Every name this setting may appear under, inside the section
			var sectionNames = [ keyDef.lucee ];
			sectionNames.append( keyDef.aliases, true );
			sectionNames.append( keyDef.cfconfig );

			// Highest precedence: anything inside the section (Lucee 8 name or an alias)
			if( configData.keyExists( keyDef.section ) && isStruct( configData[ keyDef.section ] ) ) {
				var section = configData[ keyDef.section ];
				for( var name in sectionNames ) {
					if( section.keyExists( name ) ) {
						if( !found ) {
							value = section[ name ];
							found = true;
						}
						section.delete( name );
					}
				}
			}

			// Then the CFConfig name at top level
			if( !found && configData.keyExists( keyDef.cfconfig ) ) {
				value = configData[ keyDef.cfconfig ];
				found = true;
			}

			// Lowest precedence: top level aliases (always removed so they don't linger in the file)
			for( var alias in keyDef.aliases ) {
				if( alias != keyDef.cfconfig && configData.keyExists( alias ) ) {
					if( !found ) {
						value = configData[ alias ];
						found = true;
					}
					configData.delete( alias );
				}
			}

			if( found ) {
				configData[ keyDef.cfconfig ] = value;
			}
		}
		// Sections are left in place even if now empty (stock Lucee 8 ships "proxy": {}),
		// so any keys we don't know about are preserved and nestSectionKeys() adds to them.
	}

	/**
	* Move top level CFConfig keys into the section where Lucee 8 expects them.
	* If the section already exists, the keys are added to it.
	*/
	private function nestSectionKeys( required struct configData ) {
		for( var keyDef in variables.sectionKeys ) {
			if( !configData.keyExists( keyDef.cfconfig ) ) {
				continue;
			}
			var value = configData[ keyDef.cfconfig ];
			configData.delete( keyDef.cfconfig );

			// Lucee 8 debuggingTemplate is a boolean. The CFConfig spec also uses it for Adobe's template path (classic.cfm)
			// and Lucee 8 no longer ignores invalid values, so skip anything that isn't a boolean.
			if( keyDef.lucee == 'debuggingTemplate' && !isBoolean( value ) ) {
				continue;
			}

			if( !configData.keyExists( keyDef.section ) || !isStruct( configData[ keyDef.section ] ) ) {
				configData[ keyDef.section ] = {};
			}
			configData[ keyDef.section ][ keyDef.lucee ] = value;
		}
	}

	/**
	* Turn any top level { "span" : "0,0,0,50" } into "0,0,0,50" so it matches the CFConfig spec
	* (and the plain strings used by older Lucee versions and the base template we merge with).
	*/
	private function unwrapSpans( required struct configData ) {
		for( var key in configData ) {
			var value = configData[ key ];
			if( isStruct( value ) && value.count() == 1 && value.keyExists( 'span' ) && isSimpleValue( value.span ) ) {
				configData[ key ] = value.span;
			}
		}
	}

	/**
	* Write timespans back in the { "span" : "..." } form Lucee 8 uses
	*/
	private function wrapSpans( required struct configData ) {
		for( var key in variables.spanKeys ) {
			if( configData.keyExists( key ) && isSimpleValue( configData[ key ] ) ) {
				configData[ key ] = { 'span' : configData[ key ] };
			}
		}
	}

	/**
	* Lucee 8 extensionProviders are Maven group IDs (default org.lucee). URL based providers
	* like https://extension.lucee.org or https://www.forgebox.io are ignored, so drop them.
	*/
	private function normalizeExtensionProvidersForWrite( required struct configData ) {
		if( !configData.keyExists( 'extensionProviders' ) || !isArray( configData.extensionProviders ) ) {
			return;
		}
		configData.extensionProviders = configData.extensionProviders.filter( ( provider ) => {
			return isSimpleValue( provider ) && len( trim( provider ) ) && !reFindNoCase( '^[a-z][a-z0-9+.-]*://', trim( provider ) );
		} );
		// Nothing left, let Lucee use its default
		if( configData.extensionProviders.isEmpty() ) {
			configData.delete( 'extensionProviders' );
		}
	}

}
