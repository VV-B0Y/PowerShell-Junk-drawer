Using Namespace Microsoft.VisualBasic
Add-Type  -AssemblyName  Microsoft.VisualBasic
function OrphanedGuests {
	$Creds = Get-ChildItem 'C:\Temp\Cred' | Out-GridView  -OutputMode Multiple

	foreach ($Cred in $Creds) {
		$UserCredential = Import-Clixml -Path "C:\Temp\Cred\$cred"
		Import-Module AzureAD
		$AAD = Connect-AzureAD -Credential $UserCredential #| Out-Null
		$Tenant = ($AAD.TenantDomain).Split('.')[0]

		$OrphanedInvite = Get-AzureADUser -All $true | Where-Object UserState -EQ 'PendingAcceptance'

		foreach ($Orphan in $OrphanedInvite) {

			$beg = $Orphan.UserStateChangedOn
			$end = Get-Date
			$Days = [DateAndTime]::DateDiff([DateInterval]::Day, $beg, $end)

			if ($Days -lt 60) {
				[PSCustomObject]@{
					Name           = $Orphan.DisplayName
					Mail           = $Orphan.Mail
					Id             = $Orphan.ObjectId
					Status         = $Orphan.UserState
					InvitationDate = ($Orphan.UserStateChangedOn).Split('T')[0]
					DaysOrphaned   = $Days
				}  #| Export-Csv "C:\temp\$Tenant-orphans.csv" -Append -NoTypeInformation

				$Check = Read-Host 'Press "Y" then ENTER to confirm the removal of ' $Orphan.DisplayName "orphaned for $days days"

				if ($Check -eq 'y') {
					Remove-AzureADUser -ObjectId $Orphan.ObjectId
					Write-Host $Orphan.DisplayName 'has been removed.'
				}
				else {
					Write-Host $Orphan.DisplayName 'has NOT been removed.'
				}
			}
		}
	}
}
OrphanedGuests