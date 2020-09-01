Clear-Host

# Get random cat fact
function Kitty {
	Write-Host (Invoke-RestMethod catfact.ninja/facts).data.fact -BackgroundColor green -ForegroundColor black
}
Kitty

trap { Write-Warning ($_.ScriptStackTrace | Out-String) }

# This timer is used by Trace-Message, I want to start it immediately
$TraceVerboseTimer = New-Object System.Diagnostics.Stopwatch
$TraceVerboseTimer.Start()

# Note these are dependencies of the Profile module, but it's faster to load them explicitly up front
Import-Module -FullyQualifiedName @{ ModuleName = "Environment"; ModuleVersion = "1.1.0" },
@{ ModuleName = "Configuration"; ModuleVersion = "1.3.1" },
@{ ModuleName = "Pansies"; ModuleVersion = "1.2.1" },
@{ ModuleName = "PowerLine"; ModuleVersion = "3.1.2" },
@{ ModuleName = "PSReadLine"; ModuleVersion = "2.0.0" },
@{ ModuleName = "DefaultParameter"; ModuleVersion = "1.7" },
@{ ModuleName = "Terminal-Icons"; ModuleVersion = "0.1.1" } #-Verbose:$false

# First call to Trace-Message, pass in our TraceTimer that I created at the top to make sure we time EVERYTHING.
# This has to happen after the verbose check, obviously
Trace-Message "Modules Imported" -Stopwatch $TraceVerboseTimer
Trace-Message "Profile Finished!" -KillTimer
Remove-Variable TraceVerboseTimer

## Relax the code signing restriction so we can actually get work done
Set-ExecutionPolicy RemoteSigned Process
$VerbosePreference = "SilentlyContinue"

#New-PromptText  "I $( "&hearts;" -fg "DarkRed") PWSH'n it> "
#Set-PowerLinePrompt -PowerLineFont -FullColor -Newline -Timestamp -Colors "#fe4450", "#ff7edb"
Set-Location '.\'

# function prompt {
# "I $(New-Text "&hearts;" -fg "DarkRed") PWSH'n it> "
# Set-PowerLinePrompt -SetCurrentDirectory -Newline -Timestamp -Colors "#fe4450", "#ff7edb"
# $Host.UI.RawUI.WindowTitle = ( Get-Date -UFormat '%m/%d/%y %R').Tostring()
# }
# [System.Collections.Generic.List[ScriptBlock]]$Prompt = @(
# { "PS " }
# { $executionContext.SessionState.Path.CurrentLocation }
# { '>' * ($nestedPromptLevel + 1) }
# { $Host.UI.RawUI.WindowTitle = ( Get-Date -UFormat '%m/%d/%y %R').Tostring() }
# )
# if (Test-Success) {
# $heart = "❤", "🧡", "💛", "💚", "💙", "💜", "💔", "💕", "💓", "💗", "💖", "💘", "💝" | Get-Random
# }
# New-PromptText "I${heart}PS" -ForegroundColor Black -BackgroundColor White -ErrorForegroundColor White -ErrorBackgroundColor DarkRed #>
# Set-PowerLinePrompt -SetCurrentDirectory -FullColor -Newline -Timestamp -Colors "#fe4450", "#ff7edb"

# Stop Teams status from showing me as idle
Function Move-Mouse {
	$WShell = New-Object -com "Wscript.Shell"
	while ($true) {
		$WShell.sendkeys("{SCROLLLOCK}")
		Start-Sleep -Milliseconds 100
		$WShell.sendkeys("{SCROLLLOCK}")
		Start-Sleep -Seconds 240
	}
}

# Connect to teams with credentials choosen from Out-GridView
function Connect-Teams {
	$creds = Get-ChildItem 'C:\Temp\cred' | Out-GridView -PassThru
	$UserCredential = Import-Clixml -Path "C:\Temp\cred\$creds"
	Connect-MicrosoftTeams -Credential $UserCredential
}

# Show weather in console
function Show-Weather {
	param (
		$city
	)
	if (-not $city) {
		(Invoke-RestMethod http://wttr.in/philadelphia)
	}
	else {
		(Invoke-RestMethod http://wttr.in/$city)
	}
}

# Get console history
function Chistory {
	(notepad++ C:\Users\$env:USERNAME\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt)
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}