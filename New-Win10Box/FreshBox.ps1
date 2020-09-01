#Requires -RunAsAdministrator

[cmdletbinding()]
param (
	[switch]$UACNoConsent
)

# Execution policies
Set-ExecutionPolicy RemoteSigned -Scope Process
Set-ExecutionPolicy Unrestricted -Scope LocalMachine

# Disable BitLocker
manage-bde -off C:

if ($UACNoConsent) {
	# Regkey to turn off UAC consent prompt behavior for Admins; NOT disabling UAC
	Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'ConsentPromptBehaviorAdmin' -Value 0
}

Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Setup PSGallery
Install-PackageProvider -Name Nuget -Scope CurrentUser -Force -Confirm:$false

# Install modules with required version (Windows Powershell Profile Dependencies)
$RvModList = @{
	'Configuration'    = '1.3.1'
	'Environment'      = '1.1.0'
	'DefaultParameter' = '1.7'
	'Pansies'          = '1.2.1'
	'Powerline'        = '3.1.2'
	'Terminal-Icons'   = '0.1.1'
}
ForEach ($RvModule in $RvModList.Keys) {
	Install-Module $RvModule -RequiredVersion $RvModList[$RvModule] -Force -Confirm:$false
}

# Install modules (No req version)
$ModList = @(
	'AzureAD'
	'MicrosoftTeams'
	'PsKoans'
	'Posh365'
)
ForEach ($Module in $ModList) {
	Install-Module $Module -Force -Confirm:$false
}


$PackageList = @(
	'discord'
	'everything'
	'FireFox'
	'git'
	'GoogleChrome'
	'microsoft-windows-terminal'
	'microsoft-teams'
	'notepadplusplus.install'
	'powertoys'
	'sharex'
	'vmware-workstation-player'
	'vmware-tools'
	'VsCode'
	'vscode-csharpextensions'
	'vscode-powershell'
)

choco install $PackageList -fy

# Alias "pog" stands for "pretty log"
git config --global alias.pog "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Make a place for Git repos to live
New-Item -Path c:\git -ItemType Directory -Force -ErrorAction 0
New-Item -Path c:\temp -ItemType Directory -Force -ErrorAction 0

# Show extensions for known file types; current user
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0

# Show extensions for known file types; all users
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\HideFileExt" -Name "DefaultValue" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\HideFileExt" -Name "CheckedValue" -Value 0

# Install WSL & make v2 default
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

do {
	$WslVersion = wsl --set-default-version 2
	if (($WslVersion).split(':')[0] -eq 'Error') {
		Invoke-RestMethod https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -OutFile c:/temp/wsl2.msi
		\.\temp\wsl2.msi /quiet
	}
} until (($WslVersion).split(':')[0] -ne 'Error')

# Import My Windows Posh Profile
$WpProfile = (Invoke-WebRequest 'https://gist.githubusercontent.com/VV-B0Y/962f6baed1f09b4eedc06ceb2baa0535/raw/bf16bcacb38bb9083ce6afb337c6263837b880e6/Microsoft.PowerShell_profile.ps1' -UseBasicParsing).Content
Set-Content -Value $WpProfile -Path "$env:USERPROFILE/Documents/WindowsPowershell/Microsoft.PowerShell_profile.ps1"

# Import My Windows Terminal Settings
$WtSettingPath = (Get-ChildItem -Directory $env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_*\LocalState\).fullname
$wtProfileContent = (Invoke-WebRequest 'https://gist.githubusercontent.com/VV-B0Y/c327d1c9a585b200ca3fe159999ea1f9/raw/f8c2080fc3aa77a448f159988c6c498f6881c20b/settings.json' -UseBasicParsing).Content
Set-Content -Value $wtProfileContent -Path ('{0}\{1}' -f $WtSettingPath, 'settings.json')