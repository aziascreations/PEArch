@echo off
setlocal enabledelayedexpansion

set "BUILDDIR=%~dp0Build"

pushd %CD%
cd /d %~dp0

for /d %%D in ("%BUILDDIR%\*") do (
    if exist "%BUILDDIR%\pearch%%~nxD.zip" del "%BUILDDIR%\pearch%%~nxD.zip"
    pushd "%%D"
    "C:\Program Files\7-Zip\7z.exe" a -tzip "%BUILDDIR%\pearch-%%~nxD.zip" *
    popd
)

popd

endlocal

pause
