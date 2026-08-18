@echo off
title zDPI - GitHub'a Yukle
cd /d "%~dp0"

echo =======================================================
echo          zDPI - GITHUB YUKLEME ARACI (by FRKN)
echo =======================================================
echo.
echo GitHub'a dosyalar yukleniyor...
echo (Eger tarayici acilirsa GitHub hesabinizi onaylayin)
echo.

git push -u origin main

echo.
if %errorlevel% equ 0 (
    echo =======================================================
    echo   BASARIYLA YUKLENDI! GitHub sayfanizi yenileyebilirsiniz!
    echo =======================================================
) else (
    echo [!] Hata olustu veya giris yapilmadi.
)

echo.
pause
