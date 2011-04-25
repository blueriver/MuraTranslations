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
<cfsilent>
<cfinclude template="plugin/config.cfm">
<cfset counter=0 />
<cfscript>
if (NOT IsDefined("request"))
    request=structNew();
StructAppend(request, url, "no");
StructAppend(request, form, "no");
</cfscript>

<cfparam name="request.keywords"  default="">
<cfparam name="request.localID"  default="">
<cfparam name="request.localSiteID"  default="">
<cfparam name="request.remoteSiteID"  default="">


<cfset crumbdata=application.contentManager.getCrumbList(request.localid, request.localSiteID)/>
<cfif len(request.keywords)>
<cfset rsList=application.contentManager.getPrivateSearch(request.remoteSiteId,request.keywords)/>
</cfif>
</cfsilent>

<cfsavecontent variable="body">
<cfoutput>

<cfif arrayLen(crumbdata) gt 30>
<h2>#pluginConfig.getName()#</h2>
<h3>Search For Translation</h3>
<ul class="navTask">
<li class="pluginHome"><a href="##" onclick="history.go(-1);">Return</a></li>
</ul>

<p class="error">We're sorry, an error has occurred.</p>

<cfelse>
<h2>#pluginConfig.getName()#</h2>
<h3>Search For Translation</h3>
<ul class="navTask">
<li class="pluginHome"><a href="#application.configBean.getContext()#/admin/index.cfm?fuseaction=cArch.edit&contenthistid=#request.contentHistID#&siteid=#request.localSiteID#&contentid=#request.localID#&topid=#request.localID#&type=#request.type#&parentid=#request.parentID#&moduleid=00000000000000000000000000000000000">Return</a></li>
</ul>

<div class="notice">
<p>You are assigning a #HTMLEditFormat(ucase(translationManager.getTranslationKeys().setSiteID(request.remoteSiteID).load().getName()))# translation peer for the #HTMLEditFormat(ucase(translationManager.getTranslationKeys().setSiteID(request.localSiteID).load().getName()))# version of:</p>

#application.contentRenderer.dspZoom(crumbData)#
</div>

<h4>Please search for the content that you would like to assign as a translation peer.</h4>
<p<cfif len(request.keywords) and not rslist.recordcount> class="error"</cfif>><strong>Note:</strong> If the content does not yet exist, you can create it now - just search for the section of the site where your new content will go.</p>

	<form class="search divide" method="post" name="parentSearchFrm" action="search.cfm" onsubmit="return validate(this);">
	<input name="keywords" required="true" value="<cfif not len(request.keywords)>Search by Keyword<cfelse>#HTMLEditFormat(request.keywords)#</cfif>" onclick="this.value='';" onblur="if(this.value==''){this.value='Search by Keyword';}" message="Please enter a search keyword." value="#htmlEditFormat(request.keywords)#" type="text" class="text med" />	
	<input type="submit" value="Search">
	<input type="hidden" value="#HTMLEditFormat(request.localSiteID)#" name="localSiteID" />
	<input type="hidden" value="#HTMLEditFormat(request.localID)#" name="localID" />
	<input type="hidden" value="#HTMLEditFormat(request.remoteSiteID)#" name="remoteSiteID" />
	<input type="hidden" value="#HTMLEditFormat(request.type)#" name="type" />
	<input type="hidden" value="#HTMLEditFormat(request.contentHistID)#" name="contentHistID" />
	<input type="hidden" value="#HTMLEditFormat(request.parentID)#" name="parentID" />
	</form>
<cfif len(request.keywords)>
	<cfset rsList=application.contentManager.getPrivateSearch(request.remoteSiteId,request.keywords)/>
	<form  name="selectFrm" action="add.cfm" method="post">
	 <table>
	    <cfif rslist.recordcount>
	     <cfloop query="rslist" endrow="100">
			<cfif rslist.type neq 'File' and rslist.type neq 'Link'>
			<cfset crumbdata=application.contentManager.getCrumbList(rslist.contentid, request.remoteSiteId)/>
	        <cfset verdict=application.permUtility.getnodePerm(crumbdata)/>
			<cfif verdict neq 'none' and rslist.type neq 'Link' and rslist.type neq 'File'>
			<cfset counter=counter+1/>
			<tr <cfif not(counter mod 2)>class="alt"</cfif>>  
	          <td class="varWidth">#application.contentRenderer.dspZoom(crumbData)#</td>
			  <td class="administration"><input type="radio" name="remoteID" value="#rslist.contentID#"<cfif rslist.currentRow eq 1> checked</cfif>/></td>
			</tr>
		 	</cfif></cfif>
	       </cfloop>
		 	</cfif>
		 	<cfif not counter>
			<tr class="alt">
			  <td class="noResults" colspan="2">Your search returned no results.</td>
			</tr>
			</cfif>
	  </table>
	</td></tr></table>
	<cfif rslist.recordcount>
	<input type="submit" name="doAction" value="Assign Translation"/>
	&nbsp; &nbsp; Or &nbsp;&nbsp;
	<input type="submit" name="doAction" value="Create New Translation Under This Section"/>
	&nbsp;&nbsp;
	<input type="submit" name="doAction" value="Create New Translation and Copy All Children"/>
	</cfif>
	<input type="hidden" value="#HTMLEditFormat(request.localSiteID)#" name="localSiteID" />
	<input type="hidden" value="#HTMLEditFormat(request.localID)#" name="localID" />
	<input type="hidden" value="#HTMLEditFormat(request.remoteSiteID)#" name="remoteSiteID" />
	<input type="hidden" value="#HTMLEditFormat(request.type)#" name="type" />
	<input type="hidden" value="#HTMLEditFormat(request.contentHistID)#" name="contentHistID" />
	<input type="hidden" value="#HTMLEditFormat(request.parentID)#" name="parentID" />
</form>
</cfif>
</cfif>
</cfoutput>
</cfsavecontent>
<cfoutput>
#application.pluginManager.renderAdminTemplate(body=body,pageTitle=pluginConfig.getName())#
</cfoutput>