@echo off
setlocal
cd /d "%~dp0"

echo =======================================================
echo   SUPERONLINE DISCORD HIZMETINI KALDIR
echo =======================================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [HATA] Lutfen bu dosyaya Sag Tik yapip "Yonetici Olarak Calistir" secin!
    echo.
    pause
    exit /b 1
)

echo Zapret servisi durduruluyor ve siliniyor...
sc stop "ZapretSuperonline" >nul 2>&1
sc delete "ZapretSuperonline" >nul 2>&1
sc stop "zapret" >nul 2>&1
sc delete "zapret" >nul 2>&1
taskkill /f /im winws.exe >nul 2>&1

echo Islem basariyla tamamlandi.
pause
