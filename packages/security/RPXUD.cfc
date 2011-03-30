<cfcomponent displayname="OpenID" hint="RPX User Directory" extends="farcry.core.packages.security.UserDirectory" output="false" key="rpx">
	
	<cffunction name="getLoginForm" access="public" output="false" returntype="string" hint="Returns the form component to use for login">
		
		<cfreturn "rpxLogin" />
	</cffunction>
	
	<cffunction name="authenticate" access="public" output="false" returntype="struct" hint="Attempts to process a user. Runs every time the login form is loaded.">
		<cfset var stResult = structnew() />
		<cfset var stResponse = structnew() />
		<cfset var xmlInfo = "" />
		<cfset var qMatch = "" />
		<cfset var oUser = application.fapi.getContentType(typename="rpxUser") />
		<cfset var stUser = structnew() />
		<cfset var cleanedOpenIDPos = "" />
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<cfif structkeyexists(form,"token")>
			<cfhttp url="https://rpxnow.com/api/v2/auth_info?format=xml" method="POST" result="stResponse">
				<cfhttpparam type="formfield" name="apiKey" value="#application.config.rpx.apikey#" />
				<cfhttpparam type="formfield" name="token" value="#form.token#" />
			</cfhttp>
			
			<cfset xmlInfo = xmlparse(stResponse.filecontent) />
			
			<cfif xmlInfo.rsp.XMLAttributes.stat eq "ok">
				<cfset session.openid = xmlInfo />
				
				<cfquery datasource="#application.dsn#" name="qMatch">
					select	u.objectid
					from	rpxUser u
					where	openid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.openid.rsp.profile.identifier.xmlText#" />
				</cfquery>
				
				<cfif qMatch.recordcount>
				
					<cfset stResult.authenticated = "true" />
					<cfset stResult.userid = qMatch.objectid />
					<cfset stResult.ud = "RPX" />
					
				<cfelse>
				
					<cfset stUser = oUser.getData(objectid=createuuid()) />
					<cfset stUser.openid = session.openid.rsp.profile.identifier.xmlText />
					<cfif session.openid.rsp.profile.providerName.xmlText eq "GoogleApps">
						<cfset cleanedOpenIDPos = refindnocase("^[^@]*@(.*)$",session.openid.rsp.profile.verifiedEmail.xmlText,1,true) />
						<cfset stUser.providerDomain = mid(session.openid.rsp.profile.verifiedEmail.xmlText,cleanedOpenIDPos.pos[2],cleanedOpenIDPos.len[2]) />
					<cfelse>
						<cfset cleanedOpenIDPos = refindnocase("^https?://([^/]*)/",stUser.openid,1,true) />
						<cfset stUser.providerDomain = mid(stUser.openid,cleanedOpenIDPos.pos[2],cleanedOpenIDPos.len[2]) />
					</cfif>
					<cfset oUser.setData(stProperties=stUser) />
					
					<cfset stResult.authenticated = "true" />
					<cfset stResult.userid = stUser.objectid />
					<cfset stResult.ud = "RPX" />
					
				</cfif>
				
			<cfelse>
			
				<cfset stResult.authenticated = "false" />
				<cfset stResult.message = "OpenID authentication failed" />
				<cfset stResult.userid = "" />
				<cfset stResult.ud = "RPX" />
				
			</cfif>
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="getUserGroups" access="public" output="false" returntype="array" hint="Returns the groups that the specified user is a member of">
		<cfargument name="userID" type="string" required="false" default="" hint="The user being queried" />
		<cfargument name="openID" type="string" required="false" default="" hint="The user being queried" />
		
		<cfset var qGroups = "" />
		<cfset var aGroups = arraynew(1) />
		<cfset var stUser = application.fapi.getContentObject(typename="rpxUser",objectid=arguments.userID) />
		<cfset var providerDomain = "" />
		<cfset var cleanedOpenIDPos = "" />
		
		<cfif len(arguments.openID)>
			<cfset cleanedOpenIDPos = refindnocase("^https?://([^/]*)/",stUser.openid,1,true) />
			<cfset providerDomain = mid(arguments.openid,cleanedOpenIDPos.pos[2],cleanedOpenIDPos.len[2]) />
		</cfif>
		
		<cfquery datasource="#application.dsn#" name="qGroups">
			select	title
			from	#application.dbowner#rpxGroup
			where	objectid in (
						select	data
						from	#application.dbowner#rpxUser_aGroups
						where	parentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stUser.objectid#" />
					)
					or objectid in (
						select	parentid
						from	#application.dbowner#rpxGroup_aDomains
						where	data=<cfqueryparam cfsqltype="cf_sql_varchar" value="*" />
								or data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#stUser.providerDomain#" />
								or data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#providerDomain#" />
					)
		</cfquery>
		
		<cfloop query="qGroups">
			<cfset arrayappend(aGroups,title) />
		</cfloop>
		
		<cfreturn listtoarray(valuelist(qGroups.title)) />
	</cffunction>
	
	<cffunction name="getAllGroups" access="public" output="false" returntype="array" hint="Returns all the groups that this user directory supports">
		<cfset var qGroups = "" />
		<cfset var aGroups = arraynew(1) />
		
		<cfquery datasource="#application.dsn#" name="qGroups">
			select		*
			from		#application.dbowner#rpxGroup
			order by	title
		</cfquery>
		
		<cfloop query="qGroups">
			<cfset arrayappend(aGroups,title) />
		</cfloop>

		<cfreturn aGroups />
	</cffunction>

	<cffunction name="getGroupUsers" access="public" output="false" returntype="array" hint="Returns all the users in a specified group">
		<cfargument name="group" type="string" required="true" hint="The group to query" />
		
		<cfset var qUsers = "" />
		
		<cfquery datasource="#application.dsn#" name="qUsers">
			select	objectid
			from	#application.dbowner#rpxUser
			where	objectid in (
						select	parentid
						from	#application.dbowner#rpxUser_aGroups ug
								inner join
								#application.dbowner#rpxGroup g
								on ug.data=g.objectid
						where	g.title=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.group#" />
								or objectid in (
									select	parentid
									from	#application.dbowner#rpxGroup_aDomains
									where	data=<cfqueryparam cfsqltype="cf_sql_varchar" value="*" />
											or data=rpxUser.providerDomain
								)
					)
		</cfquery>
		
		<cfreturn listtoarray(valuelist(qUsers.objectid)) />
	</cffunction>
	
	<cffunction name="getProfile" access="public" output="false" returntype="struct" hint="Returns profile data available through the user directory">
		<cfargument name="userid" type="string" required="true" hint="The user directory specific user id" />
		<cfargument name="currentprofile" type="struct" required="false" hint="The current user profile" />
		
		<cfset var stProfile = structnew() />
		
		<cfif isdefined("session.openid")>
						
			<cfif XmlSearch(session.openid,"count(rsp/profile/name/givenName)")>
				<cfset stProfile.firstname = session.openid.rsp.profile.name.givenName.xmlText />
				<cfset stProfile.lastname = session.openid.rsp.profile.name.familyName.xmlText />
			<cfelseif XmlSearch(session.openid,"count(rsp/profile/name/formatted)")>
				<cfset formattedName = session.openid.rsp.profile.name.formatted.xmlText>
				<cfset blankPos = find(" ",formattedName)>
				<cfset stProfile.firstname = Left(formattedName,blankPos)>
				<cfset stProfile.lastname = Right(formattedName,len(formattedName)-blankPos)>
			<cfelseif XmlSearch(session.openid,"count(rsp/profile/displayName)")>
				<cfset stProfile.firstname = session.openid.rsp.profile.displayName.xmlText />
			</cfif>
			<cfset stProfile.label = stProfile.firstname & " " & stProfile.lastname>
			
			<cfif XmlSearch(session.openid,"count(rsp/profile/verifiedEmail)")>
				<cfset stProfile.emailaddress = session.openid.rsp.profile.verifiedEmail.xmlText />
			<cfelseif XmlSearch(session.openid,"count(rsp/profile/email)")>
				<cfset stProfile.emailaddress = session.openid.rsp.profile.email.xmlText />				
			</cfif>
			<cfset stProfile.override = true />
		</cfif>
		
		<cfreturn stProfile />
	</cffunction>
	
	<cffunction name="isEnabled" access="public" output="false" returntype="boolean" hint="Returns true if this user directory is active. This function can be overridden to check for the existence of config settings.">
		
		<cfreturn isdefined("application.config.rpx.realm") and len(application.config.rpx.realm) and isdefined("application.config.rpx.apikey") and len(application.config.rpx.apikey) />
	</cffunction>
	
</cfcomponent>