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

<cfinclude template="plugin/config.cfm" />
<cfset message=""/>
<cfif structKeyExists(form,"doaction") and form.doaction eq "update">
<cfloop from="1" to="#form.siteCount#" index="i">
	<cfset translationKeys=variables.translationManager.getTranslationKeys()>
	<cfset translationKeys.setSiteID(form["siteid#i#"])>
	<cfset translationKeys.load()>
	<cfset translationKeys.setName(form["alias#i#"])>
	<cfset translationKeys.setSelectorLabel(form["selectorLabel#i#"])>
	<cfset translationKeys.save()>
</cfloop>
<cfset message="Your settings have been saved.">
</cfif>
<cfset rsSites=translationManager.getAssignedSites()/>
<cfsavecontent variable="body">
<cfoutput>
<script>
	$(document).ready(function(){
		$('.tabs').tabs().show();	
		}
	);
</script>
<h2>#pluginConfig.getName()#</h2>
<div class="tabs initActiveTab" style="display:none">
	<ul>
	
	<li><a href="##tabSettings" onclick="return false;"><span>Settings</span></a></li>
	<li><a href="##tabTemplate" onclick="return false;"><span>Template Code</span></a></li>
	<li><a href="##tabTranslate" onclick="return false;"><span>External Translations</span></a></li>
	<li><a href="##tabAbout" onclick="return false;"><span>About This Plugin</span></a></li>
	
	</ul>


<div id="tabSettings">
	<p>The "Locale Alias" is how each site is referenced within the locale translation navigation tools.
	
	<cfif len(message)><p class="success">#message#</p></cfif>
	<form action="index.cfm" method="post" onsubmit="return validateForm(this);">
	<table class="stripe">
	<tr>
	<th>Site</th>
	<th>Locale</th>
	<th>Locale Alias</th>
	<th>Selector Label</th>
	</tr>
	<cfloop query="rsSites">
	<tr>
	<td>#htmlEditFormat(rsSites.site)#</td>
	<td>#htmlEditFormat(rsSites.sitelocale)#</td>
	<td><input name="alias#rsSites.currentRow#" type="text" value="#htmlEditFormat(rsSites.alias)#" required="true" message="The alias for the '#htmlEditFormat(rsSites.site)#' is required" maxlength="100"/></td>
	<td><input name="selectorlabel#rsSites.currentRow#" type="text" value="#htmlEditFormat(rsSites.selectorlabel)#" required="false" message="The selector label for the '#htmlEditFormat(rsSites.site)#' is required" maxlength="100"/></td>
	</tr><input type="hidden" name="siteid#rsSites.currentRow#" value="#rsSites.siteid#"/>
	</cfloop>
	</table>
	<input type="submit" value="Update"/>
	<input type="hidden" value="#rsSites.recordcount#" name="siteCount"/>
	<input type="hidden" name="doaction" value="update"/>
	</form>
</div>
<div id="tabTemplate">
	<cfset rsObjects=translationManager.getDisplayObjects()>
	<table class="stripe">
	<tr>
	<th>Object</th>
	<th>Code</th>
	</tr>
	<cfloop query="rsObjects">
	<tr>
	<td>#htmlEditFormat(rsObjects.name)#</td>
	<td>##renderer.dspObject('plugin','#rsObjects.objectID#')##</td>
	</tr>
	</cfloop>
	</table>
</div>
<div id="tabTranslate">
	<form action="translations/index.cfm" method="post" onsubmit="return validateForm(this);">
	<h3>Import / Export Actions</h3>
	<table class="stripe">
	<tr>
	<td><input type="radio" name="export_action" value="export" checked="checked"></td>
	<td>Export</td>
	</tr>
	<tr>
	<td><input type="radio" name="export_action" value="import"></td>
	<td>Import</td>
	</tr>
	</table>
	<input type="submit" value="Next"/>
	<input type="hidden" value="#rsSites.recordcount#" name="siteCount"/>
	<input type="hidden" name="doaction" value="update"/>
	</form>
</div>
<div id="tabAbout">
	<p>The Locale Translation Manager allows you to specify related alternate language versions of content for any specific page within the Mura content editing process. This is a great tool for sites that need to provide single pages of translated content or links between entire sites of translated content.</p>
	<p>Once the plug-in is installed on all of the sites in your Mura instance and the Locale Translation Manager becomes available on any page. From the content edit screen, you can simply select the content from other sites that you would like to provide as a translated version of your current page. Once the relationship is created, just add the display object to the page you are editing and the translate this page option will appear. Toggling between versions is transparent to the user for both the admin creating the translation as well as the user on the front-end.</p>
	<p>You do not have to create an entire site structure to allow translations for each. Every translation can be created on an ad hoc basis, although some fleshing out of site architecture may be necessary for a good user-experience.</p>
	<p>The Locale Translation Manager Plug-In is released under the <a href="http://www.getmura.com/index.cfm/app-store/plugins/commercial-license/">Mura Commercial License</a>. The purchase of this plug-in allows you to use it on any number of sites within a single production Mura CMS&nbsp;instance (note that the purchase of this plug-in allows you to use it on unlimited developer or staging instances of Mura CMS). If you wish to use this plug-in on multiple production instances of Mura CMS, please <a href="http://www.getmura.com/index.cfm/contact-us/">contact us</a> us for discounted pricing.</p>
	<h3>Installation Video</h3>
	<div class="video"><object width="445" height="364">
	<param name="movie" value="http://www.youtube.com/v/sFsWvTGtKf4&amp;hl=en&amp;fs=1&amp;border=1" />
	<param name="allowFullScreen" value="true" />
	<param name="allowscriptaccess" value="always" /><embed src="http://www.youtube.com/v/sFsWvTGtKf4&amp;hl=en&amp;fs=1&amp;border=1" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="445" height="364"></embed></object></div>
	<br />
	<h3>Usage Video</h3>
	<div class="video"><object width="445" height="364">
	<param name="movie" value="http://www.youtube.com/v/mNAYOgT-ST8&amp;hl=en&amp;fs=1&amp;border=1" />
	<param name="allowFullScreen" value="true" />
	<param name="allowscriptaccess" value="always" /><embed src="http://www.youtube.com/v/mNAYOgT-ST8&amp;hl=en&amp;fs=1&amp;border=1" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="445" height="364"></embed></object></div>
	</div>
</div>
</cfoutput>
</cfsavecontent>
<cfoutput>
#application.pluginManager.renderAdminTemplate(body=body,pageTitle=pluginConfig.getName())#
</cfoutput>
