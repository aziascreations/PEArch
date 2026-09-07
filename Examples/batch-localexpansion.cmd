@echo off
setlocal enabledelayedexpansion

echo Checking System32
for %%f in (%WINDIR%\System32\*.dll) do (
	echo -^> %%~nf
	pearch /AsError "%%f" > nul
	if !ERRORLEVEL! neq 34404 echo --^> Mismatched architecture
)

echo Checking SysWOW64
for %%f in (%WINDIR%\SysWOW64\*.dll) do (
	echo -^> %%~nf
	pearch /AsError "%%f" > nul
	if !ERRORLEVEL! neq 332 echo --^> Unsupported architecture
)

pause
