# Simple function to gather domain info  *Inspired by @itchallenges on IG
# Author: Jerome
# Example: Get-DomainInfo -Domain 'google.com'
function Get-DomainInfo {
	param(
		[String]$Domain
	)
	$IP = (Resolve-DnsName $Domain).IPAddress
	$URI = 'http://ip-api.com/json/{0}?fields=66846719' -f $IP
	Invoke-RestMethod $URI
}
