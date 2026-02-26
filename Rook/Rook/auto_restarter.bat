@echo off
setlocal
cd /d "%~dp0"
color 0A

:begin
echo.
echo [START] %date% %time%
theforgottenserver-x64.exe
set "EXIT_CODE=%ERRORLEVEL%"
echo.
echo [STOP] Server exited with code %EXIT_CODE% at %date% %time%
echo [INFO] Press any key to restart. Close this window to stop.
pause >nul
goto begin
