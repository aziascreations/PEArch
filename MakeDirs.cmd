@echo off
setlocal enabledelayedexpansion

set "BUILDDIR=%~dp0Build"

rmdir /Q /S %BUILDDIR%

mkdir "%BUILDDIR%\msvcrt-x64"
mkdir "%BUILDDIR%\msvcrt-x86"

mkdir "%BUILDDIR%\ucrt-x64"
mkdir "%BUILDDIR%\ucrt-x86"
mkdir "%BUILDDIR%\ucrt-arm64"

mkdir "%BUILDDIR%\msvcrt-x64-english"
mkdir "%BUILDDIR%\msvcrt-x86-english"

mkdir "%BUILDDIR%\ucrt-x64-english"
mkdir "%BUILDDIR%\ucrt-x86-english"
mkdir "%BUILDDIR%\ucrt-arm64-english"

mkdir "%BUILDDIR%\msvcrt-x64-french"
mkdir "%BUILDDIR%\msvcrt-x86-french"

mkdir "%BUILDDIR%\ucrt-x64-french"
mkdir "%BUILDDIR%\ucrt-x86-french"
mkdir "%BUILDDIR%\ucrt-arm64-french"

popd

endlocal

pause
