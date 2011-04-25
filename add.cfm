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
<cfscript>
if (NOT IsDefined("request"))
    request=structNew();
StructAppend(request, url, "no");
StructAppend(request, form, "no");
</cfscript>
<cfinclude template="plugin/config.cfm">
<cfset psession=pluginConfig.getSession()>


<cfif request.doAction eq 'Assign Translation'>
	<!--- Create translation mapping and return to original node --->
	<cfset translation=translationManager.getTranslation()>
	<cfset translation.setLocalSiteID(request.localSiteID)>
	<cfset translation.setLocalID(request.localID)>
	<cfset translation.setRemoteSiteID(request.remoteSiteID)>
	<cfset translation.setRemoteID(request.remoteID)>
	<cfset translation.save()>
	<cfset pSession.setValue('showTab',true)>
	<cflocation url="#application.configBean.getContext()#/admin/index.cfm?fuseaction=cArch.edit&contenthistid=#request.contentHistID#&siteid=#request.localSiteID#&contentid=#request.localID#&topid=#request.localID#&type=#request.type#&parentid=#request.parentID#&moduleid=00000000000000000000000000000000000"  addtoken="false">

<cfelse>
	<cfif request.doAction eq "Create New Translation Under This Section">
		<cfset deepCopy=false>
	<cfelse>
		<cfset deepCopy=true>
	</cfif>
	
	<cfset newBean=translationManager.copyLocalToRemote(request.localSiteID,request.localID, request.remoteSiteID, request.remoteID, deepCopy)>
	<cfset pSession=pluginConfig.getSession()/>
	<cfset pSession.setValue('local',structCopy(request))>
	<cfset pSession.setValue('showTab',false)>
	<!--- go to newly create translation peer --->
	<cflocation url="#application.configBean.getContext()#/admin/index.cfm?fuseaction=cArch.edit&contenthistid=#newBean.getContentHistID()#&siteid=#request.remoteSiteID#&contentid=#newBean.getContentID()#&&topid=#request.remoteID#&type=#request.type#&parentid=#request.remoteID#&moduleid=00000000000000000000000000000000000&doMap=true&suppressDraftNotice=true"  addtoken="false">
</cfif>
