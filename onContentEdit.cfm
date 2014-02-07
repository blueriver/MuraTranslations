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
<cfset secure=false>
<cfinclude template="plugin/config.cfm">
<cfset rsLocales=translationManager.getAssignedSites(attributes.siteID)>
<cfset pSession=pluginConfig.getSession()>

<cfsavecontent variable="headerStr">
<cfoutput>
<script language="JavaScript">
function removeTranslationAssignments(){
	if(confirm('Remove Translation Assignments?')){
	
		var url = '#application.configBean.getContext()#/plugins/#pluginConfig.getDirectory()#/delete.cfm';
		var pars = 'contentID=#request.contentBean.getContentID()#&cacheid=' + Math.random();
		
		jQuery.get(url + "?" + pars, 
			function() {
			loadLocaleTable();
			}
		);
		
		
		}
	return false;
}	
	
function loadLocaleTable(activeTab){
	var url = '#application.configBean.getContext()#/plugins/#pluginConfig.getDirectory()#/assignmentTable.cfm';
	var pars = 'contentID=#request.contentBean.getContentID()#&contentHistID=#request.contentBean.getContentHistID()#&type=#attributes.type#&parentID=#attributes.parentID#&siteid=#attributes.siteID#&doMap=#yesNoFormat(event.valueExists("doMap"))#&cacheid=' + Math.random();
	var tab = activeTab;	
	
	try {
		jQuery("##localeTableContainer").html('<br/><img src="/admin/assets/images/ajax-loader.gif">');
	}
	catch( any ) {
	}
	
	
	//location.href=url + "?" + pars;
	/*
	jQuery(".initActiveTab").each(
		function(index) {			
			jQuery(this).tabs("select",tab);
		}
	);
	*/
	
	jQuery.get(url + "?" + pars, 
		function(data) {
			jQuery("##localeTableContainer").html(data);
			stripe("stripe");		
		}
	);	
}

function saveBeforeTranslation(forwardURL){
	siteManager.requestedURL=forwardURL;
	return conditionalExit();
}
</script>
</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#headerStr#">
</cfsilent>
<span id="localeTableContainer">
</span>
<cfoutput>
<script language="JavaScript">
jQuery(document).ready(
	function(){
		<cfif isBoolean(pSession.getValue('showTab')) and pSession.getValue('showTab')>
		loadLocaleTable(#evaluate(listlen(event.getValue('tablist'))-1)#);
		<cfelse>loadLocaleTable(0);
		</cfif>
});
</script>
</cfoutput>
<cfset pSession.setValue('showTab',false)>