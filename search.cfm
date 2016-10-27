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
    <h2>#pluginConfig.getName()#</h2>
    <h3>Search For Translation</h3>

    <cfif arrayLen(crumbdata) gt 30>

      <div class="form-actions">
        <a class="btn" onclick="history.go(-1);">
          <i class="mi-undo"></i>
          Return
        </a>
      </div>
      <p class="alert alert-danger">We're sorry, an error has occurred.</p>

    <cfelse>

      <div class="form-actions">
        <a class="btn" href="#application.configBean.getContext()#/admin/index.cfm?muraaction=cArch.edit&contenthistid=#request.contentHistID#&siteid=#request.localSiteID#&contentid=#request.localID#&topid=#request.localID#&type=#request.type#&parentid=#request.parentID#&moduleid=00000000000000000000000000000000000">
          <i class="mi-undo"></i>
          Return
        </a>
      </div>

      <div class="alert">
        <p>You are assigning a #HTMLEditFormat(ucase(translationManager.getTranslationKeys().setSiteID(request.remoteSiteID).load().getName()))# translation peer for the #HTMLEditFormat(ucase(translationManager.getTranslationKeys().setSiteID(request.localSiteID).load().getName()))# version of:</p>
        #application.contentRenderer.dspZoom(crumbData)#
      </div>

      <h4>Please search for the content that you would like to assign as a translation peer.</h4>
      <p<cfif len(request.keywords) and not rslist.recordcount> class="error"</cfif>><strong>Note:</strong> If the content does not yet exist, you can create it now - just search for the section of the site where your new content will go.</p>

      <hr>
      <div class="row">
        <div class="col-md-12">
        	<form class="form-inline" class="search divide" method="post" name="parentSearchFrm" action="search.cfm" onsubmit="return validate(this);">
            <div class="form-group">
              <input class="form-control" name="keywords" required="true" value="<cfif not len(request.keywords)>Search by Keyword<cfelse>#HTMLEditFormat(request.keywords)#</cfif>" onclick="this.value='';" onblur="if(this.value==''){this.value='Search by Keyword';}" message="Please enter a search keyword." value="#htmlEditFormat(request.keywords)#" type="text" class="text med" />
            </div>
            <button type="submit" class="btn" value="Search">
              <i class="mi-search"></i>
              Search
            </button>

            <input type="hidden" value="#HTMLEditFormat(request.localSiteID)#" name="localSiteID" />
            <input type="hidden" value="#HTMLEditFormat(request.localID)#" name="localID" />
            <input type="hidden" value="#HTMLEditFormat(request.remoteSiteID)#" name="remoteSiteID" />
            <input type="hidden" value="#HTMLEditFormat(request.type)#" name="type" />
            <input type="hidden" value="#HTMLEditFormat(request.contentHistID)#" name="contentHistID" />
            <input type="hidden" value="#HTMLEditFormat(request.parentID)#" name="parentID" />
        	</form>
        </div>
      </div>
      <hr>

      <cfif len(request.keywords)>
        <cfset rsList=application.contentManager.getPrivateSearch(request.remoteSiteId,request.keywords)/>
        <form  name="selectFrm" action="add.cfm" method="post">
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
                        <td class="var-width">
                          #application.contentRenderer.dspZoom(crumbData)#
                        </td>
                        <td class="administration">
                          <input type="radio" name="remoteID" value="#rslist.contentID#"<cfif rslist.currentRow eq 1> checked</cfif>/>
                        </td>
                      </tr>
                    </tbody>
                  </cfif>
                </cfif>
              </cfloop>
            </cfif>
            <cfif not counter>
              <tbody>
                <tr class="alt">
                  <td class="noResults" colspan="2">Your search returned no results.</td>
                </tr>
              </tbody>
            </cfif>
            <!--- </table>
            </td></tr> --->
          </table>

          <cfif rslist.recordcount>
            <div class="form-actions">
              <button class="btn mura-primary" type="submit" name="doAction" value="Assign Translation">
                <i class="mi-check"></i>
                Assign Translation
              </button>
              Or &nbsp;&nbsp;&nbsp;&nbsp;
              <button class="btn" type="submit" name="doAction" value="Create New Translation Under This Section">
                <i class="mi-file-text"></i>
                Create New Translation Under This Section
              </button>
              &nbsp;&nbsp;
              <button class="btn" type="submit" name="doAction" value="Create New Translation and Copy All Children">
                <i class="mi-files-o"></i>
                Create New Translation and Copy All Children
              </button>
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
  </cfoutput>
</cfsavecontent>
<cfoutput>#application.pluginManager.renderAdminTemplate(body=body,pageTitle=pluginConfig.getName())#</cfoutput>
