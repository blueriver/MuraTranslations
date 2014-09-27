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
<cfset variables.instance.LocalSiteID="">
<cfset variables.instance.LocalID="">
<cfset variables.instance.RemoteSiteID="">
<cfset variables.instance.RemoteID="">

<cffunction name="init" output="false" returntype="any">
<cfargument name="globalConfig">
<cfargument name="pluginConfig">

<cfset variables.globalConfig=arguments.globalConfig>
<cfset variables.pluginConfig=arguments.pluginConfig>
<cfset variables.table="p#variables.pluginConfig.getPluginID()#_translationmaps">

<cfreturn this>
</cffunction>

<cffunction name="set" returnType="void" output="false" access="public">
		<cfargument name="data" type="any" required="true">

		<cfset var prop=""/>
		
		<cfloop collection="#arguments.data#" item="prop">
			<cfif isdefined("variables.instance.#prop#")>
				<cfset evaluate("set#prop#(arguments.data[prop])") />
			</cfif>
		</cfloop>
	
		
		<cfset validate() />
		
</cffunction>

<cffunction name="save" returntype="void" access="public" output="false">
	<cfset var rsPeers="">
	<cfset var rsPeersRecurse="">
	
	<cftransaction isolation="read_uncommitted">
		<cfif getLocal().save()>
			<cfset mapPeers(getLocalID(), getLocalSiteID(), getRemoteID(), getRemoteSiteID())>
			<cfset mapPeers(getRemoteID(), getRemoteSiteID(), getLocalID(), getLocalSiteID())>		
		</cfif>
		
		<cfset getRemote().Save()>
	</cftransaction>
</cffunction>

<cffunction name="mapPeers" output="false">
<cfargument name="localID">
<cfargument name="localSiteID">
<cfargument name="remoteID">
<cfargument name="remoteSiteID">

<cfset var rsPeers=getPeers(arguments.remoteID,arguments.remoteSiteID)>


	<cfloop query="rsPeers">
		<cfif getMapping(rsPeers.remoteID, rsPeers.remoteSiteID, arguments.localID, arguments.localSiteID).save()>
			<cfset mapPeers(arguments.localID, arguments.localSiteID, rsPeers.remoteID, rsPeers.remoteSiteID)>
			<cfset mapPeers(rsPeers.remoteID, rsPeers.remoteSiteID, arguments.localID, arguments.localSiteID)>
		</cfif>
		
		<cfset getMapping(arguments.localID, arguments.localSiteID, rsPeers.remoteID, rsPeers.remoteSiteID).save()>
		
	</cfloop>
	
	
</cffunction>	
	
<cffunction name="getPeers" returntype="any" access="public" output="false">
	<cfargument name="contentID">
	<cfargument name="siteID">
	<cfset var rs="">	
	
	<cfquery name="rs" datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
	select remoteID, remoteSiteID from #variables.table#
	where localID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contentID#">
	and localSiteID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#">
	</cfquery>
	
	<cfreturn rs>
</cffunction>

<cffunction name="delete" returntype="void" access="public" output="false">
	
	<cftransaction isolation="read_uncommitted">
		<cfquery  datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
		delete from #variables.table#
		and remoteSiteID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getLocalSiteID()#">
		</cfquery>
		
		<cfquery  datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
		delete from #variables.table#
		and localSiteID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getLocalSiteID()#">
		</cfquery>
	</cftransaction>
	
</cffunction>

<cffunction name="getLocal" returntype="any" access="public" output="false">
	<cfset var LocalBean =createObject("component","translationMap").init(variables.globalConfig,variables.pluginConfig)>
	
	<cfset LocalBean.setLocalSiteID(getLocalSiteID())>
	<cfset LocalBean.setLocalID(getLocalID())>
	<cfset LocalBean.setRemoteSiteID(getRemoteSiteID())>
	<cfset LocalBean.setRemoteID(getRemoteID())>
	<cfset LocalBean.load()>
	
	<cfreturn LocalBean>
</cffunction>

<cffunction name="getMapping" returntype="any" access="public" output="false">
	<cfargument name="localID">
	<cfargument name="localSiteID">
	<cfargument name="remoteID">
	<cfargument name="remoteSiteID" >
	<cfargument name="filename" default="">
	
	<cfset var mapping =createObject("component","translationMap").init(variables.globalConfig,variables.pluginConfig)>
	
	<cfset mapping.setLocalSiteID(arguments.localSiteID)>
	<cfset mapping.setLocalID(arguments.localID)>
	<cfset mapping.setRemoteSiteID(arguments.remoteSiteID)>
	<cfset mapping.setRemoteID(arguments.remoteID)>
	<cfset mapping.setFileName(arguments.filename)>
	<cfset mapping.load()>
	
	<cfreturn mapping>
</cffunction>

<cffunction name="getRemote" returntype="any" access="public" output="false">
	<cfset var RemoteBean =createObject("component","translationMap").init(variables.globalConfig,variables.pluginConfig)>
	
	<cfset RemoteBean.setLocalSiteID(getRemoteSiteID())>
	<cfset RemoteBean.setLocalID(getRemoteID())>
	<cfset RemoteBean.setRemoteSiteID(getLocalSiteID())>
	<cfset RemoteBean.setRemoteID(getLocalID())>
	<cfset RemoteBean.load()>
	
	<cfreturn RemoteBean>
</cffunction>

<cffunction name="getLocalSiteID" returntype="String" access="public" output="false">
	<cfreturn variables.instance.LocalSiteID />
</cffunction>

<cffunction name="setLocalSiteID" access="public" output="false">
	<cfargument name="LocalSiteID" type="String" />
	<cfset variables.instance.LocalSiteID = trim(arguments.LocalSiteID) />
</cffunction>

<cffunction name="getLocalID" returntype="String" access="public" output="false">
	<cfreturn variables.instance.LocalID />
</cffunction>

<cffunction name="setLocalID" access="public" output="false">
	<cfargument name="LocalID" type="String" />
	<cfset variables.instance.LocalID = trim(arguments.LocalID) />
</cffunction>

<cffunction name="getRemoteSiteID" returntype="String" access="public" output="false">
	<cfreturn variables.instance.RemoteSiteID />
</cffunction>

<cffunction name="setRemoteSiteID" access="public" output="false">
	<cfargument name="RemoteSiteID" type="String" />
	<cfset variables.instance.RemoteSiteID = trim(arguments.RemoteSiteID) />
</cffunction>

<cffunction name="getRemoteID" returntype="String" access="public" output="false">
	<cfreturn variables.instance.RemoteID />
</cffunction>

<cffunction name="setRemoteID" access="public" output="false">
	<cfargument name="RemoteID" type="String" />
	<cfset variables.instance.RemoteID = trim(arguments.RemoteID) />
</cffunction>

</cfcomponent>