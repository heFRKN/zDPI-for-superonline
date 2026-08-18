@echo off
setlocal enabledelayedexpansion
title zDPI - Hizmet Kurulumu
cd /d "%~dp0..\core"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Yonetici olarak calistirin!
    pause
    exit /b 1
)

echo [*] Onceki surecler temizleniyor...
taskkill /f /im winws.exe >nul 2>&1
taskkill /f /im goodbyedpi.exe >nul 2>&1
taskkill /f /im ciadpi.exe >nul 2>&1
sc stop zDPI_Service >nul 2>&1
sc delete zDPI_Service >nul 2>&1
sc stop FailureStudioDPI >nul 2>&1
sc delete FailureStudioDPI >nul 2>&1
sc stop ZapretSuperonline >nul 2>&1
sc delete ZapretSuperonline >nul 2>&1

echo [*] Ag ayarlari optimize ediliyor...
powershell -Command "Disable-NetAdapterBinding -Name 'Ethernet' -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue; Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddresses ('1.1.1.1','1.0.0.1') -ErrorAction SilentlyContinue" >nul 2>&1
ipconfig /flushdns >nul 2>&1

set "EXE_PATH=%~dp0..\core\winws.exe"
set ARGS=--wf-tcp=80,443 --wf-udp=443,50000-65535 --filter-udp=443,50000-65535 --dpi-desync=fake --dpi-desync-repeats=6 --new --filter-tcp=80,443 --dpi-desync=fake,split2 --dpi-desync-split-pos=1 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-repeats=6

echo [*] zDPI Hizmeti kuruluyor...
sc create "zDPI_Service" binPath= "\"%EXE_PATH%\" %ARGS%" DisplayName= "zDPI Network Service" start= auto >nul 2>&1
sc description "zDPI_Service" "zDPI High-Performance Bypass Engine by FRKN - 0ms Latency" >nul 2>&1
sc start "zDPI_Service" >nul 2>&1

taskkill /f /im Discord.exe >nul 2>&1

if "%~1"=="/silent" exit /b 0
if "%~1"=="-silent" exit /b 0

echo.
echo =======================================================================
echo                   KURULUM BASARIYLA TAMAMLANDI!
echo =======================================================================
echo.
pause
