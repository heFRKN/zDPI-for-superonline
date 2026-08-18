@echo off
setlocal
cd /d "%~dp0"

echo =======================================================
echo   SUPERONLINE DISCORD SES VE MEDYA ALTERNATIF MOD (0ms Ping)
echo =======================================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [UYARI] Yonetici olarak calistirilmalidir!
    echo Lutfen bu dosyaya Sag Tik yapip "Yonetici Olarak Calistir" secin.
    echo.
    pause
    exit /b 1
)

echo [1/2] Onceki surecler temizleniyor...
taskkill /f /im goodbyedpi.exe >nul 2>&1
taskkill /f /im winws.exe >nul 2>&1
sc stop ZapretSuperonline >nul 2>&1

echo [2/2] Zapret STUN + Discord Media Modu Baslatiliyor...
echo.

winws.exe --wf-raw=@"%~dp0windivert.filter\windivert.discord_media+stun.txt" --filter-l7=discord,stun --dpi-desync=fake

pause
