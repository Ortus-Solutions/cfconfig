<!---
*********************************************************************************
 Copyright Since 2017 CommandBox by Ortus Solutions, Corp
 www.ortussolutions.com
********************************************************************************
Author: Brad Wood

--->
<cfsetting showDebugOutput="false">
<!--- Executes all tests in the 'specs' folder with simple reporter by default --->
<cfparam name="url.reporter" 		default="simple">
<cfparam name="url.directory" 		default="tests.specs">
<cfparam name="url.recurse" 		default="true" type="boolean">
<cfparam name="url.bundles" 		default="">
<cfparam name="url.labels" 			default="">
<cfparam name="url.reportpath" 		default="#expandPath( "/tests/results" )#">
<cfparam name="url.propertiesFilename" 	default="TEST.properties">
<cfparam name="url.propertiesSummary" 	default="false" type="boolean">

<!--- Code Coverage requires FusionReactor --->
<cfparam name="url.coverageEnabled"					default="false">
<cfparam name="url.coveragePathToCapture"			default="#expandPath( '/root/cfconfig/models' )#">
<cfparam name="url.coverageWhitelist"				default="">
<cfparam name="url.coverageBlacklist"				default="">
<cfparam name="url.coverageBrowserOutputDir"		default="#expandPath( '/tests/results/coverageReport' )#">
<!---<cfparam name="url.coverageSonarQubeXMLOutputPath"	default="#expandPath( '/tests/results/SonarQubeCoverage.xml' )#">--->

<!--- Include the TestBox HTML Runner --->
<cfinclude template="/testbox/system/runners/HTMLRunner.cfm" >