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
<cfset variables.instance.MapID="">
<cfset variables.instance.LocalSiteID="">
<cfset variables.instance.LocalID="">
<cfset variables.instance.RemoteSiteID="">
<cfset variables.instance.RemoteID="">
<cfset variables.isDirty=false>

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

		<cfif isquery(arguments.data)>

			<cfif arguments.data.recordcount>
				<cfset setMapID(arguments.data.MapID) />
				<cfset setLocalSiteID(arguments.data.LocalSiteID) />
				<cfset setLocalID(arguments.data.LocalID) />
				<cfset setRemoteSiteID(arguments.data.RemoteSiteID) />
				<cfset setRemoteID(arguments.data.RemoteID) />
				<cfset setFileName(arguments.data.FileName) />
			</cfif>

		<cfelseif isStruct(arguments.data)>

			<cfloop collection="#arguments.data#" item="prop">
				<cfif isdefined("variables.instance.#prop#")>
					<cfset evaluate("set#prop#(arguments.data[prop])") />
				</cfif>
			</cfloop>


		</cfif>

		<cfset validate() />

</cffunction>

<cffunction name="validate" access="public" output="false" returntype="void">
	<cfset variables.instance.errors=structnew() />
</cffunction>

<cffunction name="getErrors" returnType="struct" output="false" access="public">
    <cfreturn variables.instance.errors />
</cffunction>

<cffunction name="getMapID" returntype="String" access="public" output="false">
	<cfif not len(variables.instance.MapID)>
		<cfset variables.instance.MapID = createUUID() />
	</cfif>
	<cfreturn variables.instance.MapID />
</cffunction>

<cffunction name="setMapID" access="public" output="false">
	<cfargument name="MapID" type="String" />
	<cfset variables.instance.MapID = trim(arguments.MapID) />
</cffunction>

<cffunction name="getLocalSiteID" returntype="String" access="public" output="false">
	<cfreturn variables.instance.LocalSiteID />
</cffunction>

<cffunction name="setLocalSiteID" access="public" output="false">
	<cfargument name="LocalSiteID" type="String" />

	<cfset variables.instance.LocalSiteID = trim(arguments.LocalSiteID) />
</cffunction>

<cffunction name="getFileName" returntype="String" access="public" output="false">
	<cfreturn variables.instance.FileName />
</cffunction>

<cffunction name="setFileName" access="public" output="false">
	<cfargument name="FileName" type="String" />

	<cfset variables.instance.FileName = trim(arguments.FileName) />
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

<cffunction name="load"  access="public" output="false" returntype="void">
	<cfset set(getQuery()) />
</cffunction>

<cffunction name="getQuery"  access="public" output="false" returntype="query">
	<cfset var rs=""/>
	<cfquery name="rs" datasource="#variables.globalConfig.getDatasource()#" username="#variables.globalConfig.getDBUsername()#" password="#variables.globalConfig.getDBPassword()#">
	select trans.*,filename from #variables.table# trans
	LEFT JOIN tcontent tcon ON (trans.remoteID = tcon.contentID and tcon.active = 1)
	WHERE
	LocalSiteID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getLocalSiteID()#">
	and LocalID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getLocalID()#">
	and RemoteSiteID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getRemoteSiteID()#">
	</cfquery>

	<cfif rs.recordcount and rs.remoteID neq getRemoteID()>
		<cfset variables.isDirty=true>
	</cfif>

	<cfreturn rs/>
</cffunction>

<cffunction name="delete" access="public" returntype="void">
	<cfquery datasource="#variables.globalConfig.getDatasource()#" username="#variables.globalConfig.getDBUsername()#" password="#variables.globalConfig.getDBPassword()#">
	delete from #variables.table#
	where MapID=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#getMapID()#">
	</cfquery>
</cffunction>

<cffunction name="save"  access="public" output="false" returntype="any">
	<cfset var rs=""/>
	<cfset var saveKey="mapping" & hash(getLocalSiteID() & getLocalID() & getRemoteSiteID() & getRemoteID())>

	<cfif not structKeyExists(request,saveKey)>
		<cfset request[saveKey]=true>

		<cfif getQuery().recordcount>

			<cfquery datasource="#variables.globalConfig.getDatasource()#" username="#variables.globalConfig.getDBUsername()#" password="#variables.globalConfig.getDBPassword()#">
				update #variables.table# set
					LocalSiteID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getLocalSiteID()#">,
					LocalID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getLocalID()#">,
					RemoteSiteID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getRemoteSiteID()#">,
					RemoteID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getRemoteID()#">
				where MapID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getMapID()#">
			</cfquery>

			<cfreturn variables.isDirty>

		<cfelse>

			<cfquery datasource="#variables.globalConfig.getDatasource()#" username="#variables.globalConfig.getDBUsername()#" password="#variables.globalConfig.getDBPassword()#">
				insert into #variables.table# (MapID,LocalSiteID,LocalID,RemoteSiteID,RemoteID) values (
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#getMapID()#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#getLocalSiteID()#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#getLocalID()#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#getRemoteSiteID()#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#getRemoteID()#">
				)
			</cfquery>

			<cfreturn true>

		</cfif>
	<cfelse>
		<cfreturn false>
	</cfif>

</cffunction>

</cfcomponent>
