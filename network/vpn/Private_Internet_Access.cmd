@echo off
cls

if not defined is_min set is_min=1 && cmd /c start "" /min "%~f0" %* && exit

Title PIA VPN

if "%1"=="" (call :start && exit)
if "%1"=="k" (call :kill %* && exit)


:start

IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "C:\Windows\SysWOW64\cacls.exe" "C:\Windows\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
  cmd /c start "" "C:\Program Files\Private Internet Access\pia-client.exe" > nul 2>&1
  call :elevate
) else (
  call :start2
)

exit

:start2

cmd /c mv k

sc config "PrivateInternetAccessService" start= demand > nul 2>&1
sc config "PrivateInternetAccessWireguard" start= demand > nul 2>&1

cmd /c net start "Private Internet Access Service" > nul 2>&1
cmd /c net start "Private Internet Access WireGuard Tunnel" > nul 2>&1

ldns

exit


:kill

IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "C:\Windows\SysWOW64\cacls.exe" "C:\Windows\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (call :elevate %*) else (
  call :kill2
  )

exit

:kill2
sc config "PrivateInternetAccessService" start= demand > nul 2>&1
sc config "PrivateInternetAccessWireguard" start= demand > nul 2>&1

cmd /c net stop "Private Internet Access Service" > nul 2>&1
cmd /c net stop "Private Internet Access WireGuard Tunnel" > nul 2>&1

taskkill /f /im "pia-client.exe"

exit

:elevate

::-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "C:\Windows\SysWOW64\cacls.exe" "C:\Windows\SysWOW64\config\system"
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
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"="%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
::--------------------------------
exit
