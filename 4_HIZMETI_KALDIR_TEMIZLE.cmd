@echo off
setlocal enabledelayedexpansion
title zDPI - Temizle (by FRKN)

:: Otomatik Yonetici Yukseltmesi (Cift tiklandiginda otomatik yonetici olarak calisir)
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

echo.
echo =======================================================================
echo                      zDPI - SISTEM TEMIZLEYICI
echo                              by FRKN
echo =======================================================================
echo.

echo [*] Servisler ve baslangic gorevleri kaldiriliyor...
sc stop zDPI >nul 2>&1
sc delete zDPI >nul 2>&1
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
sc stop WinDivert >nul 2>&1
sc delete WinDivert >nul 2>&1
sc stop WinDivert14 >nul 2>&1
sc delete WinDivert14 >nul 2>&1

schtasks /Delete /TN "zDPI" /F >nul 2>&1
schtasks /Delete /TN "zDPI_Autostart" /F >nul 2>&1

reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WinDivert" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WinDivert14" /f >nul 2>&1

echo [*] Surecler sonlandiriliyor...
taskkill /f /im winws.exe >nul 2>&1
taskkill /f /im goodbyedpi.exe >nul 2>&1
taskkill /f /im ciadpi.exe >nul 2>&1
taskkill /f /im ProxiFyre.exe >nul 2>&1
taskkill /f /im wiresock.exe >nul 2>&1

ipconfig /flushdns >nul 2>&1

echo.
echo =======================================================================
echo               TUM SISTEMLER BASARIYLA TEMIZLENDI!
echo =======================================================================
echo.
pause
