@echo off
cls
if not defined is_min set is_min=1 & cmd /c start "" /min "%~f0 %*" & exit
Title Local DNS

::BatchGotAdmin
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
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"="%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
::--------------------------------

netsh interface teredo set state disabled >nul 2>&1

netsh interface ipv6 6to4 set state state=disabled undoonstop=disabled >nul 2>&1

netsh interface ipv6 isatap set state state=disabled >nul 2>&1


powershell "Disable-NetAdapterBinding -Name "Wi-Fi" -ComponentID ms_tcpip6" >nul 2>&1

powershell "Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_tcpip6" >nul 2>&1

powershell "Disable-NetAdapterBinding -Name "Mullvad" -ComponentID ms_tcpip6" >nul 2>&1


netsh interface ipv4 delete dnsservers "Wi-Fi" all >nul 2>&1

netsh interface ipv4 delete dnsservers "Ethernet" all >nul 2>&1

netsh interface ipv4 delete dnsservers "Mullvad" all >nul 2>&1


netsh interface ipv4 set dnsservers "Wi-Fi" static 127.0.0.1 none no >nul 2>&1

netsh interface ipv4 set dnsservers "Ethernet" static 127.0.0.1 none no  >nul 2>&1

netsh interface ipv4 set dnsservers "Mullvad" static 127.0.0.1  none no >nul 2>&1


ipconfig /flushdns >nul 2>&1

sc config unbound start= auto >nul 2>&1

cmd /c net start unbound >nul 2>&1


::--------------------------------


exit
