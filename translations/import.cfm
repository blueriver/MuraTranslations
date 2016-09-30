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
	<div class="fieldset">
		<div class="control-group">
			<div class="span6">
				<label class="control-label">
					Zip File
				</label>
				<div class="controls">
				  <input class="text" type="file" name="import_file" data-required="true">
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
		<h2>Content Staging
		</h2>
		<div id="content_data" class="span11">
			<div id="content_mode_existing" class="alert content_mode" style="display: none">
				<p>
					Select an existing Change Set to import your translated content into.
				</p>
			</div>
			<div id="content_mode_export" class="alert content_mode" style="display: none">
				<p>
					Select an existing Change Set from another site. The Change Set and its related settings will be copied here.
				</p>
			</div>
			<div id="content_mode_new" class="alert content_mode" style="display: none">
				<p>
					Create a new Change Set to import your translated content into.
				</p>
			</div>
		</div>
	<cfif not hasChangesets>
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
			</div>
		</div>
		<div class="control-group sc-group" id="changeset_existing_section">
			<div class="span6">
				<label class="control-label">
					Available Change Set(s) 
				</label>
				<div class="controls">
				 <select name="changeset_existing" data-required="true">
						<cfloop query="rsChangeSets">
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
							<cfloop query="sites">
								<cfif sites.siteID neq $.event('siteID')>
								<option value="#sites.siteID#">
									#sites.siteID#
								</option>
								</cfif>
							</cfloop>
						</select>			
					</div>
				</div>
			</div>
			<div class="control-group" <cfif not rsExternalChangeSets.recordCount>style="display: none"</cfif> id="changeset_new_section">
				<div class="span6">
					<label class="control-label">
						Change Set 
					</label>
					<div class="controls">
						 <select name="changeset_new" id="changeset_new">
							<cfloop query="rsExternalChangeSets">
								<option value="#changesetID#">#name#</option>
							</cfloop>
						</select>			
					</div>
				</div>
			</div>
		</div>
		<div class="control-group sc-group" id="changeset_default_section" style="display: none">
			<div class="span6">
				<label class="control-label">
					<span id="changeset_prefix">
					Default
					</span>
					Change Set Name
				</label>
				<div class="controls">
					<input class="text" type="text" name="changeset_default" id="changeset_default">
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
