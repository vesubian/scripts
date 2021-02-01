if not DEFINED IS_MINIMIZED set IS_MINIMIZED=1 && start "" /min "%~dpnx0" %* && exit
@echo off
cls
cmd /c "C:\scripts\pia\piarightstart.cmd"  >nul 2>&1
@timeout /nobreak /t 8   >nul 2>&1
start "" /b "C:\Program Files\Private Internet Access\pia-service.exe"  >nul 2>&1
start "" /b "C:\Program Files\Private Internet Access\pia-client.exe"  >nul 2>&1
exit