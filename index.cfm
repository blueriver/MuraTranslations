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
		setTabs(".tabbable",0);
//		$('.tabbable').show();	
		}
	);
</script>
<h1>#pluginConfig.getName()#</h1>
<div class="tabbable">
	<ul class="nav nav-tabs initActiveTab">
	<li><a href="##tabSettings" onclick="return false;"><span>Settings</span></a></li>
	<li><a href="##tabTemplate" onclick="return false;"><span>Template Code</span></a></li>
	<li><a href="##tabTranslate" onclick="return false;"><span>External Translations</span></a></li>
	<li><a href="##tabAbout" onclick="return false;"><span>About This Plugin</span></a></li>
	</ul>
	<div class="tab-content">
	<div id="tabSettings" class="tab-pane fade"> 
		<p>The "Locale Alias" is how each site is referenced within the locale translation navigation tools.
		<cfif len(message)><p class="success">#message#</p></cfif>
		<form class="fieldset-wrap" action="index.cfm" method="post" onsubmit="return validateForm(this);">
		<div class="fieldset">
			<div class="control-group">
				<div class="span3">
					<label class="control-label">
						Site
					</label>
				</div>
				<div class="span3">
					<label class="control-label">
						Locale
					</label>
				</div>
				<div class="span3">
					<label class="control-label">
						Locale Alias
					</label>
				</div>
				<div class="span3">
					<label class="control-label">
						Selector Label
					</label>
				</div>
			</div>
			<cfloop query="rsSites">
			<div class="control-group">
				<div class="span3">
					<div class="controls">
						#htmlEditFormat(rsSites.site)#
					</div>
				</div>
				<div class="span3">
					<div class="controls">
						#htmlEditFormat(rsSites.sitelocale)#
					</div>
				</div>
				<div class="span3">
					<div class="controls">
					<input class="text" name="alias#rsSites.currentRow#" type="text" value="#htmlEditFormat(rsSites.alias)#" required="true" message="The alias for the '#htmlEditFormat(rsSites.site)#' is required" maxlength="100"/>
					</div>
				</div>
				<div class="span3">
					<div class="controls">
					<input class="text" name="selectorlabel#rsSites.currentRow#" type="text" value="#htmlEditFormat(rsSites.selectorlabel)#" required="false" message="The selector label for the '#htmlEditFormat(rsSites.site)#' is required" maxlength="100"/>
					</div>
				</div>
			</div><input type="hidden" name="siteid#rsSites.currentRow#" value="#rsSites.siteid#"/>
			</cfloop>
		</div>
		<div class="form-actions">
			<input class="btn" type="submit" value="Update"/>
			<input type="hidden" value="#rsSites.recordcount#" name="siteCount"/>
			<input type="hidden" name="doaction" value="update"/>
		</div>
		</form>
	</div>
	<div id="tabTemplate" class="tab-pane">
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
	<div id="tabTranslate" class="tab-pane">
		<form class="fieldset-wrap" action="translations/index.cfm" method="post" onsubmit="return validateForm(this);">
		<div class="fieldset">
			<div class="control-group">
				<div class="span6">
					<label class="control-label">Action</label>
					<div class="controls">
					  	<label for="isActionExport" class="radio inline">
					     <input type="radio" name="export_action" value="export" checked="checked" id="isActionExport">
					     Export
					    </label>
					    <label for="isActionImport" class="radio inline"> 
					     <input type="radio" name="export_action" value="import" checked="checked" id="isActionImport">
					     Import
					    </label>
					</div>
				</div>
			</div>
		</div>
		<div class="form-actions">
			<input type="submit" value="Next" class="btn"/>
			<input type="hidden" value="#rsSites.recordcount#" name="siteCount"/>
			<input type="hidden" name="doaction" value="update"/>
		</div>
		</form>
	</div>
	<div id="tabAbout" class="tab-pane">
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
	</div>
</div>

</cfoutput>
</cfsavecontent>
<cfoutput>
#application.pluginManager.renderAdminTemplate(body=body,pageTitle=pluginConfig.getName())#
</cfoutput>
