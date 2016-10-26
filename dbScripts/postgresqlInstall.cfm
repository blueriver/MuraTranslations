<!--- This file is part of of a commercially-provided Mura CMS plug-in. This file, and all related files in this plug-in are offered under the terms of the license distributed with the plugin at the time of purchase or download, and use of this file and all related files in this plug-in are restricted to these terms. --->
<cfoutput>
CREATE TABLE p#variables.config.getPluginID()#_translationmaps (
	mapID char(35) NOT NULL,
	localSiteID varchar(25) NOT NULL,
	localID char(35) NOT NULL,
	remoteSiteID varchar(25) NOT NULL,
	remoteID char(35) NOT NULL,
	CONSTRAINT PK_p#variables.config.getPluginID()#_translationmaps PRIMARY KEY (mapID)
);

CREATE INDEX
	p#variables.config.getPluginID()#_translationmaps_from
ON
	p#variables.config.getPluginID()#_translationmaps(localSiteID,localID);

CREATE INDEX
	p#variables.config.getPluginID()#_translationmaps_to
ON
	p#variables.config.getPluginID()#_translationmaps(remoteSiteID,remoteID);
</cfoutput>