@echo off
setlocal enabledelayedexpansion
title zDPI - Tek Seferlik Mod (Discord ve Yasakli Siteler) by FRKN

:: Otomatik Yonetici Yukseltmesi (Cift tiklandiginda otomatik yonetici olarak calisir)
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo =======================================================================
echo          zDPI - TEK SEFERLIK MOD (DISCORD VE YASAKLI SITELER)
echo                              by FRKN
echo =======================================================================
echo.

echo [*] [1/3] Onceki servisler ve kilitli suruculer temizleniyor...
sc stop zDPI >nul 2>&1
sc stop zDPI_Service >nul 2>&1
sc stop FailureStudioDPI >nul 2>&1
sc stop ZapretSuperonline >nul 2>&1
sc stop zapret >nul 2>&1
sc stop GoodbyeDPI >nul 2>&1
sc stop WinDivert >nul 2>&1
sc delete WinDivert >nul 2>&1
sc stop WinDivert14 >nul 2>&1
sc delete WinDivert14 >nul 2>&1

:: Kayit Defterindeki kilitli WinDivert kalintisini temizle
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WinDivert" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WinDivert14" /f >nul 2>&1

taskkill /f /im winws.exe >nul 2>&1
taskkill /f /im goodbyedpi.exe >nul 2>&1
taskkill /f /im ciadpi.exe >nul 2>&1

echo [*] [2/3] Ag ayarlari optimize ediliyor (IPv6 kapatma ^& DNS)...
powershell -Command "Disable-NetAdapterBinding -Name 'Ethernet' -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue; Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddresses ('1.1.1.1','1.0.0.1') -ErrorAction SilentlyContinue" >nul 2>&1
ipconfig /flushdns >nul 2>&1

cd /d "%~dp0core"

echo [*] [3/3] zDPI Motoru Baslatiliyor...
echo.
echo =======================================================================
echo  [+] zDPI TEK SEFERLIK MOD AKTIF! (0ms Ping)
echo.
echo  [+] Bu pencere ACIK KALDIGI SURECE:
echo      - Discord uygulamasi ve tum ses kanallari aciktir.
echo      - Turkiye'de engelli olan tum web siteleri aciktir.
echo.
echo  [!] Kapatmak istediginizde bu pencereyi kapatin veya Ctrl+C yapin.
echo =======================================================================
echo.

winws.exe --wf-tcp=80,443 --wf-udp=443,50000-65535 ^
--filter-udp=443,50000-65535 --dpi-desync=fake --dpi-desync-repeats=6 --new ^
--filter-tcp=80,443 --dpi-desync=fake,split2 --dpi-desync-split-pos=1 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-repeats=6

echo.
echo [*] zDPI durduruldu ve baglanti normale donduruldu.
pause
