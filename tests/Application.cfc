/**
*********************************************************************************
* Copyright Since 2017 CommandBox by Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* @author Brad Wood
*/
component{
	
	this.name = hash( getCurrentTemplatePath() );
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan(0,0,30,0);
	this.setClientCookies = true;
	this.mappings[ '/root/cfconfig' ] = expandPath( getDirectoryFromPath( getCurrentTemplatePath() )  & '../');
	this.mappings[ '/root' ] = expandPath( getDirectoryFromPath( getCurrentTemplatePath() ) & '../../' );
	this.mappings[ '/tests' ] = getDirectoryFromPath( getCurrentTemplatePath() );
}