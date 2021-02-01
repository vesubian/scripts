@echo off
cls
if not DEFINED IS_MINIMIZED set IS_MINIMIZED=1 && start "" /min "%~dpnx0" %* && exit
cls
:: Naming the shell

title localdns

:: Elevating script to admin permissions

::-------------------------------------
::REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

::REM --> If error flag set, we do not have admin.
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
    exit

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
::--------------------------------------

:: IPv6 off

powershell "Disable-NetAdapterBinding -Name "WiFi" -ComponentID ms_tcpip6" 1>nul 2>&1
powershell "Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_tcpip6" 1>nul 2>&1

:: test method - 23.06.19

netsh interface ipv4 delete dnsservers "WiFi" all 1>nul 2>&1
netsh interface ipv4 add dnsserver "WiFi" address=127.0.0.1 index=1 1>nul 2>&1
netsh interface ipv4 delete dnsservers "Ethernet" all 1>nul 2>&1
netsh interface ipv4 add dnsserver "Ethernet" address=127.0.0.1 index=1 1>nul 2>&1


:: Reset DNS

:: netsh interface ipv4 delete dnsservers "WiFi" all 2>nul 1>nul
:: netsh interface ipv4 delete dnsservers "Ethernet" all 2>nul 1>nul

:: Set local DNS

:: netsh interface ipv4 add dnsserver "WiFi" address=127.0.0.1 index=1 2>nul
:: netsh interface ipv4 add dnsserver "Ethernet" address=127.0.0.1 index=1 2>nul

exit
