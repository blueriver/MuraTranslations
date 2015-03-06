<cfoutput>
<cfsilent>
	<cfset theURL = application.configBean.getContext() & translationManager.lookUpTranslation(event.getValue('crumbdata'),event.getValue('siteid'),event.getContentRenderer(),true)/>
	<cfset hrefLang = translationManager.getHrefLang(application.settingsManager.getSite(event.getValue('siteid'))) />
	<cfif not find("://",theUrl)>
		<cfif cgi.https eq "on">
			<cfset protocol = "https" />
		<cfelse>
			<cfset protocol = "http" />
		</cfif>
		<cfset theUrl = protocol & "://" & cgi.http_host & theUrl />
	</cfif>
</cfsilent>
<link rel="alternate" hreflang="#hrefLang#" href="#theURL#" />
<cfloop query="rslocales"><cfsilent>
	<cfset theURL = application.configBean.getContext() & translationManager.lookUpTranslation(event.getValue('crumbdata'),rsLocales.siteid,event.getContentRenderer(),true)/>
	<cfset hrefLang = translationManager.getHrefLang(application.settingsManager.getSite(rsLocales.siteid)) />
</cfsilent><cfif find("://",theUrl)><link rel="alternate" hreflang="#hrefLang#" href="#theURL#" /></cfif>
</cfloop>
</cfoutput>