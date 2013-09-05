<!--- This file is part of of a commercially-provided Mura CMS plug-in. This file, and all related files in this plug-in are offered under the terms of the license distributed with the plugin at the time of purchase or download, and use of this file and all related files in this plug-in are restricted to these terms. --->
<cfoutput>
DROP TABLE "#ucase('p#variables.config.getPluginID()#_translationmaps')#" cascade constraints;
DROP TABLE "#ucase('p#variables.config.getPluginID()#_translationkeys')#" cascade constraints;
DROP TABLE "#ucase('p#variables.config.getPluginID()#_translationexports')#" cascade constraints;
</cfoutput>