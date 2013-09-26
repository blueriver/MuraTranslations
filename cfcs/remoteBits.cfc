<cfcomponent>

	<cffunction name="getStageNames" access="remote" returnformat="JSON">
		<cfargument name="siteID" type="string">

		<cfset var $ = getMScope( arguments.siteID) /> 		
	
		<cfset var rsChangeSets = $.getBean("changesetManager").getQuery( siteID=arguments.siteID,published=0 ) />
		
		<cfset var sSets = StructNew() />
	
		<cfloop query="rsChangeSets">
			<cfset sSets[name] = changesetID />
		</cfloop>

		<cfreturn serializeJSON( sSets ) />
	</cffunction>

	<cffunction name="getMScope" access="remote" returnformat="JSON">
		<cfargument name="siteID" type="string">
		
		<cfreturn application.serviceFactory.getBean("muraScope").init(arguments.siteID)>
	</cffunction>
	
</cfcomponent>