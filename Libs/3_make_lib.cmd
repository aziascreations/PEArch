@echo off
setlocal

pushd %CD%
cd /D "%~dp0"

call "%~dp0\0_config.cmd"

echo Checking the PATH
IF NOT EXIST %MSVC_LIB% (
    echo ^> Unable to find 'lib.exe' as indicated in '%%MSVC_DUMPBIN%%' !
    echo ^> Please check the '0_config.cmd' script !
    goto end
)
echo ^> Found 'lib.exe' at the given location !

echo Removing old '.lib' files
del /S /Q .\*.lib 2> nul

echo Iterating over all '.def' files in 'libs/' for 'x64', 'x86' and 'arm64'...
for /R ".\" %%i in (*.def) do call :sub-make-lib X64 %%i
for /R ".\" %%i in (*.def) do call :sub-make-lib X86 %%i
for /R ".\" %%i in (*.def) do call :sub-make-lib ARM64 %%i
echo Done !

:end
popd
endlocal
pause
exit /b


:sub-make-lib
echo ^> %2
pushd %~dp2
::set _RAW_DEF_NAME=%~nx2
::set _RAW_DEF_NAME=%_RAW_DEF_NAME:.raw.def=%
::echo lib.exe /nologo /def:%_RAW_DEF_NAME%.raw.def /out:%_RAW_DEF_NAME%.lib /machine:%1
::%MSVC_LIB% /nologo /def:%_RAW_DEF_NAME%.raw.def /out:%_RAW_DEF_NAME%.lib /machine:%1
mkdir .\%1
%MSVC_LIB% /nologo /def:%~nx2 /out:.\%1\%~n2.lib /machine:%1
popd
exit /b
