@echo off
setlocal enabledelayedexpansion
title zDPI - Tek Seferlik (Mod 5 (Discord Ses STUN))

net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo [*] Onceki servisler durduruluyor...
sc stop zDPI >nul 2>&1
sc stop WinDivert >nul 2>&1
sc delete WinDivert >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WinDivert" /f >nul 2>&1
taskkill /f /im winws.exe >nul 2>&1

powershell -Command "Disable-NetAdapterBinding -Name 'Ethernet' -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue; Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddresses ('1.1.1.1','1.0.0.1') -ErrorAction SilentlyContinue" >nul 2>&1
ipconfig /flushdns >nul 2>&1

cd /d "%~dp0..\core"

echo.
echo -----------------------------------------------------------------------
echo  [+] zDPI Tek Seferlik Mod Aktif (Mod 5 (Discord Ses STUN))
echo  [+] Bu pencere ACIK KALDIGI SURECE Discord ve tum siteler aciktir.
echo  [+] Kapatmak icin pencereyi kapatin veya Ctrl+C yapin.
echo -----------------------------------------------------------------------
echo.

winws.exe --wf-raw="@%~dp0..\core\windivert.filter\windivert.discord_media+stun.txt" --filter-l7=discord,stun --dpi-desync=fake --new --wf-tcp=80,443 --dpi-desync=fake,split2 --dpi-desync-split-pos=1 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig

echo [*] zDPI durduruldu.
pause
