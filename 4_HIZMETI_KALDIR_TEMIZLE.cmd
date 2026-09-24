@echo off
title zDPI - Temizle (by FRKN)

:: Otomatik Yonetici Yukseltmesi (Cift tiklandiginda otomatik yonetici olarak calisir)
net session >nul 2>&1
if %errorlevel% neq 0 (
    rem Yol ortam degiskeniyle aktarilir; klasor adinda ' veya bosluk olsa da guvenli calisir
    set "ZDPI_SELF=%~f0"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:ZDPI_SELF -Verb RunAs"
    exit /b
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0core\zdpi.ps1" -Action uninstall
pause
