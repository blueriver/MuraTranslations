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
  <cfscript>
  counter=0;

  if ( !IsDefined("request") ) {
    request = {};
  }

  StructAppend(request, url, "no");
  StructAppend(request, form, "no");

  param name="request.keywords"  default="";
  param name="request.localID"  default="";
  param name="request.localSiteID"  default="";
  param name="request.remoteSiteID"  default="";

  crumbdata=application.contentManager.getCrumbList(request.localid, request.localSiteID);

  if (len(request.keywords)) {
    rsList=application.contentManager.getPrivateSearch(request.remoteSiteId,request.keywords);
  }
  </cfscript>
</cfsilent>
<cfsavecontent variable="body">
<cfoutput>
<cfif arrayLen(crumbdata) lte 30>
  <div class="alert alert-warning">
  <span>You are assigning the #HTMLEditFormat(ucase(translationManager.getTranslationKeys().setSiteID(request.remoteSiteID).load().getName()))# translation peer for the #HTMLEditFormat(ucase(translationManager.getTranslationKeys().setSiteID(request.localSiteID).load().getName()))# version of this content:
  <br>#application.contentRenderer.dspZoom(crumbData)#
  </span>
  </div>
</cfif>
<div class="mura-header">
  <h1>#pluginConfig.getName()#</h1>
    <div class="nav-module-specific btn-group">
      <a class="btn" <cfif arrayLen(crumbdata) gt 30>href="##" onclick="history.go(-1);"<cfelse>href="#application.configBean.getContext()#/admin/index.cfm?muraaction=cArch.edit&contenthistid=#request.contentHistID#&siteid=#request.localSiteID#&contentid=#request.localID#&topid=#request.localID#&type=#request.type#&parentid=#request.parentID#&moduleid=00000000000000000000000000000000000##tabsysMuraTranslations"</cfif>><i class="mi-arrow-circle-left"></i>Return</a></li>
    </div>
</div>

<div class="block block-constrain">
    <div class="block block-bordered">
      <div class="block-content">

      <cfif arrayLen(crumbdata) gt 30>
        <h2>Search For Translation</h2>
        <div class="help-block-inline help-block-error">Error: unable to complete search. Please try a different search term.</div>
        <div class="mura-control-group">
          <a class="btn" href="##" onclick="history.go(-1);"><i class="mi-arrow-left"></i>Return to Search</a>
        </div>
      <cfelse>
        <h2>Search For Translation</h2>
        <div class="help-block-inline">Please search for the content that you would like to assign as a translation peer. <br><em>If the content does not yet exist, you can create it now - just search for the section of the site where your new content will go.</em></div>

          <form class="search divide" method="post" name="parentSearchFrm" action="search.cfm" onsubmit="return validate(this);">
            <div class="mura-control-group justify">

              <div class="mura-input-set">
                <input name="keywords" required="true" value="<cfif len(request.keywords)>#HTMLEditFormat(request.keywords)#</cfif>" onclick="this.value='';" placeholder="Keyword Search" value="#htmlEditFormat(request.keywords)#" type="text" class="text med" />
                <input type="submit" class="btn" value="Search">
              </div>

              <input type="hidden" value="#HTMLEditFormat(request.localSiteID)#" name="localSiteID" />
              <input type="hidden" value="#HTMLEditFormat(request.localID)#" name="localID" />
              <input type="hidden" value="#HTMLEditFormat(request.remoteSiteID)#" name="remoteSiteID" />
              <input type="hidden" value="#HTMLEditFormat(request.type)#" name="type" />
              <input type="hidden" value="#HTMLEditFormat(request.contentHistID)#" name="contentHistID" />
              <input type="hidden" value="#HTMLEditFormat(request.parentID)#" name="parentID" />
            </div>
          </form>
          <cfif len(request.keywords)>
            <cfset rsList=application.contentManager.getPrivateSearch(request.remoteSiteId,request.keywords)/>
            <form  name="selectFrm" action="add.cfm" method="post">
            <div class="mura-control-group justify">
            <table class="table table-striped table-condensed table-bordered mura-table-grid">
              <cfif rslist.recordcount>
               <cfloop query="rslist" endrow="100">
              <cfif rslist.type neq 'File' and rslist.type neq 'Link'>
              <cfset crumbdata=application.contentManager.getCrumbList(rslist.contentid, request.remoteSiteId)/>
                  <cfset verdict=application.permUtility.getnodePerm(crumbdata)/>
              <cfif verdict neq 'none' and rslist.type neq 'Link' and rslist.type neq 'File'>
              <cfset counter=counter+1/>
              <tbody>
              <tr <cfif not(counter mod 2)>class="alt"</cfif>>
                    <td class="var-width">#application.contentRenderer.dspZoom(crumbData)#</td>
                <td class="administration"><input type="radio" name="remoteID" value="#rslist.contentID#"<cfif rslist.currentRow eq 1> checked</cfif>/></td>
              </tr>
              </tbody>
              </cfif></cfif>
                 </cfloop>
              </cfif>
              <cfif not counter>
               <tbody>
              <tr class="alt">
                <td class="noResults" colspan="2">Your search returned no results.</td>
              </tr>
              </tbody>
              </cfif>
            </table>
          </td></tr></table>
        </div>
          <cfif rslist.recordcount>
            <div class="mura-actions">
              <div class="form-actions">
                <input class="btn" type="submit" name="doAction" value="Create New Translation"/>
                <input class="btn" type="submit" name="doAction" value="Create New Translation and Copy All Children"/>
                <input class="btn mura-primary" type="submit" name="doAction" value="Assign Translation"/>
              </div>
            </div>
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
      <div class="clearfix"></div>
    </div> <!-- /.block-content -->
  </div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->
</cfoutput>
</cfsavecontent>
<cfoutput>
#application.pluginManager.renderAdminTemplate(body=body,pageTitle=pluginConfig.getName())#
</cfoutput>
