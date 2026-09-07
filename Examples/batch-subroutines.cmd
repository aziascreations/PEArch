@echo off


:: Expecting x64 (0x8664 / 34404)
:: We will tolerate other architectures
echo Checking System32

for %%f in (%WINDIR%\System32\*.dll) do (
	call :sub-pearch %%~nf %%f 34404 0
)


:: Expecting x86 (0x14c / 332)
:: We won't tolerate other architectures
echo Checking SysWOW64

for %%f in (%WINDIR%\SysWOW64\*.dll) do (
	call :sub-pearch %%~nf %%f 332 1
)

goto end



:sub-pearch
:: We must use a subroutine since %ERRORLEVEL% tends to fail in loops
:: %1 -> Filename without folder
:: %2 -> Filename with path
:: %3 -> Expected PE architecture
:: %4 -> 1 if mismatch is fatal, 0 is not

echo -^> %1
pearch /AsError "%2" > nul

if %ERRORLEVEL% equ %3 goto sub-pearch-good
if %ERRORLEVEL% neq %3 goto sub-pearch-bad
echo --^> Failed to check architecture ^!^!^!
exit /b

:sub-pearch-good
exit /b

:sub-pearch-bad
if %4 equ 1 goto sub-pearch-fatal
echo --^> Mismatched architecture
exit /b

:sub-pearch-fatal
echo --^> Unsupported architecture
exit /b

:sub-pearch-end



:end
pause
