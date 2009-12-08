<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!--- @@Developer: Blair Mackenzie (blair@daemon.com.au) --->
<cfcomponent displayname="RPX User" hint="User model for the RPX OpenID Directory." extends="farcry.core.packages.types.types" output="false" description="">
	<cfproperty name="openid" type="string" default="" hint="The userid to use in FarCry" ftLabel="UserID" ftType="string" />
	<cfproperty name="aGroups" type="array" default="" hint="The groups this member is a member of" ftLabel="Groups" ftType="array" ftJoin="rpxGroup" />
	<cfproperty name="lGroups" type="longchar" default="" hint="The groups this member is a member of (list generated automatically)" ftLabel="Groups" ftType="arrayList" ftArrayField="aGroups" ftJoin="farGroup" />
	
	<cffunction name="addGroup" access="public" output="false" returntype="void" hint="Adds this user to a group">
		<cfargument name="user" type="string" required="true" hint="The user to add" />
		<cfargument name="group" type="string" required="true" hint="The group to add to" />
		
		<cfset var stUser = structnew() />
		<cfset var stGroup = structnew() />
		<cfset var oGroup = createObject("component", application.stcoapi["farGroup"].packagePath) />
		<cfset var i = 0 />
		
		<!--- Get the user by objectid or userid --->
		<cfif isvalid("uuid",arguments.user)>
			<cfset stUser = getData(arguments.user) />
		<cfelse>
			<cfset stUser = getByUserID(arguments.user) />
		</cfif>
	
		<cfif not isvalid("uuid",arguments.group)>
			<cfset arguments.group = oGroup.getID(arguments.group) />
		</cfif>
		
		<!--- Check to see if they are already a member of the group --->
		<cfparam name="stUser.aGroups" default="#arraynew(1)#" />
		<cfloop from="1" to="#arraylen(stUser.aGroups)#" index="i">
			<cfif stUser.aGroups[i] eq arguments.group>
				<cfset arguments.group = "" />
			</cfif>
		</cfloop>
		
		<cfif len(arguments.group)>
			<cfset arrayappend(stUser.aGroups,arguments.group) />
			<cfset setData(stProperties=stUser) />
		</cfif>
	</cffunction>

	<cffunction name="removeGroup" access="public" output="false" returntype="void" hint="Removes this user from a group">
		<cfargument name="user" type="string" required="true" hint="The user to add" />
		<cfargument name="group" type="string" required="true" hint="The group to add to" />
		
		<cfset var stUser = structnew() />
		<cfset var i = 0 />
		<cfset var oGroup = createObject("component", application.stcoapi["farGroup"].packagePath) />
		
		<!--- Get the user by objectid or userid --->
		<cfif isvalid("uuid",arguments.user)>
			<cfset stUser = getData(arguments.user) />
		<cfelse>
			<cfset stUser = getByUserID(arguments.user) />
		</cfif>
		
		<cfif not isvalid("uuid",arguments.group)>
			<cfset arguments.group = oGroup.getID(arguments.group) />
		</cfif>
		
		<!--- Check to see if they are a member of the group --->
		<cfparam name="stUser.aGroups" default="#arraynew(1)#" />
		<cfloop from="#arraylen(stUser.aGroups)#" to="1" index="i" step="-1">
			<cfif stUser.aGroups[i] eq arguments.group>
				<cfset arraydeleteat(stUser.aGroups,i) />
			</cfif>
		</cfloop>
		
		<cfset setData(stProperties=stUser) />
	</cffunction>

</cfcomponent>