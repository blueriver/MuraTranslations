<cfoutput><page id="#contentData.contentID#" siteID="#contentData.siteID#">
<htmltitle><![CDATA[
#contentData.htmltitle#
]]></htmltitle><title><![CDATA[
#contentData.title#
]]></title><body><![CDATA[
#contentData.body#
]]></body><cfif extendData.recordcount>
<extended><cfloop query="extendData"><cfif len(extendData.attributevalue)>
	<#extendData.name#><![CDATA[#extendData.attributevalue#]]></#extendData.name#></cfif></cfloop>
</extended></cfif>
</page></cfoutput>
