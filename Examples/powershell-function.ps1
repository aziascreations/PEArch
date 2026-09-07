
function Test-PEArch {
	param(
		[string]$FilesWildcard,
		[int]$ExpectedArchCode,
		[string]$FailMessage
	)
	
	Write-Host "Checking $FilesWildcard"
	Get-ChildItem "$FilesWildcard" | ForEach-Object {
		Write-Host "-> $($_.BaseName)"
		pearch /AsError "$($_.FullName)" > $null
		if ($LASTEXITCODE -ne $ExpectedArchCode) { Write-Host "--> $FailMessage" }
	}
}

Test-PEArch -FilesWildcard "$env:WINDIR\System32\*.dll" -ExpectedArchCode 34404 -FailMessage "Mismatched architecture"
Test-PEArch -FilesWildcard "$env:WINDIR\SysWOW64\*.dll" -ExpectedArchCode 332   -FailMessage "Unsupported architecture"

Read-Host "Press Enter to continue"
