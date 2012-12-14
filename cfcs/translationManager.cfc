<!---
   Copyright 2011 Blue River Interactive

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
--->
<cfcomponent output="false">

<cfset variables.globalConfig="">
<cfset variables.pluginConfig="">
<cfset variables.table="">
<cffunction name="init" output="false" returntype="any">
<cfargument name="globalConfig">
<cfargument name="pluginConfig">

<cfset variables.globalConfig=arguments.globalConfig>
<cfset variables.pluginConfig=arguments.pluginConfig>
<cfset variables.translationmaps="p#variables.pluginConfig.getPluginID()#_translationmaps">
<cfset variables.translationkeys="p#variables.pluginConfig.getPluginID()#_translationkeys">

<cfreturn this>
</cffunction>

<cffunction name="getAssignedSites" returntype="query" output="false">
<cfargument name="siteid" required="true" default="">
	<cfset var rs=""/>
	<cfquery name="rs" datasource="#variables.globalConfig.getDatasource()#" username="#variables.globalConfig.getDBUsername()#" password="#variables.globalConfig.getDBPassword()#">
	select tcontent.siteID,tcontent.moduleID, tsettings.siteLocale,tsettings.site, tsettings.site, #variables.translationkeys#.name alias, #variables.translationkeys#.selectorlabel
	from tcontent inner join tsettings on tcontent.siteid=tsettings.siteid
	left join #variables.translationkeys# on tsettings.siteid = #variables.translationkeys#.siteid
	where  moduleID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.pluginConfig.getModuleID()#">
	<cfif len(arguments.siteid)>
		and tcontent.siteid != <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteid#">
	</cfif>
	order by #variables.translationkeys#.name
	</cfquery>
	<cfreturn rs>
</cffunction>

<cffunction name="getTranslation" returntype="any" access="public" output="false">
	<cfset var translation =createObject("component","translation").init(variables.globalConfig,variables.pluginConfig)>
	
	<cfreturn translation>
</cffunction>

<cffunction name="getTranslationKeys" returntype="any" access="public" output="false">
	<cfset var translationName =createObject("component","translationKeys").init(variables.globalConfig,variables.pluginConfig)>
	
	<cfreturn translationName>
</cffunction>

<cffunction name="deleteAllMappings" returntype="void" output="false">
<cfargument name="contentid" required="true" default="">
	
	<cfif arguments.contentID neq '00000000000000000000000000000000001'>
	<cfquery datasource="#variables.globalConfig.getDatasource()#" username="#variables.globalConfig.getDBUsername()#" password="#variables.globalConfig.getDBPassword()#">
	 delete from #variables.translationmaps#
	 where remoteID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contentID#">
	 or localID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contentID#">	
	</cfquery>
	</cfif>
	
</cffunction>

<cffunction name="deleteSiteMappings" returntype="void" output="false">
<cfargument name="siteID" required="true">
	
	<cfif arguments.contentID neq '00000000000000000000000000000000001'>
	<cfquery datasource="#variables.globalConfig.getDatasource()#" username="#variables.globalConfig.getDBUsername()#" password="#variables.globalConfig.getDBPassword()#">
	 delete from #variables.translationmaps#
	 where localsiteID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#">
	 or remotesiteID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#">	
	</cfquery>
	</cfif>
	
</cffunction>


<cffunction name="hasTranslation" returntype="any" output="false">
<cfargument name="contentid" required="true" default="">
<cfargument name="siteID" required="true" default="">
	<cfset var rs="">
	<cfquery name="rs" datasource="#variables.globalConfig.getDatasource()#" username="#variables.globalConfig.getDBUsername()#" password="#variables.globalConfig.getDBPassword()#">
	 select count(*) mappings from #variables.translationmaps#
	 where localID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contentID#">
	</cfquery>

	<cfreturn rs.mappings>
</cffunction>

<cffunction name="lookUpTranslation" returntype="string" output="false">
<cfargument name="crumbData" >
<cfargument name="remoteSiteID">
<cfargument name="renderer">

	<cfset var translation=getTranslation()>
	<cfset var I=1>
	<cfset var mapping="">
	<cfset var urlStem=arguments.renderer.getURLStem(remoteSiteID,'')>
	
	<cfset translation.setRemoteSiteID(arguments.remoteSiteID)>
	<cfset translation.setLocalSiteID(arguments.crumbData[1].siteID)>
	
	<cfloop from="1" to="#arrayLen(arguments.crumbdata)#" index="I">
		<cfset translation.setLocalID(arguments.crumbData[I].contentID)>
		<cfset mapping=translation.getLocal()>
		<cfif len(mapping.getRemoteID())>
			<cfreturn urlStem & "?linkServID=" & mapping.getRemoteID()>
		</cfif>
	</cfloop>
	
	<cfreturn urlStem>
	
</cffunction>

<cffunction name="getDisplayObjects" returntype="any" access="public" output="false">
	<cfset var rs="">	
	
	<cfquery name="rs" datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
	select * from tplugindisplayobjects where moduleID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#pluginConfig.getModuleID()#">
	</cfquery>
	
	<cfreturn rs>
</cffunction>

<cffunction name="copyLocalToRemote" output="false">
<cfargument name="localSiteID">
<cfargument name="localContentID">
<cfargument name="remoteSiteID">
<cfargument name="remoteParentID">
<cfargument name="deepCopy">

	<cfset var local=structNew()>
	
	<cfset local.localScope=application.serviceFactory.getBean('MuraScope').init(arguments.localSiteID)>
	<cfset local.remoteScope=application.serviceFactory.getBean('MuraScope').init(arguments.remoteSiteID)>
	<cfset local.copyBean=local.localScope.getBean("content").loadBy(contentID=arguments.localContentID)>
	
	<cfset local.translation=getTranslation()>
	<cfset local.translation.setLocalSiteID(arguments.localSiteID)>
	<cfset local.translation.setLocalID(arguments.localContentID)>
	<cfset local.translation.setRemoteSiteID(arguments.remoteSiteID)>
	<cfset local.currentMapping=local.translation.getLocal()>
	
	<cfif not len(local.currentMapping.getRemoteID())>
		<!--- Create new node that has some basic info from the source content --->	
		<cfset local.copyStruct=duplicate(local.copyBean.getAllValues())>
		<cfset local.newBean=local.remoteScope.getBean('content')>
			
		<cfset structDelete( local.copyStruct, "path" ) />
		<cfset structDelete( local.copyStruct, "filename" ) />
		<cfset structDelete( local.copyStruct, "contentId" ) />
		<cfset structDelete( local.copyStruct, "contentHistId" ) />
		<cfset structDelete( local.copyStruct, "isNew" ) />
		<cfset structDelete( local.copyStruct, "lastupdatedby" ) />
		<cfset structDelete( local.copyStruct, "lastupdatedbyid" ) />
		<cfset structDelete( local.copyStruct, "extendsetid" ) />
		<cfset structDelete( local.copyStruct, "parentId" ) />
		
		<cfif len(local.copyStruct.fileID)>
			
			<cfset local.rsFile=local.localScope.getBean("fileManager").readMeta(local.copyStruct.fileID)>
			
			<cfset local.fileDir=application.configBean.getFileDir()>
			
			<cffile action="readBinary"
			file="#local.fileDir#/#local.rsFile.siteID#/cache/file/#local.rsFile.fileid#.#local.rsFile.fileEXT#"
			variable="local.newFile">
			
			<cfif listFindnoCase("png,jpg,jpeg,gif",local.rsFile.fileExt)>
				<cffile action="readBinary"
				file="#local.fileDir#/#local.rsFile.siteID#/cache/file/#local.rsFile.fileid#_small.#local.rsFile.fileEXT#"
				variable="local.newFileSmall">
				<cffile action="readBinary"
				file="#local.fileDir#/#local.rsFile.siteID#/cache/file/#local.rsFile.fileid#_medium.#local.rsFile.fileEXT#"
				variable="local.newFileMedium">
			<cfelse>
				<cfset local.newFileSmall="">
				<cfset local.newFileMedium="">
			</cfif>
				
			<cfset local.copyStruct.fileID=local.localScope.getBean("fileManager").create(
					local.newFile,
					local.newBean.getContentID(),
					local.newBean.getSiteID(),
					local.rsFile.filename,
					local.rsFile.contentType,
					local.rsFile.contentSubType,
					local.rsFile.fileSize,
					local.rsFile.moduleID,
					local.rsFile.fileExt,
					local.newFileSmall,
					local.newFileMedium
				)>
			
			<!---
			<cfset local.copyFilename=local.localScope.getBean("fileManager").readMeta(local.copyStruct.fileID).filename>
			<cfset local.copyStruct.newFile="http://#cgi.server_name##application.configBean.getServerPort()#/tasks/render/file/?fileID=#local.copyBean.getFileID()#&/#local.copyFilename#">
			<cfset local.copyStruct.fileID="">
			--->
		</cfif>
	
		<cfset local.newBean.set(local.copyStruct)>
		<cfset local.newBean.setSiteID(arguments.remoteSiteID)>
		<cfset local.newBean.setParentID(arguments.remoteParentID)>
		<cfset local.newBean.setOrderNo(0)>
		<cfset local.newBean.setValue("fromMuraLTM","true")>
		
		<cfif listFindNoCase("Link",local.copyBean.getType())>
			<cfset local.newBean.setFilename(local.copyBean.getFilename())>
		</cfif>
		
		<cfset local.newBean.save()>
		
		<!--- assign the localID to the current remoteID translation mapping --->
		<cfset local.translation=getTranslation()>
		<cfset local.translation.setLocalSiteID(arguments.localSiteID)>
		<cfset local.translation.setLocalID(arguments.localContentID)>
		<cfset local.translation.setRemoteSiteID(arguments.remoteSiteID)>
		<cfset local.translation.setRemoteID(local.newBean.getContentID())>
		<cfset local.translation.save()>
		
	<cfelse>
	
		<cfset local.newBean=local.remoteScope.getBean("content").loadBy(content=local.currentMapping.getRemoteID())>	
		
	</cfif>
	
	<cfif isBoolean(arguments.deepCopy) and arguments.deepCopy>
		<cfset local.rskids=application.serviceFactory.getBean("contentGateway").getNest(parentID=local.copyBean.getContentID(), siteID=local.copyBean.getSiteID(), sortBy=local.copyBean.getSortBy(), sortDirection="desc")>
		<cfset local.kids=application.serviceFactory.getBean('contentIterator')>
		<cfset local.kids.setQuery(local.rskids)>
			
		<cfif local.kids.hasNext()>
			
			<cfloop condition="local.kids.hasNext()">
				<cfset local.kid=local.kids.next()>
				<cfset copyLocalToRemote(local.kid.getSiteID(), local.kid.getContentID(), local.newBean.getSiteID(), local.newBean.getContentID(), arguments.deepCopy)>
			</cfloop>	
		</cfif>
	</cfif>
		
	<cfreturn local.newBean>
	
</cffunction>
</cfcomponent>