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