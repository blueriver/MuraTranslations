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
---><cfset translationManager=createObject("component","plugins.#pluginConfig.getDirectory()#.cfcs.translationManager").init(event.getConfigBean(),pluginConfig)>
<cfset rsLocales=translationManager.getAssignedSites(event.getValue('siteid'))>
<cfif rsLocales.recordcount>
<cfsavecontent variable="str">
<cfoutput><link rel="stylesheet" href="#request.pluginConfig.getSetting('pluginPath')#css/ltm.css" type="text/css" media="all" /></cfoutput>
</cfsavecontent>
<cfhtmlhead text="#str#">
<cfoutput>
<select id="svLTM" class="dropdown" onchange="location.href=this.value;">
<option value="">#HTMLEditFormat(translationManager.getTranslationKeys().setSiteID(event.getValue('siteid')).load().getSelectorLabel())#</option>
<cfloop query="rslocales">
	<cfsilent>
	<cfset theURL = application.configBean.getContext() & translationManager.lookUpTranslation(event.getValue('crumbdata'),rsLocales.siteid,event.getContentRenderer())/>
	</cfsilent>
	<option value="#HTMLEditFormat(theURL)#">#HTMLEditFormat(rsLocales.alias)#</option>
</cfloop>
</select>
</cfoutput>
</cfif>


