@echo off
title ATHARVA OS — Windows Executive Terminal Launcher
echo ====================================================
echo   Starting ATHARVA OS Desktop Platform...
echo ====================================================
echo.
echo Launching local server on port 8080...
start "" /b python -m http.server 8080 --directory desktop_app
timeout /t 2 /nobreak >nul
start http://localhost:8080
echo.
echo ATHARVA OS is now running at http://localhost:8080
echo Keep this window open while using the app.
echo.
pause
