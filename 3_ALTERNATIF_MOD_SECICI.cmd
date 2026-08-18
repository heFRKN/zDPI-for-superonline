@echo off
setlocal enabledelayedexpansion
title zDPI - Alternatif Mod Secici (by FRKN)

:: Otomatik Yonetici Yukseltmesi (Cift tiklandiginda otomatik yonetici olarak acar)
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

:MENU
cls
echo.
echo =======================================================================
echo                 zDPI - SUPERONLINE ALTERNATIF MOD SECICI
echo                                 by FRKN
echo =======================================================================
echo.
echo  Farkli sehirlerde veya Superonline altyapilarinda (Fiber/VDSL) farkli
echo  DPI kurallari bulunabilir. Standart mod calismazsa asagidaki modlari
echo  sirayla deneyebilirsiniz:
echo.
echo  [1] Mod 1 (Standart - Onerilen Superonline Fake+Split2 Profili)
echo  [2] Mod 2 (TTL 3 - Klasik Superonline Profili)
echo  [3] Mod 3 (Agresif Multi-Disorder - Agir DPI Korumalari Icin)
echo  [4] Mod 4 (TTL 4 - Turkcell Fiber / VDSL Profili)
echo  [5] Mod 5 (Discord Ses & Medya STUN Filtre Odakli Profil)
echo  [6] Mod 6 (Hafif Fake Desync Profili)
echo.
echo -----------------------------------------------------------------------
echo  [T] Hizmetleri Temizle / Kaldir
echo  [B] Baglanti Testi Yap
echo  [Q] Cikis
echo =======================================================================
echo.
set /p MOD_CHOICE="Lutfen bir mod secin (1-6, T, B, Q): "

if /i "%MOD_CHOICE%"=="Q" exit /b 0
if /i "%MOD_CHOICE%"=="T" (
    call "4_HIZMETI_KALDIR_TEMIZLE.cmd"
    goto MENU
)
if /i "%MOD_CHOICE%"=="B" (
    call "5_BAGLANTI_TESTI.cmd"
    goto MENU
)

if "%MOD_CHOICE%"=="1" (
    set "MOD_NAME=Mod 1 (Standart Fake+Split2)"
    set ARGS=--wf-tcp=80,443 --wf-udp=443,50000-65535 --filter-udp=443,50000-65535 --dpi-desync=fake --dpi-desync-repeats=6 --new --filter-tcp=80,443 --dpi-desync=fake,split2 --dpi-desync-split-pos=1 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-repeats=6
    goto SUBMENU
)
if "%MOD_CHOICE%"=="2" (
    set "MOD_NAME=Mod 2 (TTL 3 Superonline)"
    set ARGS=--wf-tcp=80,443 --wf-udp=443,50000-65535 --filter-udp=443,50000-65535 --dpi-desync=fake --dpi-desync-fooling=md5sig --dpi-desync-ttl=3 --new --filter-tcp=80,443 --dpi-desync=fake --dpi-desync-fooling=md5sig --dpi-desync-ttl=3
    goto SUBMENU
)
if "%MOD_CHOICE%"=="3" (
    set "MOD_NAME=Mod 3 (Agresif Multi-Disorder)"
    set ARGS=--wf-tcp=80,443 --wf-udp=443,50000-65535 --filter-udp=443,50000-65535 --dpi-desync=fake --dpi-desync-repeats=11 --new --filter-tcp=80,443 --dpi-desync=fake,multidisorder --dpi-desync-split-pos=midsld --dpi-desync-repeats=6 --dpi-desync-fooling=badseq,md5sig
    goto SUBMENU
)
if "%MOD_CHOICE%"=="4" (
    set "MOD_NAME=Mod 4 (TTL 4 Turkcell)"
    set ARGS=--wf-tcp=80,443 --wf-udp=443,50000-65535 --filter-udp=443,50000-65535 --dpi-desync=fake --dpi-desync-ttl=4 --new --filter-tcp=80,443 --dpi-desync=fake,split2 --dpi-desync-split-pos=2 --dpi-desync-ttl=4 --dpi-desync-fooling=badseq
    goto SUBMENU
)
if "%MOD_CHOICE%"=="5" (
    set "MOD_NAME=Mod 5 (Discord Ses STUN)"
    set ARGS=--wf-raw="@%~dp0core\windivert.filter\windivert.discord_media+stun.txt" --filter-l7=discord,stun --dpi-desync=fake --new --wf-tcp=80,443 --dpi-desync=fake,split2 --dpi-desync-split-pos=1 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig
    goto SUBMENU
)
if "%MOD_CHOICE%"=="6" (
    set "MOD_NAME=Mod 6 (Hafif Fake)"
    set ARGS=--wf-tcp=80,443 --wf-udp=443,50000-65535 --filter-udp=443,50000-65535 --dpi-desync=fake --new --filter-tcp=80,443 --dpi-desync=fake --dpi-desync-fooling=md5sig
    goto SUBMENU
)

echo [!] Gecersiz secim!
timeout /t 2 >nul
goto MENU

:SUBMENU
cls
echo.
echo =======================================================================
echo  Secilen Mod: !MOD_NAME!
echo =======================================================================
echo.
echo  Bu modu nasil calistirmak istersiniz?
echo.
echo  [1] Hizmet Olarak Kur (Windows baslangicinda otomatik ve arkada calisir)
echo  [2] Tek Seferlik Baslat (Gecici pencere modunda test et)
echo  [3] Ana Menuye Don
echo.
set /p ACTION_CHOICE="Seciminiz (1-3): "

if "%ACTION_CHOICE%"=="3" goto MENU

if "%ACTION_CHOICE%"=="1" (
    echo.
    echo [*] Onceki servisler ve gorevler temizleniyor...
    sc stop zDPI >nul 2>&1
    sc delete zDPI >nul 2>&1
    sc stop WinDivert >nul 2>&1
    sc delete WinDivert >nul 2>&1
    schtasks /Delete /TN "zDPI_Autostart" /F >nul 2>&1
    reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WinDivert" /f >nul 2>&1
    taskkill /f /im winws.exe >nul 2>&1

    powershell -Command "Disable-NetAdapterBinding -Name 'Ethernet' -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue; Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddresses ('1.1.1.1','1.0.0.1') -ErrorAction SilentlyContinue" >nul 2>&1
    ipconfig /flushdns >nul 2>&1

    echo [*] zDPI Hizmeti kuruluyor (!MOD_NAME!)...
    set "CORE_DIR=%~dp0core"
    set "CORE_EXE=%CORE_DIR%\winws.exe"
    sc create "zDPI" binPath= "\"%CORE_EXE%\" !ARGS!" DisplayName= "zDPI Bypass Service" start= auto >nul 2>&1
    sc description "zDPI" "zDPI Engine by FRKN (!MOD_NAME!)" >nul 2>&1
    schtasks /Create /F /TN "zDPI_Autostart" /RL HIGHEST /RU "SYSTEM" /SC ONSTART /TR "\"%CORE_EXE%\" !ARGS!" >nul 2>&1
    sc start "zDPI" >nul 2>&1
    powershell -Command "if (-not (Get-Process winws -ErrorAction SilentlyContinue)) { Start-Process -FilePath '%CORE_EXE%' -ArgumentList '!ARGS!' -WorkingDirectory '%CORE_DIR%' -WindowStyle Hidden }" >nul 2>&1

    echo [*] Discord yenileniyor...
    taskkill /f /im Discord.exe >nul 2>&1

    echo.
    echo =======================================================================
    echo !MOD_NAME! BASARIYLA KURULDU VE BASLATILDI!
    echo =======================================================================
    pause
    goto MENU
)

if "%ACTION_CHOICE%"=="2" (
    echo.
    echo [*] Onceki servisler durduruluyor...
    sc stop zDPI >nul 2>&1
    sc stop WinDivert >nul 2>&1
    sc delete WinDivert >nul 2>&1
    reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WinDivert" /f >nul 2>&1
    taskkill /f /im winws.exe >nul 2>&1

    powershell -Command "Disable-NetAdapterBinding -Name 'Ethernet' -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue; Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddresses ('1.1.1.1','1.0.0.1') -ErrorAction SilentlyContinue" >nul 2>&1
    ipconfig /flushdns >nul 2>&1

    cd /d "%~dp0core"
    echo.
    echo -----------------------------------------------------------------------
    echo  [+] zDPI Tek Seferlik Mod Aktif (!MOD_NAME!)
    echo  [+] Bu pencere ACIK KALDIGI SURECE Discord ve tum siteler aciktir.
    echo  [+] Kapatmak icin pencereyi kapatin veya Ctrl+C yapin.
    echo -----------------------------------------------------------------------
    echo.
    winws.exe !ARGS!
    echo [*] Mod sonlandirildi.
    pause
    cd /d "%~dp0"
    goto MENU
)

goto SUBMENU
