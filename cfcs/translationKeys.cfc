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
<cfset variables.instance.siteID="">
<cfset variables.instance.name="">
<cfset variables.instance.selectorlabel="">

<cffunction name="init" output="false" returntype="any">
<cfargument name="globalConfig">
<cfargument name="pluginConfig">

<cfset variables.globalConfig=arguments.globalConfig>
<cfset variables.pluginConfig=arguments.pluginConfig>
<cfset variables.table="p#variables.pluginConfig.getPluginID()#_translationkeys">

<cfreturn this>
</cffunction>

<cffunction name="set" returnType="any" output="false" access="public">
		<cfargument name="data" type="any" required="true">

		<cfset var prop=""/>
		
		<cfif isquery(arguments.data)>
			
			<cfif arguments.data.recordcount>
				<cfset setSiteID(arguments.data.siteID) />
				<cfset setName(arguments.data.name) />
				<cfset setSelectorLabel(arguments.data.selectorlabel) />
				
			</cfif>
			
		<cfelseif isStruct(arguments.data)>
		
			<cfloop collection="#arguments.data#" item="prop">
				<cfif isdefined("variables.instance.#prop#")>
					<cfset evaluate("set#prop#(arguments.data[prop])") />
				</cfif>
			</cfloop>
	
			
		</cfif>
		
		<cfset validate() />
		<cfreturn this>
</cffunction>
  
<cffunction name="validate" access="public" output="false" returntype="any">
	<cfset variables.instance.errors=structnew() />
	<cfreturn this>
</cffunction>

<cffunction name="getErrors" returnType="struct" output="false" access="public">
    <cfreturn variables.instance.errors />
</cffunction>

<cffunction name="getSiteID" returntype="String" access="public" output="false">
	<cfreturn variables.instance.siteID />
</cffunction>

<cffunction name="setSiteID" access="public" output="false" returntype="any">
	<cfargument name="siteID" type="String" />
	<cfset variables.instance.siteID = trim(arguments.siteID) />
	<cfreturn this>
</cffunction>

<cffunction name="getName" returntype="String" access="public" output="false">
	<cfreturn variables.instance.name />
</cffunction>

<cffunction name="setName" access="public" output="false" returntype="any">
	<cfargument name="name" type="String" />
	<cfset variables.instance.name = trim(arguments.name) />
	<cfreturn this>
</cffunction>

<cffunction name="getSelectorLabel" returntype="String" access="public" output="false">
	<cfreturn variables.instance.selectorlabel />
</cffunction>

<cffunction name="setSelectorLabel" access="public" output="false" returntype="any">
	<cfargument name="selectorlabel" type="String" />
	<cfset variables.instance.selectorlabel = trim(arguments.selectorlabel) />
	<cfreturn this>
</cffunction>

<cffunction name="load"  access="public" output="false" returntype="any">
	<cfset set(getQuery()) />
	<cfreturn this>
</cffunction>

<cffunction name="getQuery"  access="public" output="false" returntype="query">
	<cfset var rs=""/>
	<cfquery name="rs" datasource="#variables.globalConfig.getDatasource()#" username="#variables.globalConfig.getDBUsername()#" password="#variables.globalConfig.getDBPassword()#">
	select * from #variables.table# where 
	siteID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getSiteID()#">
	</cfquery>
	
	<cfreturn rs/>
</cffunction>

<cffunction name="delete" access="public" returntype="void">
	<cfquery datasource="#variables.globalConfig.getDatasource()#" username="#variables.globalConfig.getDBUsername()#" password="#variables.globalConfig.getDBPassword()#">
	delete from #variables.table#
	where siteID=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#getSiteID()#">
	</cfquery>
</cffunction>

<cffunction name="save"  access="public" output="false" returntype="any">
<cfset var rs=""/>

	
	<cfif getQuery().recordcount>
		
		<cfquery datasource="#variables.globalConfig.getDatasource()#" username="#variables.globalConfig.getDBUsername()#" password="#variables.globalConfig.getDBPassword()#">
		update #variables.table# set
		name=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getName()#">,
		selectorlabel=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getSelectorLabel()#">
		where siteID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getSiteID()#">
		</cfquery>
		
	<cfelse>
	
		<cfquery datasource="#variables.globalConfig.getDatasource()#" username="#variables.globalConfig.getDBUsername()#" password="#variables.globalConfig.getDBPassword()#">
			insert into #variables.table# (siteID,name,selectorlabel) values (
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#getSiteID()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#getName()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#getSelectorLabel()#">
			)
		</cfquery>
		
	</cfif>
	
</cffunction>

</cfcomponent>