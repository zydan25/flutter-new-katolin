@echo off
chcp 65001 >nul
title تثبيت تبعيات مشروع الفلاتر (shopik_app)

set "DIR=%~dp0"
cd /d "%DIR%"
echo ============================================
echo  تثبيت تبعيات مشروع Flutter (shopik_app)
echo ============================================
echo.
echo مكان المشروع: %DIR%
echo.

where flutter >nul 2>nul
if errorlevel 1 (
    echo [X] لم يتم العثور على Flutter!
    echo     تأكد من تثبيت Flutter وإضافته إلى PATH.
    echo.
    pause
    exit /b 1
)

echo [1/2] تنزيل وربط حزم pubspec.yaml...
echo.
call flutter pub get
if errorlevel 1 (
    echo.
    echo [X] فشل flutter pub get!
    pause
    exit /b 1
)

echo.
echo [2/2] فحص سريع للمشروع...
call flutter analyze --no-pub >nul 2>nul

echo.
echo ============================================
echo  تم تثبيت جميع التبعيات بنجاح!
echo  لبناء نسخة الإصدار:
echo    flutter build apk --release --split-per-abi
echo ============================================
echo.
pause