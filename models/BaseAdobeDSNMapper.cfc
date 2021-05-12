/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
* 
* This CFC simply breaks out some of the messy code for mapping datasources on Adobe CF. It was getting to be way too much code 
* in the BaseAdobe CFC. Each provider can still have their own subclass of this CFC where they override bits and peices.
*/
component accessors=true {
			
	/**
	* Constructor
	*/
	function init() {
		return this;
	}
	
	/**
	* Take string in the form of foo=bar&baz=bum and convert to a struct of name/value pairs
	*/
	struct function parseCustom( string dbdriver, string custom ) {
		var returnStruct = {};
		
		// Not accounting for any escapes here.  Adjust if neccessary
		for( var prop in custom.listToArray( '&' ) ) {
			returnStruct[ prop.listFirst( '=' ) ] = prop.listRest( '=' );
		}
		
		return returnStruct;	
	}
	
	/**
	* Take a struct of name/value pairs and convert to string in the form of foo=bar&baz=bum or foo=bar;baz=bum depending on the DB type.
	*/
	string function assembleCustom( string dbdriver, struct custom ) {
		var returnString = '';
		var URLDelim = customURLDelimiter( dbdriver );
		
		// Not accounting for any escapes here.  Adjust if neccessary
		for( var prop in custom ) {
			returnString = returnString.listAppend( '#prop#=#custom[ prop ]#', URLDelim );
		}
		
		return returnString;	
	}

	string function customURLDelimiter( string dbdriver ) {
		
		switch( dbdriver ) {
			case 'MySQL' :
			case 'PostgreSQL' :
				return '&';
			case 'MSSQL' :
			case 'MSSQL2' : // jTDS driver
			case 'Oracle' :
			case 'DB2' :
			case 'Sybase' :
			case 'ODBC' :			
			case 'HSQLDB' :			
			case 'H2Server' :
			case 'H2' :
				return ';';	
			case 'Firebird' :
			default :
				return '';
		}
		
	}

	// Every datasource type seems to store a slightly different set of properties.  
	// TODO: A few are probably missing here and need added
	function getDefaultDatasourceStruct( required string DBDriver ) {
		switch( DBDriver ) {
		    case 'MSSQLServer':
		         return getDefaultDSNSQLServer();
		    case 'PostgreSql':
		         return getDefaultDSNPostgresql();
		    case 'Oracle':
		         return getDefaultDSNOracle();
		    case 'MySQL5':
		         return getDefaultDSNMySQL();
		    default: 
		         return getDefaultDSNOther();
		}
	}
	
	function translateDatasourceDriverToGeneric( required string driverName ) {
		
		switch( driverName ) {
			case 'MSSQLServer' :
				return 'MSSQL';
			case 'PostgreSQL' :
				return 'PostgreSql';
			case 'Oracle' :
				return 'Oracle';
			case 'MySQL5' :
				return 'MySQL';
			case 'DB2' :
				return 'DB2';
			case 'Sybase' :
				return 'Sybase';
			case 'Apache Derby Client' :
				return 'Apache Derby Client';
			case 'Apache Derby Embedded' :
				return 'Apache Derby Embedded';
			case 'MySQL_DD' :
				return 'MySQL_DD';
			case 'jndi' :
				return 'jndi';
			default :
				return arguments.driverName;
		}
	
	}
	
	function translateDatasourceDriverToAdobe( required string driverName ) {
		
		switch( driverName ) {
			case 'MSSQL' :
				return 'MSSQLServer';
			case 'PostgreSQL' :
				return 'PostgreSql';
			case 'Oracle' :
				return 'Oracle';
			case 'MySQL' :
				return 'MySQL5';
			case 'DB2' :
				return 'DB2';
			case 'Sybase' :
				return 'Sybase';
			// These all just fall through to default "other"
			case 'ODBC' :
			case 'HSQLDB' :
			case 'H2Server' :
			case 'H2' :
			case 'Firebird' :
			case 'MSSQL2' : // jTDS driver
			default :
				return arguments.driverName;
		}
	
	}
	
	function translateDatasourceClassToAdobe( required string driverName, required string className ) {
		
		switch( driverName ) {
			case 'MSSQLServer' :
				return 'macromedia.jdbc.MacromediaDriver';
			case 'Oracle' :
				return 'macromedia.jdbc.MacromediaDriver';
			case 'MySQL5' :
				return 'com.mysql.jdbc.Driver';
			case 'PostgreSQL' :
				return 'org.postgresql.Driver';				
			default :
				return arguments.className;
		}
	
	}

	function getDefaultDSNMySQL() {
		return {
		    "disable":false,
		    "disable_autogenkeys":false,
		    "revoke":true,
		    "validationQuery":"",
		    "drop":true,
		    "url":"jdbc:mysql://{host}:{port}/{database}?tinyInt1isBit=false&",
		    "update":true,
		    "password":"",
		    "DRIVER":"MySQL5",
		    "NAME":"",
		    "blob_buffer":64000,
		    "disable_blob":true,
		    "timeout":1200,
		    "validateConnection":false,
		    "CLASS":"com.mysql.jdbc.Driver",
		    "grant":true,
		    "buffer":64000,
		    "username":"",
		    "login_timeout":30,
		    "description":"",
		    "urlmap":{
		        "defaultpassword":"",
		        "pageTimeout":"",
		        "SID":"",
		        "spyLogFile":"",
		        "CONNECTIONPROPS":{
		            "HOST":"",
		            "DATABASE":"",
		            "PORT":3306
		        },
		        "host":"",
		        "_logintimeout":30,
		        "defaultusername":"",
		        "maxBufferSize":"",
		        "databaseFile":"",
		        "TimeStampAsString":"no",
		        "systemDatabaseFile":"",
		        "datasource":"",
		        "_port":3306,
		        "args":"",
		        "supportLinks":"true",
		        "UseTrustedConnection":"false",
		        "applicationintent":"",
		        "sendStringParametersAsUnicode":"false",
		        "database":"",
		        "informixServer":"",
		        "port":"3306",
		        "MaxPooledStatements":"100",
		        "useSpyLog":false,
		        "isnewdb":"false",
		        "qTimeout":"0",
		        "selectMethod":"direct"
		    },
		    "insert":true,
		    "create":true,
		    "ISJ2EE":false,
		    "storedproc":true,
		    "interval":420,
		    "alter":true,
		    "delete":true,
		    "select":true,
		    "disable_clob":true,
		    "pooling":true,
		    "clientinfo":{
		        "ClientHostName":false,
		        "ApplicationNamePrefix":"",
		        "ApplicationName":false,
		        "ClientUser":false
		    }
		};
	}
	
	function getDefaultDSNPostgresql() {
		return {
		    "disable":false,
		    "disable_autogenkeys":false,
		    "revoke":true,
		    "validationQuery":"",
		    "drop":true,
		    "url":"jdbc:postgresql://{host}:{port}/{database}?",
		    "update":true,
		    "password":"",
		    "DRIVER":"PostgreSql",
		    "NAME":"",
		    "blob_buffer":64000,
		    "disable_blob":true,
		    "timeout":1200,
		    "validateConnection":false,
		    "CLASS":"org.postgresql.Driver",
		    "grant":true,
		    "buffer":64000,
		    "username":"",
		    "login_timeout":30,
		    "description":"",
		    "urlmap":{
		        "defaultpassword":"",
		        "pageTimeout":"",
		        "SID":"",
		        "spyLogFile":"",
		        "CONNECTIONPROPS":{
		            "HOST":"",
		            "DATABASE":"",
		            "PORT":"0"
		        },
		        "host":"Server",
		        "_logintimeout":30,
		        "defaultusername":"",
		        "maxBufferSize":"",
		        "databaseFile":"",
		        "TimeStampAsString":"no",
		        "systemDatabaseFile":"",
		        "datasource":"",
		        "_port":5432,
		        "args":"",
		        "supportLinks":"true",
		        "UseTrustedConnection":"false",
		        "applicationintent":"",
		        "sendStringParametersAsUnicode":"false",
		        "database":"",
		        "informixServer":"",
		        "port":"5432",
		        "MaxPooledStatements":"100",
		        "useSpyLog":false,
		        "isnewdb":"false",
		        "qTimeout":"0",
		        "selectMethod":"direct"
		    },
		    "insert":true,
		    "create":true,
		    "ISJ2EE":false,
		    "storedproc":true,
		    "interval":420,
		    "alter":true,
		    "delete":true,
		    "select":true,
		    "disable_clob":true,
		    "pooling":true,
		    "clientinfo":{
		        "ClientHostName":false,
		        "ApplicationNamePrefix":"",
		        "ApplicationName":false,
		        "ClientUser":false
		    }
		};
	}
	
	function getDefaultDSNOracle() {
		return {
		    "disable":false,
		    "disable_autogenkeys":false,
		    "revoke":true,
		    "validationQuery":"",
		    "drop":true,
		    "url":"jdbc:macromedia:oracle://{host}:{port};SID={SID};ServiceName={serviceName};AuthenticationMethod=userIDPassword;sendStringParametersAsUnicode={sendStringParametersAsUnicode};querytimeout={querytimeout};MaxPooledStatements={MaxPooledStatements}",
		    "update":true,
		    "password":"",
		    "DRIVER":"Oracle",
		    "NAME":"",
		    "blob_buffer":64000,
		    "disable_blob":true,
		    "timeout":1200,
		    "validateConnection":false,
		    "CLASS":"macromedia.jdbc.MacromediaDriver",
		    "grant":true,
		    "buffer":64000,
		    "login_timeout":30,
		    "username":"",
		    "description":"",
		    "urlmap":{
		        "defaultpassword":"",
		        "pageTimeout":"",
		        "SID":"",
		        "SERVICENAME":"",
		        "spyLogFile":"",
		        "CONNECTIONPROPS":{
		            "SID":"",
		            "SERVICENAME":"",
		            "SENDSTRINGPARAMETERSASUNICODE":"false",
		            "HOST":"",
		            "PORT":"1521",
		            "MAXPOOLEDSTATEMENTS":"100",
		            "QTIMEOUT":"0"
		        },
		        "host":"Server",
		        "_logintimeout":30,
		        "defaultusername":"",
		        "maxBufferSize":"",
		        "databaseFile":"",
		        "TimeStampAsString":"no",
		        "systemDatabaseFile":"",
		        "datasource":"",
		        "_port":1521,
		        "args":"",
		        "supportLinks":"true",
		        "UseTrustedConnection":"false",
		        "applicationintent":"",
		        "VENDOR":"oracle",
		        "sendStringParametersAsUnicode":"false",
		        "database":"",
		        "informixServer":"",
		        "port":"1521",
		        "MaxPooledStatements":"100",
		        "useSpyLog":false,
		        "isnewdb":"false",
		        "qTimeout":"0",
		        "selectMethod":"direct"
		    },
		    "insert":true,
		    "create":true,
		    "ISJ2EE":false,
		    "storedproc":true,
		    "interval":420,
		    "alter":true,
		    "TYPE":"ddtek",
		    "delete":true,
		    "select":true,
		    "disable_clob":true,
		    "pooling":true,
		    "clientinfo":{
		        "ClientHostName":false,
		        "ApplicationNamePrefix":"",
		        "ApplicationName":false,
		        "ClientUser":false
		    }
		};
	}
		
	function getDefaultDSNSQLServer() {
		return {
		    "disable":false,
		    "disable_autogenkeys":false,
		    "revoke":true,
		    "validationQuery":"",
		    "drop":true,
		    "url":"jdbc:macromedia:sqlserver://{host}:{port};databaseName={database};SelectMethod=direct;sendStringParametersAsUnicode={sendStringParametersAsUnicode};querytimeout={queryTimeout};MaxPooledStatements={maxPooledStatements}",
		    "update":true,
		    "password":"",
		    "DRIVER":"MSSQLServer",
		    "NAME":"sqlserver",
		    "blob_buffer":64000,
		    "disable_blob":true,
		    "timeout":1200,
		    "validateConnection":false,
		    "CLASS":"macromedia.jdbc.MacromediaDriver",
		    "grant":true,
		    "buffer":64000,
		    "login_timeout":30,
		    "username":"",
		    "description":"",
		    "urlmap":{
		        "defaultpassword":"",
		        "pageTimeout":"",
		        "SID":"",
		        "spyLogFile":"",
		        "CONNECTIONPROPS":{
		            "APPLICATIONINTENT":"",
		            "SENDSTRINGPARAMETERSASUNICODE":"false",
		            "HOST":"",
		            "DATABASE":"",
		            "PORT":"1433",
		            "MAXPOOLEDSTATEMENTS":"100",
		            "QTIMEOUT":"0",
		            "SELECTMETHOD":"direct"
		        },
		        "host":"",
		        "_logintimeout":30,
		        "defaultusername":"",
		        "maxBufferSize":"",
		        "databaseFile":"",
		        "TimeStampAsString":"no",
		        "systemDatabaseFile":"",
		        "datasource":"",
		        "_port":1433,
		        "args":"",
		        "supportLinks":"true",
		        "UseTrustedConnection":"false",
		        "applicationintent":"",
		        "VENDOR":"sqlserver",
		        "sendStringParametersAsUnicode":"false",
		        "database":"",
		        "informixServer":"",
		        "port":"1433",
		        "MaxPooledStatements":"100",
		        "useSpyLog":false,
		        "isnewdb":"false",
		        "CF_POOLED":"true",
		        "qTimeout":"0",
		        "selectMethod":"direct"
		    },
		    "insert":true,
		    "create":true,
		    "ISJ2EE":false,
		    "storedproc":true,
		    "interval":420,
		    "alter":true,
		    "TYPE":"ddtek",
		    "delete":true,
		    "select":true,
		    "disable_clob":true,
		    "pooling":true,
		    "clientinfo":{
		        "ClientHostName":false,
		        "ApplicationNamePrefix":"",
		        "ApplicationName":false,
		        "ClientUser":false
		    }
		};
	}
		
	function getDefaultDSNOther() {
		return {
		    "disable":false,
		    "disable_autogenkeys":false,
		    "revoke":true,
		    "validationQuery":"",
		    "drop":true,
		    "url":"",
		    "update":true,
		    "password":"",
		    "DRIVER":"Other",
		    "NAME":"",
		    "blob_buffer":64000,
		    "disable_blob":true,
		    "timeout":1200,
		    "validateConnection":false,
		    "CLASS":"",
		    "grant":true,
		    "buffer":64000,
		    "username":"",
		    "login_timeout":30,
		    "description":"",
		    "urlmap":{
		        "defaultpassword":"",
		        "pageTimeout":"",
		        "SID":"",
		        "spyLogFile":"",
		        "CONNECTIONPROPS":{
		            
		        },
		        "host":"",
		        "_logintimeout":30,
		        "defaultusername":"",
		        "maxBufferSize":"",
		        "databaseFile":"",
		        "TimeStampAsString":"no",
		        "systemDatabaseFile":"",
		        "datasource":"",
		        "_port":0,
		        "args":"",
		        "supportLinks":"true",
		        "UseTrustedConnection":"false",
		        "applicationintent":"",
		        "sendStringParametersAsUnicode":"false",
		        "database":"",
		        "informixServer":"",
		        "port":"",
		        "MaxPooledStatements":"100",
		        "useSpyLog":false,
		        "isnewdb":"false",
		        "qTimeout":"0",
		        "selectMethod":"direct"
		    },
		    "insert":true,
		    "create":true,
		    "ISJ2EE":false,
		    "storedproc":true,
		    "interval":420,
		    "alter":true,
		    "delete":true,
		    "select":true,
		    "disable_clob":true,
		    "pooling":true,
		    "clientinfo":{
		        "ClientHostName":false,
		        "ApplicationNamePrefix":"",
		        "ApplicationName":false,
		        "ClientUser":false
		    }
		};
	}
}