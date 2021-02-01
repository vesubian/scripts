@echo off
cls

::------------------------------::
Title "Search Fix"
::------------------------------::


:: Elevating script to admin permissions
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\icacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c start cmd /c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:-------------------------------------


::-----------------------------
:: Kill cortana
::-----------------------------

taskkill /f /im searchapp.exe

::-----------------------------
:: Uninstall
::-----------------------------

cmd /c powershell "Get-AppxPackage *Search* ^| Remove-AppxPackage"

::-----------------------------
:: Remove files
::-----------------------------

taskkill /f /im searchapp.exe
pushd "%localappdata%\packages\"

for /f "tokens=* usebackq delims=" %%i in (`dir /b ^| findstr Search`) do del /f /s /q %%i

:: interactive debugging
:: for /f "tokens=* usebackq delims=" %i in (`dir /b ^| findstr Cortana`) do del /f /s /q %i

::-----------------------------
:: reinstall
::-----------------------------

taskkill /f /im searchapp.exe

cmd /c powershell.exe "Get-AppxPackage -AllUsers Microsoft.Windows.Search | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register \"$($_.InstallLocation)\AppXManifest.xml\"}"

::-----------------------------
:: log out
::-----------------------------

shutdown /l
