@echo off
cls
if not defined is_min set is_min=1 && start "" /min "%~f0 " %* && exit

::troubleshooting line ::  echo if [%1]==[k] call :kill %* && if [%1]==[k] call :kill %* && pause && echo if [%1]==[] call :start && if [%1]==[] call :start && pause && exit

if [%1]==[k] call :kill %*
if [%1]==[] call :start %*
if [%1]==[elevated_iteration] call :start %*
exit
::-------------------------------------
:kill
title Mullvad kill
:: elevation
::-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
::--------------------------------------

cmd /c net stop "Mullvad VPN Service"  >nul 2>&1

taskkill /f /im "Mullvad VPN.exe"  >nul 2>&1

exit

::-------------------------------------
:start

title Mullvad Launch

call :pial %*

cmd /c "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\custom\pia.lnk" k

if "%1"=="elevated_iteration" (exit)

start "" /min "C:\Program Files\Mullvad VPN\Mullvad VPN.exe" >nul 2>&1

exit

:pial
:: elevation
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt2
) else ( goto gotAdmin2 )
:UACPrompt2
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params=elevated_iteration

    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
:gotAdmin2
:-------------------------------------
cmd /c net start "Mullvad VPN Service" >nul 2>&1

exit
