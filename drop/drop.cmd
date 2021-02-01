@echo off
cls
if not defined is_min set is_min=1 & cmd /c start "" /min "%~f0" %* && exit

Title Drop

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

if "%1"=="k" (call :kill && exit)

sc config DbxSvc start= demand

cmd /c net start DbxSvc

cmd /c "start "" /min "C:\Program Files (x86)\Dropbox\Client\Dropbox.exe" "
exit

::--------------------------------

:kill

taskkill /f /im dropbox.exe
cmd /c net stop DbxSvc

exit
