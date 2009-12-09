<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: OpenID ObjectAdmin Cell --->

<cfset stLocal.stUser = application.fapi.getContentObject(objectid=application.factory.oUtils.listSlice(stObj.username,1,-2,"_"),typename="rpxUser") />

<cfif structkeyexists(stLocal.stUser,"openid") and len(stLocal.stUser.openid)>
	<cfoutput>#stLocal.stUser.openid#</cfoutput>
</cfif>


<cfsetting enablecfoutputonly="false" />