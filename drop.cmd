@echo off
cls

:: minimize window
if not defined is_min set is_min=1 && start "" /min "%~f0 " %* && exit

::-------------------------------------

title drop

::-------------------------------------
if "%1" EQU "k" (call :kill %*) else (call :start)

exit

:kill
:: elevation
::-------------------------------------
:: --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

:: --> If error flag set, we do not have admin.
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

:: set service start to manual
sc config "DbxSvc" start= demand

:: stop service
net stop "DbxSvc"

:: quit Dropbox
cmd /c "taskkill /f /im dropbox.exe"

cmd /c "taskkill /f /im DropboxUpdate.exe"

exit
::--------------------------------------


::--------------------------------------
:start

::--------------------------------------
:: Dropbox Offline KDBX Back up
::--------------------------------------

:: back up Dropbox file to Dropbox kdbx baks folder if changed
cmd /c "xcopy "D:\Arbitrage\Dropbox\Georges\crypto\admin.kdbx" "D:\Arbitrage\Dropbox\Georges\crypto\kdbx baks" /d /f /k /o /y"

:: back up back up file if it was updated
cmd /c "xcopy "D:\Encryption\admin.kdbx" "D:\Encryption\baks\admin.kdbx" /d /f /k /o /y"

:: back up file if it was updated
cmd /c "xcopy "D:\Arbitrage\Dropbox\Georges\crypto\admin.kdbx" "D:\Encryption\admin.kdbx" /d /f /k /o /y"
::--------------------------------------

::--------------------------------------
:: Local Tableau dashboards' updates offline back up to Dropbox
::--------------------------------------

:: back up old Dropbox dashboards to Dropbox baks
cmd /c "xcopy "D:\Arbitrage\Dropbox\Georges\Tableau\*.twbx" "D:\Arbitrage\Dropbox\Georges\Tableau\old\" /d /f /k /o /y"

:: back up local changes to Dropbox
cmd /c "xcopy "D:\Tableau Dash\*.twbx" "D:\Arbitrage\Dropbox\Georges\Tableau\" /d /f /k /o /y"

::--------------------------------------
:: Launch Dropbox & Sync
::--------------------------------------

:: stop service
net start "DbxSvc"

:: launch Dropbox
cmd /c "start "" /min "C:\Program Files (x86)\Dropbox\Client\Dropbox.exe""

exit
::--------------------------------------
