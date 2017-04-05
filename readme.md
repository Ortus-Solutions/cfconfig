```
   ____ _____ ____             __ _       
  / ___|  ___/ ___|___  _ __  / _(_) __ _ 
 | |   | |_ | |   / _ \| '_ \| |_| |/ _` |
 | |___|  _|| |__| (_) | | | |  _| | (_| |
  \____|_|   \____\___/|_| |_|_| |_|\__, |
                                    |___/ 
```

This is a library for reading, writing, and storing configuration for all CF engines. This is an underlying service layer meant to have other tools built on top of it.

## Main Features

1. Generic JSON storage of any CF engine's settings
2. Engine-specific mappings for all major engines to convert their config to and from the generic JSON format

This does not use RDS and doesn't need the server to be running.  It just needs access to the installation folder for a server to locate its config files. 

## Possible Uses

Uses for this library include but are not limited to:

* Export config from a server as a backup
* Import config to a server to speed/automate setup
* Copy config from one server to another.  Servers could be different engines-- i.e. copy config from Adobe CF11 to Lucee 5.
* Merge config from multiple servers together. Ex: combine several Lucee web contexts into a single config (mappings, datasources, etc)
* Facilitate the external management of any server's settings (such as CLI tools to read or set settings)

## Completeness

This project is a work in progress.  I'm starting with the most common engines and the most common config settings so it's possible you may find an engine
or config setting that's not supported yet.  Please submit pull requests for these.  It's not hard, it's just tedious to do all the copy/paste.  I'd *love* collaborate on this project

If you don't have time for a pull request, please enter a ticket so we can track remaining features.  

Major features left to develop
* **Adobe CF9** - Everything
* **Adobe CF10** - Everything
* **Adobe CF11** - In progress...
* **Adobe C2016** - In progress...
* **Railo 4.x** - Everything-- probably can heavily re-use from Lucee 4.x
* **Lucee 4.x/5.x** - custom tags, debugging, REST mappings, error settings, component settings

## Component Overview

Here are the main components in the project

### BaseConfig

This class represents the configuration of a CF engine.  It is agnostic and doesn't contain any particular behavior for a specific engine.  
Not all the data it stores applies to every engine though.  It is capable of reading and writing to a standard JSON format, but if you want to read or write to/from a specific engine's format, you'll need to create one of the engine-specific subclasses

### Engine-specific mappers

* **JSONConfig** - Engine-agnostic JSON format
* **Lucee4Server** - Lucee 4.x server context
* **Lucee4Web** - Lucee 4.x web context
* **Lucee5Server** - Lucee 5.x server context
* **Lucee5Web** - Lucee 5.x web context
* **Adobe9** - Coming soon
* **Adobe10** - Coming soon
* **Adobe11** - Adobe ColdFusion 11
* **Adobe2016** - Adobe Coldfusion 2016

## Usage

Each of the components above supports these public methods:

* `setCFHomePath()` - Points to the server home where the config files are to be read or written.
* `read( CFHomePath )` - Extract the config from the files found in the server home.  You can override `CFHomePath` here too.
* `write( CFHomePath )` - Write the config out to the files in the server home whether or not they already exist.  You can override `CFHomePath` here too.
* `getMemento()` - Return all configuration in as a raw CFML data structure.  Useful for passing config values to another instance.
* `setMemento()` - Accept configuration as a raw CFML data structure.  Useful for accepting another instance's data.

Create an instance of the component that corresponds to the server that you'd like to read or write config settings from, or the `BaseConfig` class if you want to deal with the generic JSON-based config.

**Create a new JSON configuration file programmatically**
```
baseConfig = new path.to.baseConfig()
	.setNullSupport( true );
	.setUseTimeServer( true );
	.setAdminPassword( 'myPass' );
	.addCFMapping( '/foo', '/bar' );
	.write();
 ```

**Read an existing JSON configuration file**
```
baseConfig = new path.to.baseConfig()
	.read( 'test.json' );
```

**Read an existing Lucee 4 server configuration file**
```
lucee4ServerConfig = new path.to.Lucee4ServerConfig()
	.setCFHomePath( expandPath( '/path/to/lucee-server' ) )
	.read();
	
writeDump( lucee4ServerConfig.getMemento() );
```

**Read an existing JSON config file and load into a Lucee 5 web context**
```
JSONConfig = new path.to.baseConfig()
	.read( expandPath( '.CFConfig.json' ) );

new models.Lucee4WebConfig()
	.setMemento( JSONConfig.getMemento() )		
	.write( expandPath( 'WEB-INF/lucee/' ) );
```

## Notes

The `BaseConfig` will read/write to a JSON file called `.CFConfig.json` by default in the home directory you specify.  You can alternatively specify a full path
to a JSON file to change the name. 

The Lucee 4 and Lucee 5 *web* components expect the `CFHomePath` to be the folder containing the `lucee-web.xml.cfm` file.  
An example would be:
```
<webroot>/WEB-INF/lucee/
```

The Lucee 4 and Lucee 5 *server* components expect the `CFHomePath` to be the `lucee-server` folder containing the `/context/lucee-server.xml` file.  
An example would be:
```
/opt/lucee/lib/lucee-server/
```

The Adobe components expect the `CFHomePath` to be the `cfusion` folder that contains the `lib/neo-runtime.xml` file.  
An example would be:
```
C:/ColdFusion11/cfusion/
```
