<cfcomponent displayname="RPX OpenID" hint="RPX OpenID settings" extends="farcry.core.packages.forms.forms" output="false" key="rpx">
	<cfproperty ftSeq="1" name="realm" ftFieldSet="RPX OpenID" type="string" ftLabel="Realm" />
	<cfproperty ftSeq="2" name="apikey" ftFieldSet="RPX OpenID" type="string" ftLabel="API Key" />
	<cfproperty ftSeq="3" name="defaultgroup" ftFieldSet="RPX OpenID" type="uuid" ftLabel="Default group" ftJoin="rpxGroup" ftHint="New users are automatically assigned to this group" />
	
</cfcomponent>