@echo off
setlocal enabledelayedexpansion
title zDPI - Temizle
cd /d "%~dp0..\core"

sc stop zDPI_Service >nul 2>&1
sc delete zDPI_Service >nul 2>&1
sc stop FailureStudioDPI >nul 2>&1
sc delete FailureStudioDPI >nul 2>&1
sc stop ZapretSuperonline >nul 2>&1
sc delete ZapretSuperonline >nul 2>&1
sc stop zapret >nul 2>&1
sc delete zapret >nul 2>&1
sc stop GoodbyeDPI >nul 2>&1
sc delete GoodbyeDPI >nul 2>&1

taskkill /f /im winws.exe >nul 2>&1
taskkill /f /im goodbyedpi.exe >nul 2>&1
taskkill /f /im ciadpi.exe >nul 2>&1
taskkill /f /im ProxiFyre.exe >nul 2>&1
taskkill /f /im wiresock.exe >nul 2>&1

ipconfig /flushdns >nul 2>&1

if "%~1"=="/silent" exit /b 0
if "%~1"=="-silent" exit /b 0

echo [*] Tum sistemler basariyla temizlendi!
pause
