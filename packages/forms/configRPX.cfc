<cfcomponent displayname="Janrain Engage Plugin" hint="Janrain Engage user directory settings." extends="farcry.core.packages.forms.forms" output="false" key="rpx">

	<cfproperty 
		name="realm" type="string" 
		ftSeq="1" ftFieldSet="Janrain Engage Setup" ftLabel="Realm" 
		fthint="Janrain Engage realm. For example, farcrycore assuming a set up of farcrycore.rpxnow.com" />

	<cfproperty 
		name="apikey" type="string" 
		ftSeq="2" ftFieldSet="Janrain Engage Setup" ftLabel="API Key"
		fthint="Janrain Engage API key." />
	
</cfcomponent>