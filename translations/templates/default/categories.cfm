<cfoutput><categories siteID="#arguments.rscontentcategories.siteID#">
<cfloop query="arguments.rscontentcategories"><category id="#rscontentcategories.categoryid#">
#rscontentcategories.name#
</category>
</cfloop></categories>
</cfoutput>