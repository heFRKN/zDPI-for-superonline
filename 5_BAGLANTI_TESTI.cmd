@echo off
title zDPI - Baglanti Testi (by FRKN)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0core\zdpi.ps1" -Action test
pause
