<cfdirectory action="list" directory="#expandPath("/#pluginConfig.getDirectory()#")#/translations/templates" name="rsTemplates" type="dir">
<cfsilent>
	<cfset rc.hasChangesets = $.getBean('settingsManager').getSite($.event('siteID')).getValue('hasChangesets') />
	<cfset rc.enforceChangesets = $.getBean('settingsManager').getSite($.event('siteID')).getValue('enforceChangesets') />
	<cfset rc.sites = pluginConfig.getAssignedSites() />
	<cfset rc.rsChangeSets = $.getBean("changesetManager").getQuery( siteID=$.event('siteID'),published=0 ) />
	<cfset rc.rsExternalChangeSets = $.getBean("changesetManager").getQuery( siteID=rc.sites.siteID,published=0 ) />
</cfsilent>

<cfoutput>
	
	<h2>Import Site (Beta)</h2>
	<form class="fieldset-wrap" action="./index.cfm" method="post" onsubmit="return validateForm(this);" enctype="multipart/form-data">
	<input type="hidden" name="export_action" value="import">
	<div class="fieldset">
		<div class="control-group">
			<div class="span6">
				<label class="control-label">
					Zip File
				</label>
				<div class="controls">
				  <input class="text" type="file" name="import_file">
				</div>
			</div>
		</div>
		<div class="control-group">
			<div class="span6">
				<label class="control-label">
					Template
				</label>
				<div class="controls">
				 <select name="template">
					<cfloop query="rsTemplates">
						<option>#rsTemplates.name#</option>
					</cfloop>		
				</select>
				</div>
			</div>
		</div>
	</div>
	<div class="fieldset">
		<div class="legend">
			<h2>Content Staging
			</h2>
		</div>
	<cfif not rc.hasChangesets>
		<div class="control-group">
			<div class="span12">
				<p>Please note; it is highly recommended that you enable content staging (Change Sets) for this site. This will allow you
				to publish the imported translations in a more controlled fashion.</p>
				<li>
					<strong>Draft:</strong> Will set imported translations as the current draft version. This will overwrite any existing draft.
				</li>
				<li>
					<strong>Publish:</strong> Will publish all imported translations immediately.
				</li>
			</div>
			<div class="control-group">
				<div class="span6">
					<label class="control-label">
						Import Content Status
					</label>
					<div class="controls">
					 <select name="import_status">
						<option value="draft">Set As Draft</option>
						<option value="publish">Publish Immediately</option>
					</select>
					</div>
				</div>
			</div>
		</div>
	<cfelse>
		<div class="control-group">
			<div class="span6">
				<label class="control-label">
					Content Staging Method
				</label>
				<div class="controls">
				 <select name="staging_type" id="staging_type">
					<option value="existing">Use Existing Change Set(s)</option>
					<option value="export">Duplicate Export Change Set(s)</option>
					<option value="new">Create New Change Set</option>
					
					<option value="draft">Set As Draft</option>
					<option value="publish">Publish Immediately</option>
				</select>
				</div>
			</div>
		</div>
		<div class="control-group sc-group" id="changeset_existing_section">
			<div class="span6">
				<label class="control-label">
					Available Change Set(s) 
				</label>
				<div class="controls">
				 <select name="changeset_existing">
						<cfloop query="rc.rsChangeSets">
							<option value="#changesetID#">#name#</option>
						</cfloop>
				</select>
				</div>
			</div>
		</div>
		<div class=" sc-group" id="changeset_source_section" style="display: none">
			<div class="control-group">
				<div class="span6">
					<label class="control-label">
						Site
					</label>
					<div class="controls">
						 <select name="changeset_sites" id="changeset_source">
							<cfloop query="rc.sites">
								<cfif rc.sites.siteID neq $.event('siteID')>
								<option value="#rc.sites.siteID#">
									#rc.sites.siteID#
								</option>
								</cfif>
							</cfloop>
						</select>			
					</div>
				</div>
			</div>
			<div class="control-group" <cfif not rc.rsExternalChangeSets.recordCount>style="display: none"</cfif> id="changeset_new_section">
				<div class="span6">
					<label class="control-label">
						Change Set 
					</label>
					<div class="controls">
						 <select name="changeset_new" id="changeset_new">
							<cfloop query="rc.rsExternalChangeSets">
								<option value="#changesetID#">#name#</option>
							</cfloop>
						</select>			
					</div>
				</div>
			</div>
		</div>||now||
		<div class="control-group sc-group" id="changeset_default_section" style="display: none">
			<div class="span6">
				<label class="control-label">
					<span id="changeset_prefix">
					Default
					</span>
					Change Set Name
				</label>
				<div class="controls">
					<input class="text" type="text" name="changeset_default">
				</div>
			</div>
		</div>
		
	</cfif>
	</div>
		<div class="form-actions">
			<a href="../" class="btn">Cancel</a>
			<input type="submit" value="Import" class="btn"/>
			<input type="hidden" name="doaction" value="doimport"/>
		</div>

	</form>
</cfoutput>
<script language="JavaScript">
jQuery(document).ready( function(){
	jQuery("#staging_type").change( function() {
		jQuery(".sc-group").hide();
		jQuery("#changeset_prefix").hide();

		if( jQuery(this).val() == "export" )
		{
			jQuery("#changeset_source_section").show();
//			jQuery("#changeset_default_section").show();
			jQuery("#changeset_prefix").show();
		}
		else if( jQuery(this).val() == "existing" )
		{
			jQuery("#changeset_existing_section").show();
//			jQuery("#changeset_default_section").show();
			jQuery("#changeset_prefix").show();
		}
		else if( jQuery(this).val() == "new" )
		{
			jQuery("#changeset_default_section").show();
		}
		else {
			jQuery("#changeset_prefix").show();
		}
	});
	
	jQuery("#changeset_source").change( function() {
		$.post("../cfcs/remoteBits.cfc?method=getStageNames&siteID=" + $(this).val(), {}, function(_resp) {
			try {
				resp = eval('(' + _resp + ')');
				
				$("#changeset_new").empty();
				$("#changeset_new_section").hide();

				$.each(resp, function(value, key) {   
					$("#changeset_new_section").show();
				     $('#changeset_new')
				         .append($("<option></option>")
				         .attr("value",key)
				         .text(value)); 
				});			
				
			} catch(err) {
				resp = _resp;
				alert(resp);
			}
		});	
	});	
	
});
</script>
