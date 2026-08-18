@echo off
setlocal enabledelayedexpansion
title zDPI - Tek Seferlik Mod (by FRKN)

echo.
echo =======================================================================
echo                 zDPI - TEK SEFERLIK MOD (0ms Ping)
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

echo [*] Onceki servisler durduruluyor...
sc stop zDPI >nul 2>&1
sc stop zDPI_Service >nul 2>&1
sc stop FailureStudioDPI >nul 2>&1
sc stop ZapretSuperonline >nul 2>&1
taskkill /f /im winws.exe >nul 2>&1
taskkill /f /im goodbyedpi.exe >nul 2>&1
taskkill /f /im ciadpi.exe >nul 2>&1

powershell -Command "Disable-NetAdapterBinding -Name 'Ethernet' -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue; Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddresses ('1.1.1.1','1.0.0.1') -ErrorAction SilentlyContinue" >nul 2>&1
ipconfig /flushdns >nul 2>&1

cd /d "%~dp0core"

echo.
echo -----------------------------------------------------------------------
echo  [+] zDPI Tek Seferlik Mod Aktif!
echo  [+] Bu pencere ACIK KALDIGI SURECE Discord ve tum siteler aciktir.
echo  [+] Kapatmak istediginizde bu pencereyi kapatin veya Ctrl+C yapin.
echo -----------------------------------------------------------------------
echo.

winws.exe --wf-tcp=80,443 --wf-udp=443,50000-65535 ^
--filter-udp=443,50000-65535 --dpi-desync=fake --dpi-desync-repeats=6 --new ^
--filter-tcp=80,443 --dpi-desync=fake,split2 --dpi-desync-split-pos=1 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-repeats=6

echo.
echo [*] zDPI durduruldu.
pause
