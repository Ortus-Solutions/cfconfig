# CF Config

This is a library for reading, writing, and storing configuration for all CF engines. This is an underlying service layer meant to have other tools built on top of it.

## Main Features

1. Generic JSON storage of CF engine settings
2. Engine-specific mappings for all major engines to convert their config to and from the generic JSON format

This does not use RDS and doesn't need the server to be running.  It just needs access to the installation folder for a server to locate it's config files. 

## Possible Uses

Uses for this library include but are not limited to:

* Export config from a server as a backup
* Import config to a server to speed/automate setup
* Copy config from one server to another.  Servers could be different engines-- i.e. copy config from Adobe CF11 to Lucee 5.
* Merge config from multiple servers together. Ex: combine several Lucee web contexts into a single config (mappings, datasources, etc)
* Facilitate the external management of any server's settings (such as CLI tools to read or set settings)

## Completeness

This project is a word in progress.  I'm starting with the most common engines and the most common config settings so it's possible you may find an engine
or config setting that's not supported.  Please submit pull requests for these.  It's not hard, it's just tedious to do all the copy/paste.  
If you don't have time for a pull reqyest, please enter a ticket so we can track remaining features.  

## Component Overview

Here are the main components in the project

### BaseConfig

I represent the configuration of a CF engine.  I am agnostic and don't contain any particular behavior for a specific engine.  
Not all the data I store applies to every engine though.  I am capable of reading and writing to a standard JSON format, but if you want to read or write to/from a specific engine's format, you'll need to create one of my subclasses

### Engine-specific mappers

* **Lucee4ServerConfig** - Lucee 4.x server context
* **Lucee4WebConfig** - Lucee 4.x web context
* **Lucee5ServerConfig** - Lucee 5.x server context
* **Lucee5WebConfig** - Lucee 4.x web context

## Usage

Each of the components above supports these public methods:

* `setCFHomePath()` - Points to the server home where the config files are to be read or written.
* `read( CFHomePath )` - Extract the config from the files found in the server home.  You can override `CFHomePath` here too.
* `write( CFHomePath )` - Write the config out to the files in the server home whether or not they already exist.  You can override `CFHomePath` here too.
* `getMemento()` - Return all configuration in as a raw CFML data structure.  Useful for passing config values to another instance.
* `setMemento()` - Accept configuration as a raw CFML data structure.  Useful for accepting another instances data.

Create an instance of the component that corresponds to the server that you'd like to read or write config settings from, or the `BaseConfig` class if you want to deal with JSON-based config.

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
to a JSON to change the name. 

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

