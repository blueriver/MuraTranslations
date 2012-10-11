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
<cfset translationManager=createObject("component","plugins.#pluginConfig.getDirectory()#.cfcs.translationManager").init(event.getConfigBean(),pluginConfig)>
<cfset rsLocales=translationManager.getAssignedSites(event.getValue('siteid'))>
<cfif rsLocales.recordcount>
<cfsilent>
<cfset selectorLabel=translationManager.getTranslationKeys().setSiteID(event.getValue('siteid')).load().getSelectorLabel()>
	
<cfsavecontent variable="str">
<cfoutput>
<link rel="stylesheet" href="#request.pluginConfig.getSetting('pluginPath')#css/ltm.css" type="text/css" media="all" />
<style>
<cfloop query="rslocales">
<cfset javaLocale=lcase(listLast(application.settingsManager.getSite(rsLocales.siteid).getJavaLocale(),"_"))>
.showFlags li###javaLocale# a {
	background-image: url(#request.pluginConfig.getSetting('pluginPath')#images/#javaLocale#.gif);
}
</cfloop>
</style>
</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#str#">
</cfsilent>
<cfoutput>
<div id="svLTM" class="navSecondary plugIn<cfif pluginConfig.getSetting('showFlags') eq 'Yes'> showFlags</cfif>">
<!--- Uncomment the showFlags class to use flag icons in the list --->
<cfif len(selectorLabel)><h3>#HTMLEditFormat(selectorLabel)#</h3></cfif>
<ul>
<cfloop query="rslocales">
	<cfsilent>
	<cfset javaLocale=lcase(listLast(application.settingsManager.getSite(rsLocales.siteid).getJavaLocale(),"_"))>
	<cfset theURL = application.configBean.getContext() & translationManager.lookUpTranslation(event.getValue('crumbdata'),rsLocales.siteid,event.getContentRenderer())/>
	<cfset class="">
	<cfif rsLocales.currentrow eq 1>
		<cfset class="first">
	</cfif>
	<cfif rsLocales.currentrow eq rsLocales.recordcount>
		<cfset class=listAppend(class,"last"," ")>
	</cfif>
	</cfsilent>
	<li id="#javaLocale#"<cfif len(class)> class="#class#"</cfif>>
		<a href="#HTMLEditFormat(theURL)#">#HTMLEditFormat(rsLocales.alias)#</a>
	</li>
</cfloop>
</ul>
</div>
</cfoutput>
</cfif>