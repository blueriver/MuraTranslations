<cfoutput>
	<h4>External Translations (Beta)</h4>
	<div class="block-content">
		<input type="hidden" name="export_action" value="download">
		<div class="help-block-inline help-block-success">
		 Import Complete
		</div>

		<cfif len(report)>
			<div class="help-block-inline help-block-error">Error Report:<br>
			#paragraphFormat(report)#
			</div>
		</cfif>

		<div class="mura-control-group">
			<a class="btn" href="../##tabTranslate"><i class="mi-arrow-left"></i> Back</a>
		</div>
	</div>
</cfoutput>