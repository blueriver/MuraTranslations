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
<cfcomponent extends="mura.plugin.pluginGenericEventHandler">

<cffunction name="onContentDelete" output="true" returntype="any">
<cfargument name="event">

	<cfset var contentBean=event.getValue('contentBean')>
	<cfset var translationManager=createObject("component","translationManager").init(application.configBean,pluginConfig)>
	<cfset translationManager.deleteAllMappings(contentBean.getContentID())>

</cffunction>

<cffunction name="onContentSave" output="true" returntype="any">
<cfargument name="event">

<cfset var contentBean=event.getValue("contentBean")>
<cfset var pSession=pluginConfig.getSession()/>
<cfset var _local=""/>
<cfset var returnURL=""/>

	<cfif not structKeyExists(request,"event")>
		<cfset request.event=arguments.event>
	</cfif>
	
	<cfif listFindNoCase("Portal,File,Link,Page,Calendar,Gallery",contentBean.getType())>
		
		<cfif findNocase("#application.configBean.getContext()#/plugins/#pluginConfig.getDirectory()#/search.cfm",request.event.getValue('returnURL'))>
			<cfset request.event.setValue('returnURL',replaceNoCase(request.event.getValue('returnURL'),'contentHistID=','contentHistID=#contentBean.getContentHistID()#&old='))>
			<cfset request.event.setValue('returnURL',replaceNoCase(request.event.getValue('returnURL'),'localID=','localID=#contentBean.getContentID()#&old='))>				
		<cfelse>
			<cfset pSession=pluginConfig.getSession()>
		
				<cfset _local=pSession.getValue('local')>
				
				<cfif isStruct(_local) and not StructIsEmpty(_local)>
					<cfset pSession.setValue('showTab',true)>
					
					<cfif contentBean.getParentID() eq _local.remoteID
						and contentBean.getSiteID() eq _local.remoteSiteID>
					
					<cfif not len(event.getValue('returnURL'))>
						<cfset returnURL="#application.configBean.getContext()#/admin/index.cfm?fuseaction=cArch.edit&contenthistid=#_local.contentHistID#&siteid=#_local.localSiteID#&contentid=#_local.localID#&topid=#_local.localID#&type=#_local.type#&parentid=#_local.parentID#&moduleid=00000000000000000000000000000000000">		
						<cfset request.event.setValue('returnURL',returnURL)/>
					</cfif>
					
					</cfif>
				
				</cfif>
				
		</cfif>
	
	</cfif>
	
	<cfset pSession.setValue('local',structNew())>
</cffunction>

</cfcomponent>