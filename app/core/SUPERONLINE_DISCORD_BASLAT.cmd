@echo off
setlocal
cd /d "%~dp0"

echo =======================================================
echo   SUPERONLINE DISCORD VE DPI DUZELTICI (PINGSIZ 0ms)
echo =======================================================
echo.

:: Yonetici kontrolu
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [UYARI] Yonetici olarak calistirilmalidir!
    echo Lutfen bu dosyaya Sag Tik yapip "Yonetici Olarak Calistir" secin.
    echo.
    pause
    exit /b 1
)

:: Eski surecleri temizle
echo [1/3] Onceki GoodbyeDPI/Zapret surecleri sonlandiriliyor...
taskkill /f /im goodbyedpi.exe >nul 2>&1
taskkill /f /im winws.exe >nul 2>&1
taskkill /f /im ciadpi.exe >nul 2>&1
sc stop GoodbyeDPI >nul 2>&1
sc stop zapret >nul 2>&1
sc stop ZapretSuperonline >nul 2>&1

echo [2/3] DNS onbellegi temizleniyor...
ipconfig /flushdns >nul 2>&1

echo [3/3] Zapret Superonline Modu Baslatiliyor...
echo.
echo Bu pencere acik kaldigi surece Discord kesintisiz calisacaktir.
echo (Kapatmak istediginizde bu pencereyi kapatabilirsiniz.)
echo.

winws.exe --wf-tcp=80,443 --wf-udp=443,50000-65535 ^
--filter-udp=443,50000-65535 --dpi-desync=fake --dpi-desync-repeats=6 --new ^
--filter-tcp=80,443 --dpi-desync=fake,split2 --dpi-desync-split-pos=1 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-repeats=6

pause
