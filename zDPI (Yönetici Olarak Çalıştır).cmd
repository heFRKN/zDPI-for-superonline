@echo off
setlocal enabledelayedexpansion
title zDPI (Yonetici Olarak Calistir)
cd /d "%~dp0"

:: Yonetici Yetkisi Kontrolu - Otomatik Yukseltme
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Python Bul
set "PY_CMD=python"
where python >nul 2>&1
if %errorlevel% neq 0 (
    if exist "C:\Users\furka\AppData\Local\Programs\Python\Python312\python.exe" (
        set "PY_CMD=C:\Users\furka\AppData\Local\Programs\Python\Python312\python.exe"
    )
)

:: Eski sunuculari temizle ve yeni zDPI sunucusunu baslat
taskkill /f /im python.exe /fi "WINDOWTITLE eq zDPI_Server*" >nul 2>&1
start /b "" "!PY_CMD!" "%~dp0app\ui\server.py" >nul 2>&1
timeout /t 1 /nobreak >nul 2>&1

:: Edge Standalone App Modunda Arayuzu Baslat
set "EDGE_PATH=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if not exist "!EDGE_PATH!" (
    set "EDGE_PATH=C:\Program Files\Microsoft\Edge\Application\msedge.exe"
)

if exist "!EDGE_PATH!" (
    start "" "!EDGE_PATH!" --app="http://127.0.0.1:49223" --window-size=440,710 --user-data-dir="%TEMP%\zDPIProfile"
) else (
    start http://127.0.0.1:49223
)

exit /b 0
