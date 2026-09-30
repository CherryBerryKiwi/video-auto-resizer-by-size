@echo off
setlocal EnableDelayedExpansion

if "%~1"=="" (
    echo Keo tha video vao file BAT nay.
    pause
    exit /b
)

set "input=%~1"
set "folder=%~dp1"
set "name=%~n1"

set /p target="Nhap dung luong mong muon (MB): "

echo.
echo Dang lay thoi luong video...

for /f "delims=" %%a in ('ffprobe -v error -show_entries format^=duration -of default^=noprint_wrappers^=1:nokey^=1 "%input%"') do set duration=%%a

if "%duration%"=="" (
    echo Khong doc duoc thoi luong video.
    pause
    exit /b
)

rem Tinh bitrate:
rem MB * 8192 / giay - audio 128kbps
for /f "tokens=1 delims=." %%a in ("!duration!") do set seconds=%%a

set /a total_kbps=(target*8192)/seconds
set /a video_kbps=total_kbps-128

if !video_kbps! LSS 100 (
    set video_kbps=100
)

echo.
echo Thoi luong: !seconds! giay
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
echo Hoan tat:
echo %folder%%name%_output.mp4

pause