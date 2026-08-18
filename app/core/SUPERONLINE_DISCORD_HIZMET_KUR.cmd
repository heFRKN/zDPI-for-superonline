@echo off
setlocal
cd /d "%~dp0"

echo =======================================================
echo   SUPERONLINE DISCORD OTOMATIK HIZMET KURULUMU (0ms Ping)
echo =======================================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [HATA] Lutfen bu dosyaya Sag Tik yapip "Yonetici Olarak Calistir" secin!
    echo.
    pause
    exit /b 1
)

echo [1/4] Eski calisan servisler ve programlar kapatiliyor...
sc stop GoodbyeDPI >nul 2>&1
sc delete GoodbyeDPI >nul 2>&1
sc stop zapret >nul 2>&1
sc delete zapret >nul 2>&1
sc stop ZapretSuperonline >nul 2>&1
sc delete ZapretSuperonline >nul 2>&1
taskkill /f /im goodbyedpi.exe >nul 2>&1
taskkill /f /im winws.exe >nul 2>&1
taskkill /f /im ciadpi.exe >nul 2>&1

echo [2/4] DNS onbellegi sifirlaniyor...
ipconfig /flushdns >nul 2>&1

set ARGS=--wf-tcp=80,443 --wf-udp=443,50000-65535 --filter-udp=443,50000-65535 --dpi-desync=fake --dpi-desync-repeats=6 --new --filter-tcp=80,443 --dpi-desync=fake,split2 --dpi-desync-split-pos=1 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-repeats=6

echo [3/4] ZapretSuperonline Hizmeti Olusturuluyor...
sc create "ZapretSuperonline" binPath= "\"%~dp0winws.exe\" %ARGS%" DisplayName= "Zapret Superonline Discord Fix" start= auto
sc description "ZapretSuperonline" "Superonline Discord ve DPI atlatma servisi - 0ms ping"

echo [4/4] Hizmet Baslatiliyor...
sc start "ZapretSuperonline"

echo.
echo =======================================================
echo KURULUM BASARIYLA TAMAMLANDI!
echo Bilgisayariniz her acildiginda otomatik ve arkada sessizce calisacaktir.
echo Artik hicbir pencere acik tutmaniza gerek yok.
echo Discord uygulamasini simdi acip kullanabilirsiniz.
echo =======================================================
echo.
pause
