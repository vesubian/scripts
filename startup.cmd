@echo off
cls

IF NOT DEFINED ismin set ismin=1 & cmd /c start "" /min "%~f0" %* && exit

Title Startup

:: Local DNS
cmd /c ldns

:: Day of the week conditioned Slack launch
for /f "tokens=1 skip=1 delims='\n'" %%i in ('wmic path win32_localtime get dayofweek') do @for /f "delims='\n'" %%x in ("%%i") do set day=%%x

for /f "tokens=1 delims=:" %%i in ('time /t') do (
  set hour=%%i
)

IF %hour:~0,1% EQU 0 set hour=%hour:~1%

IF %day% LEQ 2 (
  IF %day% GTR 0 (
    IF %hour% GTR 6 (
      IF %hour% LEQ 20 (
        call :slack
      )
    )
  )
) else (
  tskill slack
)

exit

:slack
tasklist /fi "imagename eq slack.exe" | ^
findstr slack || ^
cmd /c "start "" "C:\Users\admin\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Slack Technologies Inc\Slack.lnk""

exit
