<cfdirectory action="list" directory="#expandPath("/#pluginConfig.getDirectory()#")#/translations/templates" name="rsTemplates" type="dir">
<cfsilent>
	<cfset hasChangesets = $.getBean('settingsManager').getSite($.event('siteID')).getValue('hasChangesets') />
	<cfset enforceChangesets = $.getBean('settingsManager').getSite($.event('siteID')).getValue('enforceChangesets') />
	<cfset sites = pluginConfig.getAssignedSites() />
	<cfset rsChangeSets = $.getBean("changesetManager").getQuery( siteID=$.event('siteID'),published=0 ) />
	<cfset rsExternalChangeSets = $.getBean("changesetManager").getQuery( siteID=sites.siteID,published=0 ) />
</cfsilent>

<cfoutput>
	
	<h2>Import Site (Beta)</h2>
	<form class="fieldset-wrap" action="./index.cfm" method="post" onsubmit="return validateForm(this);" enctype="multipart/form-data">
	<input type="hidden" name="export_action" value="import">

		<div class="mura-control-group">
			<label>
			Zip File
			</label>
			<input class="text" type="file" name="import_file" data-required="true">
		</div>
		<div class="mura-control-group">
				<label>
					Template
				</label>
				 <select name="template">
					<cfloop query="rsTemplates">
						<option>#rsTemplates.name#</option>
					</cfloop>		
				</select>
	</div>
		<h2>Content Staging</h2>
		<div id="content_data">
			<div id="content_mode_existing" class="help-block content_mode" style="display: none">
				<p>
					Select an existing Change Set to import your translated content into.
				</p>
			</div>
			<div id="content_mode_export" class="help-block content_mode" style="display: none">
				<p>
					Select an existing Change Set from another site. The Change Set and its related settings will be copied here.
				</p>
			</div>
			<div id="content_mode_new" class="help-block content_mode" style="display: none">
				<p>
					Create a new Change Set to import your translated content into.
				</p>
			</div>
		<cfif not hasChangesets>

				<p>Please note; it is highly recommended that you enable content staging (Change Sets) for this site. This will allow you
				to publish the imported translations in a more controlled fashion.</p>
				<p>
					<strong>Draft:</strong> Will set imported translations as the current draft version. This will overwrite any existing draft.
				</p>
				<p>
					<strong>Publish:</strong> Will publish all imported translations immediately.
				</p>

			<div class="mura-control-group">
					<label>
						Import Content Status
					</label>
					 <select name="import_status">
						<option value="draft">Set As Draft</option>
						<option value="publish">Publish Immediately</option>
					</select>
			</div>
	<cfelse>
		<div class="mura-control-group">
				<label>
					Content Staging Method
				</label>
				 <select name="staging_type" id="staging_type">
					<cfif rsChangeSets.recordCount>
					<option value="existing">Use Existing Change Set</option>
					</cfif>
					<option value="export">Duplicate External Change Set</option>
					<option value="new">Create New Change Set</option>
					<cfif not enforceChangesets>
						<option value="draft">Set As Draft</option>
						<option value="publish">Publish Immediately</option>
					</cfif>
				</select>
		</div>
		<div class="mura-control-group sc-group" id="changeset_existing_section">
				<label>
					Available Change Set(s) 
				</label>
				 <select name="changeset_existing" data-required="true">
						<cfloop query="rsChangeSets">
							<option value="#changesetID#">#name#</option>
						</cfloop>
				</select>
		</div>
		<div class=" sc-group" id="changeset_source_section" style="display: none">
			<div class="mura-control-group">
				<label>
					Site
				</label>
				 <select name="changeset_sites" id="changeset_source">
					<cfloop query="sites">
						<cfif sites.siteID neq $.event('siteID')>
						<option value="#sites.siteID#">
							#sites.siteID#
						</option>
						</cfif>
					</cfloop>
				</select>			
			</div>
			<div class="mura-control-group" <cfif not rsExternalChangeSets.recordCount>style="display: none"</cfif> id="changeset_new_section">
				<label>
					Change Set 
				</label>
				 <select name="changeset_new" id="changeset_new">
					<cfloop query="rsExternalChangeSets">
						<option value="#changesetID#">#name#</option>
					</cfloop>
				</select>			
			</div>
		</div>
		<div class="mura-control-group sc-group" id="changeset_default_section" style="display: none">
			<label>
				<span id="changeset_prefix">
				Default
				</span>
				Change Set Name
			</label>
			<input class="text" type="text" name="changeset_default" id="changeset_default">
		</div>
		
	</cfif>

	<div class="mura-actions">
		<div class="form-actions">
			<a href="../" class="btn">Cancel</a>
			<input type="submit" value="Import" class="btn"/>
			<input type="hidden" name="doaction" value="doimport"/>
		</div>
	</div>

	</form>
</cfoutput>
<script language="JavaScript">
jQuery(document).ready( function(){
	jQuery("#staging_type").change( function() {
		updateDrops();
	});
	
	function updateDrops() {
		_tgt = jQuery("#staging_type");
		
		jQuery(".sc-group").hide();
		jQuery("#changeset_prefix").hide();
		jQuery(".content_mode").hide();
		jQuery("#changeset_default").removeAttr('data-required');

		if( jQuery(_tgt).val() == "export" )
		{
			jQuery("#changeset_source_section").show();
//			jQuery("#changeset_default_section").show();
			jQuery("#changeset_prefix").show();
			jQuery("#content_mode_export").show();
		}
		else if( jQuery(_tgt).val() == "existing" )
		{
			jQuery("#changeset_existing_section").show();
//			jQuery("#changeset_default_section").show();
			jQuery("#changeset_prefix").show();
			jQuery("#content_mode_existing").show();
		}
		else if( jQuery(_tgt).val() == "new" )
		{
			jQuery("#changeset_default_section").show();
			jQuery("#content_mode_new").show();
			jQuery("#changeset_default").attr('data-required',true);
		}
		else {
			jQuery("#changeset_prefix").show();
		}		
	}
	
	updateDrops();
	
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
