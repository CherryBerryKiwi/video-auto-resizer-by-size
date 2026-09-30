@echo off
setlocal EnableDelayedExpansion

if "%~1"=="" (
    echo Drag and drop a video file onto this BAT file.
    pause
    exit /b
)

set "input=%~1"
set "folder=%~dp1"
set "name=%~n1"

set /p target="Enter target file size (MB): "

echo.
echo Reading video duration...

for /f "delims=" %%a in ('ffprobe -v error -show_entries format^=duration -of default^=noprint_wrappers^=1:nokey^=1 "%input%"') do set duration=%%a

if "%duration%"=="" (
    echo Cannot read video duration.
    pause
    exit /b
)

rem Calculate bitrate:
rem Total bitrate = target MB * 8192 / seconds
rem Subtract audio bitrate (128 kbps)

for /f "tokens=1 delims=." %%a in ("!duration!") do set seconds=%%a

set /a total_kbps=(target*8192)/seconds
set /a video_kbps=total_kbps-128

if !video_kbps! LSS 100 (
    set video_kbps=100
)

echo.
echo Duration: !seconds! seconds
echo Video bitrate: !video_kbps! kbps
echo.

ffmpeg -i "%input%" ^
-vf "scale=-2:720" ^
-c:v libx264 ^
-preset fast ^
-b:v !video_kbps!k ^
-maxrate !video_kbps!k ^
-bufsize !video_kbps!*2k ^
-c:a aac ^
-b:a 128k ^
"%folder%%name%_output.mp4"

echo.
echo Finished:
echo %folder%%name%_output.mp4

pause