if not DEFINED IS_MINIMIZED set IS_MINIMIZED=1 && start "" /min "%~dpnx0" %* && exit
@echo off
cls
Title PIA launch
pushd C:\scripts\pia
if "%1" == "k" (cmd /c pia_kill.cmd ^& exit) else (cmd /c pia_launch.cmd ^& exit)
exit