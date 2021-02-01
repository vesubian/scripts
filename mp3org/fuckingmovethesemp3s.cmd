echo off
cls
cd /d C:\Users\Admin\Desktop\n

for /f "tokens=* usebackq delims=" %%i in (`type "C:\Users\Admin\Desktop\dirtorm.txt"`) do (pushd "%%i" && move /y *.mp3 .. && popd && rmdir "%%i")
for /f "tokens=* usebackq delims=" %%i in (`type "C:\Users\Admin\Desktop\dirtorm.txt"`) do (pushd "%%i" && move /y *.wma .. && popd && rmdir "%%i")
for /f "tokens=* usebackq delims=" %%i in (`type "C:\Users\Admin\Desktop\dirtorm.txt"`) do (pushd "%%i" && move /y *.flac .. && popd && rmdir "%%i")
for /f "tokens=* usebackq delims=" %%i in (`type "C:\Users\Admin\Desktop\dirtorm.txt"`) do (pushd "%%i" && move /y *.wav .. && popd && rmdir "%%i")
for /f "tokens=* usebackq delims=" %%i in (`type "C:\Users\Admin\Desktop\dirtorm.txt"`) do (pushd "%%i" && move /y *.jpg .. && popd && rmdir "%%i")
for /f "tokens=* usebackq delims=" %%i in (`type "C:\Users\Admin\Desktop\dirtorm.txt"`) do (pushd "%%i" && move /y *.png .. && popd && rmdir "%%i")
for /f "tokens=* usebackq delims=" %%i in (`type "C:\Users\Admin\Desktop\dirtorm.txt"`) do (pushd "%%i" && move /y *.ogg .. && popd && rmdir "%%i")
pause
:eof
exit