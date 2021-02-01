title "bypass vpn netflix"
@echo off && cls

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
    echo UAC.ShellExecute "cmd.exe", "/c start /min cmd /c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

:--------------------------------------

:updatelist
for /f "tokens=* useback delims=" %%i in (C:\Users\Admin\Documents\netflxips.txt) do (route add %%i mask 255.255.255.255 192.168.2.1)


@timeout /nobreak /t 10

goto :updatelist