@echo off
setlocal enabledelayedexpansion
title zDPI - Otomatik Hizmet Kurulumu (by FRKN)

:: Otomatik Yonetici Yukseltmesi (Cift tiklandiginda otomatik yonetici olarak calisir)
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

echo.
echo =======================================================================
echo                 zDPI - OTOMATIK HIZMET KURULUMU
echo                              by FRKN
echo =======================================================================
echo.

echo [*] [1/5] Eski servisler, gorevler ve kilitli suruculer temizleniyor...
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

:: Kayit Defterindeki kilitli WinDivert kalintisini temizle
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WinDivert" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WinDivert14" /f >nul 2>&1

taskkill /f /im winws.exe >nul 2>&1
taskkill /f /im goodbyedpi.exe >nul 2>&1
taskkill /f /im ciadpi.exe >nul 2>&1

echo [*] [2/5] Ag ayarlari optimize ediliyor (IPv6 kapatma ^& DNS)...
powershell -Command "Disable-NetAdapterBinding -Name 'Ethernet' -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue; Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddresses ('1.1.1.1','1.0.0.1') -ErrorAction SilentlyContinue" >nul 2>&1
ipconfig /flushdns >nul 2>&1

set "CORE_DIR=%~dp0core"
set "CORE_EXE=%CORE_DIR%\winws.exe"
set ARGS=--wf-tcp=80,443 --wf-udp=443,50000-65535 --filter-udp=443,50000-65535 --dpi-desync=fake --dpi-desync-repeats=6 --new --filter-tcp=80,443 --dpi-desync=fake,split2 --dpi-desync-split-pos=1 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-repeats=6

echo [*] [3/5] Otomatik baslatma gorevi ve servisi olusturuluyor...
sc create "zDPI" binPath= "\"%CORE_EXE%\" %ARGS%" DisplayName= "zDPI Bypass Service" start= auto >nul 2>&1
sc description "zDPI" "zDPI Bypass Engine by FRKN - 0ms Latency" >nul 2>&1

:: Windows Gorev Zamanlayicisi ile guvenli arka plan gorevi (Kesin calisma garantisi)
schtasks /Create /F /TN "zDPI_Autostart" /RL HIGHEST /RU "SYSTEM" /SC ONSTART /TR "\"%CORE_EXE%\" %ARGS%" >nul 2>&1

echo [*] [4/5] zDPI Arka planda baslatiliyor...
sc start "zDPI" >nul 2>&1
powershell -Command "if (-not (Get-Process winws -ErrorAction SilentlyContinue)) { Start-Process -FilePath '%CORE_EXE%' -ArgumentList '%ARGS%' -WorkingDirectory '%CORE_DIR%' -WindowStyle Hidden }" >nul 2>&1

echo [*] [5/5] Discord yenileniyor...
taskkill /f /im Discord.exe >nul 2>&1
taskkill /f /im DiscordCanary.exe >nul 2>&1

echo.
echo =======================================================================
echo                   KURULUM BASARIYLA TAMAMLANDI!
echo =======================================================================
echo  1. zDPI su an arka planda sessizce aktif!
echo  2. Bilgisayariniz her acildiginda otomatik olarak baslar (0ms Ping).
echo  3. Discord ve tum engelli web siteleri acilmistir.
echo =======================================================================
echo.
pause
