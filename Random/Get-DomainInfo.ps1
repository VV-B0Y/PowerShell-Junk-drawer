# Simple function to gather domain info  *Inspired by @itchallenges on IG
# Author: Jerome
# Example: Get-DomainLocation -Domain 'google.com'

function Get-DomainInfo {
	param(
		[Parameter(Mandatory = $true)]
		[String]$Domain
	)
	$URI = 'http://ip-api.com/json/{0}?fields=66846719' -f $Domain
	Invoke-RestMethod $URI

}
