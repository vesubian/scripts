echo off
cls
for /f "tokens=* usebackq delims=" %%i in (`type "D:\Musique\dirtorm.txt"`) do (pushd "%%i" && move /y *.jpg .. && popd && rmdir "%%i")

pause
:eof
exit