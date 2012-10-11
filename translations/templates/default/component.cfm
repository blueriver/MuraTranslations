<cfoutput><page id="#contentData.contentID#" siteID="#contentData.siteID#">
<htmltitle>
#contentData.htmltitle#
</htmltitle><body>
#contentData.body#
</body><cfif extendData.recordcount>
<extended><cfloop query="extendData"><cfif len(extendData.attributevalue)>
	<#extendData.name#>#extendData.attributevalue#</#extendData.name#></cfif></cfloop>
</extended></cfif>
</page></cfoutput>