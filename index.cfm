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
	<style>
		.mura .mt-wrapper p {
			margin-bottom: 1em !important;
		}
		.mura .mt-wrapper .tab-content {
			margin: 1em;
		}
		.mura .mt-wrapper .row.site-info {
			margin-bottom: 1.5em;
		}
		.mura .mt-wrapper label {
			font-weight: bold;
			font-size: 1.25em;
		}
	</style>


	<div class="mt-wrapper">
		<h1>#HTMLEditFormat(pluginConfig.getName())#</h1>

		<ul class="mura tabs nav nav-tabs initActiveTab">
			<li role="presentation" class="active"><a href="##tabSettings" role="tab" data-toggle="tab"><span>Settings</span></a></li>
			<li role="presentation"><a href="##tabTemplate" role="tab" data-toggle="tab"><span>Template Code</span></a></li>
			<li role="presentation"><a href="##tabTranslate" role="tab" data-toggle="tab"><span>External Translations</span></a></li>
			<li role="presentation"><a href="##tabAbout" role="tab" data-toggle="tab"><span>About This Plugin</span></a></li>
		</ul>

		<div class="tab-content">

			<div role="tabpanel" id="tabSettings" class="tab-pane active fade in">
				<p>The &quot;Locale Alias&quot; is how each site is referenced within the Mura Translations plugin navigation tools.</p>

				<cfif len(message)>
					<p class="alert alert-success">#message#</p>
				</cfif>

				<form action="index.cfm" method="post" onsubmit="return validateForm(this);">
					<div class="form-wrapper">
						<div class="row">
							<div class="col-md-3">
								<label>
									Site
								</label>
							</div>
							<div class="col-md-3">
								<label>
									Locale
								</label>
							</div>
							<div class="col-md-3">
								<label>
									Locale Alias
								</label>
							</div>
							<div class="col-md-3">
								<label>
									Selector Label
								</label>
							</div>
						</div>

						<cfloop query="rsSites">
							<div class="row site-info">
								<div class="col-md-3">
									<div class="controls">
										#htmlEditFormat(rsSites.site)#
									</div>
								</div>
								<div class="col-md-3">
									<div class="controls">
										#htmlEditFormat(rsSites.sitelocale)#
									</div>
								</div>
								<div class="col-md-3">
									<div class="controls">
									<input class="text" name="alias#rsSites.currentRow#" type="text" value="#htmlEditFormat(rsSites.alias)#" required="true" message="The alias for the '#htmlEditFormat(rsSites.site)#' is required" maxlength="100"/>
									</div>
								</div>
								<div class="col-md-3">
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

			<div role="tabpanel" id="tabTemplate" class="tab-pane fade">
				<cfset rsObjects=translationManager.getDisplayObjects()>
				<table class="table stripe">
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

			<div role="tabpanel" id="tabTranslate" class="tab-pane fade">
				<h4>External Translations (Beta)</h4>
				<form class="fieldset-wrap" action="translations/index.cfm" method="post" onsubmit="return validateForm(this);">
				<div class="fieldset">
					<div class="form-group">
						<div class="span6">
							<label>Action</label>
							<div class="controls">
							  	<label for="isActionExport" class="radio-inline">
							    	<input type="radio" name="export_action" value="export" checked="checked" id="isActionExport">
							    	Export
							    </label>
							    <label for="isActionImport" class="radio-inline">
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

			<div role="tabpanel" id="tabAbout" class="tab-pane fade">
				<p>The Mura Translations plugin allows you to specify related alternate language versions of content for any specific page within the Mura content editing process.
				This is a great tool for sites that need to provide single pages of translated content or links between entire sites of translated content.</p>
				<p>Once the plug-in is installed on all of the sites in your Mura instance and the Mura Translations plugin becomes available on any page.
				From the content edit screen, you can simply select the content from other sites that you would like to provide as a translated version of your current page.
				Once the relationship is created, just add the display object to the page you are editing and the translate this page option will appear.
				Toggling between versions is transparent to the user for both the admin creating the translation as well as the user on the front-end.</p>
				<p>External Translations allow you to export the content of a site for external translation, then import the translated content into a new site within the same Mura instance.
				The Mura Translations plugin will copy the format and structure of the original (export) site into the new (import) site, replacing the original content with your translated content.
				You can process the imports in an ad hoc fashion (i.e. only a few pages at a time) and perform the export/import operation as often as you like.
				All imported content is automatically mapped to the original (export) site.</p>
				<p>You do not have to create an entire site structure to allow translations for each.
				Every translation can be created on an ad hoc basis, although some fleshing out of site architecture may be necessary for a good user-experience.</p>
				<p>The Mura Translations plugin is released under the <a href="https://github.com/blueriver/MuraTranslations">Mura Commercial License</a>.
				The purchase of this plug-in allows you to use it on any number of sites within a single production Mura CMS instance
				(note that the purchase of this plug-in allows you to use it on unlimited developer or staging instances of Mura CMS).
				If you wish to use this plug-in on multiple production instances of Mura CMS, please <a href="http://www.getmura.com/contact-us/">contact us</a> us for discounted pricing.</p>

				<h3>Overview Video</h3>
				<div class="video">
					<iframe width="640" height="360" src="http://www.youtube.com/embed/GnMUuFw2SK0" frameborder="0" allowfullscreen></iframe>
				</div>
				<br />
				</div>
			</div>
	</div>

</cfoutput>
</cfsavecontent>
<cfoutput>
#application.pluginManager.renderAdminTemplate(body=body,pageTitle=pluginConfig.getName())#
</cfoutput>
