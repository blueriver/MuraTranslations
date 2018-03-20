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
---><cfsilent>
<cfset secure=false>
<cfinclude template="plugin/config.cfm">
<cfset rsLocales=translationManager.getAssignedSites(url.siteID)>
<cfset pSession=pluginConfig.getSession()>
<cfif not url.doMap>
	<cfset pSession.init()>
</cfif>
</cfsilent>
<cfoutput>
<dl class="oneColumn">
<dt class="first">
<div class="control-group">
<label>
Associated Locales<cfif translationManager.hasTranslation(url.contentID,url.siteID)>: <a href="##" onclick="removeTranslationAssignments();return false;">[Remove Translation Assignment(s)]</a></cfif>
</label>
</div>
</dt>
<table class="table table-striped table-condensed table-bordered mura-table-grid" id="locales">
<thead>
	<tr>
<th class="actions"></th>
<th>Locale</th>
<th>Site</th>
<th class="var-width">Node</th>
</tr>
</thead>
<cfif rsLocales.recordcount>
<tbody id="Locales">
<cfloop query="rsLocales">
<cfset translation=translationManager.getTranslation()>
<cfset translation.setLocalSiteID(url.siteid)>
<cfset translation.setLocalID(url.contentID)>
<cfset translation.setRemoteSiteID(rsLocales.siteid)>
<!---<hr>#translation.getLocal().getRemoteID()#::#translation.getLocal().getRemoteSiteID()#<hr>--->
<cfset mapping=translation.getLocal()>
<cfset mapCrumb=application.contentGateway.getCrumblist(mapping.getRemoteID(),mapping.getRemoteSiteID())>

<tr>
<td class="actions" id="stm_admin#rsLocales.siteid#">
	<a class="show-actions" href="javascript:;" ontouch="this.onclick();" onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
	<div class="actions-menu hide">
		<ul class="actions-list">
		<cfif len(mapping.getRemoteID())>
			<cfif application.permUtility.getModulePerm('00000000000000000000000000000000000',mapCrumb[1].siteID)
				and listFindNoCase("Editor,Author",application.permUtility.getnodePerm(mapCrumb))>
				<li class="edit"><a target="_top" href="#application.configBean.getContext()##application.configBean.getAdminDir()#/index.cfm?muraaction=cArch.edit&contenthistid=#mapCrumb[1].contentHistID#&contentid=#mapCrumb[1].contentID#&type=#mapCrumb[1].type#&parentid=#mapCrumb[1].parentID#&topid=#mapCrumb[1].contentID#&siteid=#mapCrumb[1].siteID#&moduleid=00000000000000000000000000000000000&startrow=1" onclick=";"><i class="mi-pencil"></i>Edit</a></li>
			<cfelse>
				<li class="edit editOff"><a>Edit</a></li>
			</cfif>
			
		<cfelse>
			<cfif application.permUtility.getModulePerm('00000000000000000000000000000000000',rsLocales.siteid)>	
			<li class="select"><a target="_top" href="#application.configBean.getContext()#/plugins/#pluginConfig.getDirectory()#/search.cfm?localSiteID=#translation.getLocalSiteID()#&localID=#translation.getLocalID()#&remoteSiteID=#translation.getRemoteSiteID()#&parentID=#url.parentID#&type=#url.type#&contentHistID=#url.contentHistID#" onclick="return saveBeforeTranslation(this.href);"><i class="mi-plus-circle"></i>Select</a></li>	
			<cfelse>
			<li class="select selectOff"><a>Select</a></li>	
			</cfif>
		</cfif>
		</ul>
	</div>	
</td>
<td>#HTMLEditFormat(rsLocales.alias)#</td>
<td>#HTMLEditFormat(rsLocales.site)#</td>
<td class="var-width" id="stm_crumb#rsLocales.siteid#">
<cfif len(mapping.getRemoteID())>
#application.contentRenderer.dspZoom(mapCrumb)#
<cfelse>
<em>(No Assigned Translation)</em>
</cfif>
</td>
</tr>
</cfloop>
</tbody>
<cfelse>
<tr>
<td id="noFilters" colspan="4" class="noResults">This site currently has no translation peers.</td>
</tr>
</cfif>
</table>
</dl>

</cfoutput>