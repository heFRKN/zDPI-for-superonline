@echo off
setlocal enabledelayedexpansion
title zDPI - Hizmet Kur (Mod 1 (Standart Fake+Split2))

net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0.."

echo [*] Onceki servisler temizleniyor...
sc stop zDPI >nul 2>&1
sc delete zDPI >nul 2>&1
sc stop WinDivert >nul 2>&1
sc delete WinDivert >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WinDivert" /f >nul 2>&1
taskkill /f /im winws.exe >nul 2>&1

powershell -Command "Disable-NetAdapterBinding -Name 'Ethernet' -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue; Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddresses ('1.1.1.1','1.0.0.1') -ErrorAction SilentlyContinue" >nul 2>&1
ipconfig /flushdns >nul 2>&1

set "CORE_EXE=%~dp0..\core\winws.exe"
set ARGS=--wf-tcp=80,443 --wf-udp=443,50000-65535 --filter-udp=443,50000-65535 --dpi-desync=fake --dpi-desync-repeats=6 --new --filter-tcp=80,443 --dpi-desync=fake,split2 --dpi-desync-split-pos=1 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-repeats=6

echo [*] zDPI Hizmeti kuruluyor (Mod 1 (Standart Fake+Split2))...
sc create "zDPI" binPath= ""%CORE_EXE%" %ARGS%" DisplayName= "zDPI Bypass Service" start= auto >nul 2>&1
sc description "zDPI" "zDPI Engine by FRKN (Mod 1 (Standart Fake+Split2))" >nul 2>&1
sc start "zDPI" >nul 2>&1

taskkill /f /im Discord.exe >nul 2>&1

echo.
echo =======================================================================
echo Mod 1 (Standart Fake+Split2) HIZMET OLARAK BASARIYLA KURULDU!
echo =======================================================================
pause
