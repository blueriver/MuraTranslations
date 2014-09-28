<cfoutput>
	<cfparam name="report" default="" >
	<input type="hidden" name="export_action" value="download">
	<h3>Import Complete</h3>
	
	<cfif len(report)>
		<h4>Error Report</h4>
#paragraphFormat(report)#
	</cfif>
	
	<a href="../">Back</a>
</cfoutput>