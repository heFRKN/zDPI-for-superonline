@echo off
setlocal enabledelayedexpansion
title zDPI - Hizmet Kurulumu (by FRKN)
cd /d "%~dp0"

echo.
echo =======================================================================
echo                       zDPI - SUPERONLINE FIX
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

echo [*] [1/4] Eski ve cakisabilecek servisler temizleniyor...
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

taskkill /f /im winws.exe >nul 2>&1
taskkill /f /im goodbyedpi.exe >nul 2>&1
taskkill /f /im ciadpi.exe >nul 2>&1
taskkill /f /im ProxiFyre.exe >nul 2>&1
taskkill /f /im wiresock.exe >nul 2>&1

echo [*] [2/4] Ag ayarlari optimize ediliyor (IPv6 kapatma ^& DNS)...
powershell -Command "Disable-NetAdapterBinding -Name 'Ethernet' -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue; Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddresses ('1.1.1.1','1.0.0.1') -ErrorAction SilentlyContinue" >nul 2>&1
ipconfig /flushdns >nul 2>&1

set "CORE_EXE=%~dp0core\winws.exe"
set ARGS=--wf-tcp=80,443 --wf-udp=443,50000-65535 --filter-udp=443,50000-65535 --dpi-desync=fake --dpi-desync-repeats=6 --new --filter-tcp=80,443 --dpi-desync=fake,split2 --dpi-desync-split-pos=1 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-repeats=6

echo [*] [3/4] zDPI Hizmeti kuruluyor...
sc create "zDPI" binPath= "\"%CORE_EXE%\" %ARGS%" DisplayName= "zDPI Bypass Service" start= auto >nul 2>&1
sc description "zDPI" "zDPI Bypass Engine by FRKN - 0ms Latency" >nul 2>&1
sc start "zDPI" >nul 2>&1

echo [*] [4/4] Discord yenileniyor...
taskkill /f /im Discord.exe >nul 2>&1
taskkill /f /im DiscordCanary.exe >nul 2>&1

echo.
echo =======================================================================
echo                   KURULUM BASARIYLA TAMAMLANDI!
echo =======================================================================
echo  1. Bilgisayariniz her acildiginda otomatik ve arkada sessizce calisir.
echo  2. Oyunlarda pinginizi kesinlikle artirmaz (0ms ek gecikme / VPN degildir).
echo  3. Discord ve yasakli sitelere erisim artik acik!
echo =======================================================================
echo.
pause
