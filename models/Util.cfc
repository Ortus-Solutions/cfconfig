/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
* 
*/
component singleton {
	
	/**
	 * Pretty JSON
	 * @json.hint A string containing JSON, or a complex value that can be serialized to JSON
 	 **/
	public function formatJson( json ) {
		
		// Overload this method to accept a struct or array
		if( !isSimpleValue( arguments.json ) ) {
			arguments.json = serializeJSON( arguments.json );
		}
		
		var retval = createObject('java','java.lang.StringBuilder').init('');
		var str = json;
	    var pos = 0;
	    var strLen = str.length();
		var indentStr = '    ';
	    var newLine = chr( 13 ) & chr( 10 );
		var char = '';
		var inQuote = false;
		var isEscaped = false;

		for (var i=0; i<strLen; i++) {
			char = str.substring(i,i+1);
			
			if( isEscaped ) {
				isEscaped = false;
				retval.append( char );
				continue;
			}
			
			if( char == '\' ) {
				isEscaped = true;
				retval.append( char );
				continue;
			}
			
			if( char == '"' ) {
				if( inQuote ) {
					inQuote = false;
				} else {
					inQuote = true;					
				}
				retval.append( char );
				continue;
			}
			
			if( inQuote ) {
				retval.append( char );
				continue;
			}	
			
			
			if (char == '}' || char == ']') {
				retval.append( newLine );
				pos = pos - 1;
				for (var j=0; j<pos; j++) {
					retval.append( indentStr );
				}
			}
			retval.append( char );
			if (char == '{' || char == '[' || char == ',') {
				retval.append( newLine );
				if (char == '{' || char == '[') {
					pos = pos + 1;
				}
				for (var k=0; k<pos; k++) {
					retval.append( indentStr );
				}
			}
		}
		return retval.toString();
	}

	/**
	* Returns a single-level metadata struct that includes all items inhereited from extending classes.
	*/
	function getInheritedMetaData( thisComponent, md={} ) {

		// First time through, get metaData of thisComponent.
		if( structIsEmpty( md ) ) {
			if( isObject( thisComponent ) ) {
				md = getMetaData(thisComponent);
			} else {
				md = getComponentMetaData(thisComponent);
			}
		}

		// If it has a parent, stop and calculate it first

		if( structKeyExists( md, 'extends' ) AND md.type eq 'component' ) {
			local.parent = getInheritedMetaData( thisComponent=thisComponent, md=md.extends );
		// If we're at the end of the line, it's time to start working backwards so start with an empty struct to hold our condensesd metadata.
		} else {
			local.parent = {};
			local.parent.inheritancetrail = [];
		}

		// Override ourselves into parent
		for( local.key in md ) {
			// Functions and properties are an array of structs keyed on name, so I can treat them the same
			if( listFindNoCase("functions,properties",local.key) ) {
				if( !structKeyExists(local.parent, local.key) ) {
					local.parent[local.key] = [];
				}
				// For each function/property in me...
				for( local.item in md[local.key] ) {
					local.parentItemCounter = 0;
					local.foundInParent = false;
					// ...Look for an item of the same name in my parent...
					for( local.parentItem in local.parent[local.key] ) {
						local.parentItemCounter++;
						// ...And override it
						if( compareNoCase(local.item.name,local.parentItem.name) eq 0 ) {
							local.parent[local.key][local.parentItemCounter] = local.item;
							local.foundInParent = true;
							break;
						}
					}
					// ...Or add it
					if( not local.foundInParent ) {
						arrayAppend(local.parent[local.key], local.item);
					}
				}
			} else if( !listFindNoCase("extends,implements", local.key) ) {
				local.parent[local.key] = md[local.key];
			}
		}
		arrayPrePend(local.parent.inheritanceTrail, local.parent.name);
		return local.parent;
	}

}