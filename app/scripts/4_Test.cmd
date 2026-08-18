@echo off
title zDPI - Test
cd /d "%~dp0"

echo.
echo  =======================================================
echo                      zDPI - TEST
echo  =======================================================
echo.

echo  [1/3] discord.com (Web)...
curl.exe -I --connect-timeout 4 https://discord.com >nul 2>&1
if %errorlevel% equ 0 (
    echo       [+] BASARILI: discord.com erisilebilir!
) else (
    echo       [-] BASARISIZ: discord.com erisilemedi.
)

echo.
echo  [2/3] gateway.discord.gg (Ses)...
curl.exe -I --connect-timeout 4 https://gateway.discord.gg >nul 2>&1
if %errorlevel% equ 0 (
    echo       [+] BASARILI: gateway.discord.gg erisilebilir!
) else (
    echo       [-] BASARISIZ: gateway.discord.gg erisilemedi.
)

echo.
echo  [3/3] cdn.discordapp.com (Medya)...
curl.exe -I --connect-timeout 4 https://cdn.discordapp.com >nul 2>&1
if %errorlevel% equ 0 (
    echo       [+] BASARILI: cdn.discordapp.com erisilebilir!
) else (
    echo       [-] BASARISIZ: cdn.discordapp.com erisilemedi.
)

echo.
echo  =======================================================
pause
