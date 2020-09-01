<#
Author: VV-B0Y
Name: Get-Five
Description: Inspired by a post i saw in r/python: https://www.reddit.com/r/Python/comments/hvq628/randomly_generate_69420_generate_random_5digit/
¯\_(ツ)_/¯: Generate a random five digit number until 42069 is generated.
Date: 7/22/2020
#>
function Get-Five {
	$TraceVerboseTimer = New-Object System.Diagnostics.Stopwatch
	$TraceVerboseTimer.Start()
	$Counter = 0

	while ((Get-Random -Minimum 10000 -Maximum 99999) -ne 42069) {
		$Counter++
	}

	$TraceVerboseTimer.Stop()
	Write-Host `n('It took {0} tries and {1} seconds to reach 42069!' -f $Counter, ($TraceVerboseTimer.ElapsedMilliseconds / 1000))

}
Get-Five

while ((Read-Host ' Do you want to try again? [Y/N?]') -eq 'y') {
	Get-Five
}

Write-Host `n(@('Au Revoir!', 'Adiós!', 'Arrivederci!', 'Ciao!', 'Sayonara!', 'Bon Voyage!', 'Vale!', 'Shalom!', 'Totsiens!') | Get-Random)

