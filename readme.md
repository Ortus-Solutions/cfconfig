```
   ____ _____ ____             __ _
  / ___|  ___/ ___|___  _ __  / _(_) __ _
 | |   | |_ | |   / _ \| '_ \| |_| |/ _` |
 | |___|  _|| |__| (_) | | | |  _| | (_| |
  \____|_|   \____\___/|_| |_|_| |_|\__, |
                                    |___/
```

<img src="https://www.ortussolutions.com/__media/logos/CfConfigLogo300.png" class="img-thumbnail"/>

> Copyright 2017 by Ortus Solutions, Corp - https://www.ortussolutions.com

This is a library for reading, writing, and storing configuration for all CF engines. This is an underlying service layer meant to have other tools built on top of it.

Please enter tickets for bugs and enhancements here:
https://ortussolutions.atlassian.net/browse/CFCONFIG

Documentation is found here:
https://cfconfig.ortusbooks.com

## Main Features

1. Generic JSON storage of any CF engine's settings
2. Engine-specific mappings for all major engines to convert their config to and from the generic JSON format

This does not use RDS and doesn't need the server to be running.  It just needs access to the installation folder for a server to locate its config files.

## Uses

Uses for this library include but are not limited to:

* Export config from a server as a backup
* Import config to a server to speed/automate setup
* Copy config from one server to another.  Servers could be different engines-- i.e. copy config from Adobe CF11 to Lucee 5.
* Merge config from multiple servers together. Ex: combine several Lucee web contexts into a single config (mappings, datasources, etc)
* Facilitate the external management of any server's settings (such as CLI tools to read or set settings)
* Compare configuration between two sources

## Supported Engines

CFConfig covers most of the common settings you'll find in Adobe and Lucee servers.  This includes datasources, CF Mappings, Lucee caches, mail servers, logging settings, debugging settings, event gateways (Adobe), scheduled tasks (Adobe), and custom tag paths.

The current list of supported engines is:

* **Adobe ColdFusion 9, 10, 11, 2016, 2018, 2021, 2023**
* **Lucee 4, 5, 6**
* **Railo 4**
* **BoxLang 1**

If you find a setting or feature which is not supported, please send a pull request or add a ticket so we can track it.

## Component Overview

Here are the main components in the project

### BaseConfig.cfc

This class represents the configuration of a CF engine.  It is agnostic and doesn't contain any particular behavior for a specific engine.
Not all the data it stores applies to every engine though.  The `BaseConfig.cfc` is not capable of reading or writing the config, it merely holds the data in a generic manner.  If you want to read or write to/from a specific engine's format, you'll need to create one of the engine-specific subclasses, all of which extend `BaseConfig.cfc`.

### Engine-specific mappers

* **JSONConfig.cfc** - Engine-agnostic JSON format
* **Lucee4Server.cfc** - Lucee 4.x server context
* **Lucee4Web.cfc** - Lucee 4.x web context
* **Lucee5Server.cfc** - Lucee 5.x server context
* **Lucee5Web.cfc** - Lucee 5.x web context
* **Lucee6Server.cfc** - Lucee 6.x server context
* **Lucee6Web.cfc** - Lucee 6.x web context
* **Railo4Server.cfc** - Railo 4.x server context
* **Railo4Web.cfc** - Railo 4.x web context
* **Adobe9.cfc** - Adobe ColdFusion 9
* **Adobe10.cfc** - Adobe ColdFusion 10
* **Adobe11.cfc** - Adobe ColdFusion 11
* **Adobe2016.cfc** - Adobe Coldfusion 2016
* **Adobe2018.cfc** - Adobe Coldfusion 2018
* **Adobe2021.cfc** - Adobe Coldfusion 2021
* **Adobe2023.cfc** - Adobe Coldfusion 2023
* **BoxLang1.cfc** - BoxLang 1.0.0

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
JSONConfig = new path.to.JSONConfig()
	.setNullSupport( true );
	.setUseTimeServer( true );
	.setAdminPassword( 'myPass' );
	.addCFMapping( '/foo', '/bar' );
	.write();
 ```

**Read an existing JSON configuration file**
```
JSONConfig = new path.to.JSONConfig()
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
JSONConfig = new path.to.JSONConfig()
	.read( expandPath( '.CFConfig.json' ) );

new path.to.Lucee4WebConfig()
	.setMemento( JSONConfig.getMemento() )
	.write( expandPath( 'WEB-INF/lucee/' ) );
```

## Notes

The `JSONConfig` will read/write to a JSON file called `.CFConfig.json` by default in the home directory you specify.  You can alternatively specify a full path to a JSON file to change the name.

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

BoxLang servers expect the `CFHomePath` to be the `config` folder containing the `boxlang.json` file.
Ex: C:/users/brad/.boxlang/config/

The code in this library has only been tested on Lucee and likely doesn't work on Adobe ColdFusion.  If anyone wants to make it compatible, feel free to try by beware of tons of use of the Elvis operator, reliance on sorted JSON structs, and some specific WDDX behavior.

## Extending this module/service

Individuals who would like to contribute to this library can follow the steps below to configure this tool to run independently for the purposes of extending and testing the code:

1. This package currently depends on a `cfconfig.local` host entry.  You can add this to your system's `hosts` file manually or leverage a tool like [Commandbox HostUpdater](https://www.forgebox.io/view/commandbox-hostupdater) to add the host entry.
2. Start up this project with CommandBox using `server start` - this will open a browser to the test runner for this project.
3. Happy Contributing!
