@echo off
setlocal enabledelayedexpansion
title zDPI - Temizle (by FRKN)
cd /d "%~dp0"

echo.
echo =======================================================================
echo                      zDPI - SISTEM TEMIZLEYICI
echo                              by FRKN
echo =======================================================================
echo.

:: Yonetici Yetkisi Kontrolu
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] HATA: Bu dosyayi Yonetici Olarak Calistir'maniz gerekmektedir!
    echo [!] Lutfen Sag Tik yapip "Yonetici Olarak Calistir" secin.
    echo.
    pause
    exit /b 1
)

echo [*] Servisler kaldiriliyor...
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
