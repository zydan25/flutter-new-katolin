@echo off
chcp 65001 >nul
title تثبيت تبعيات مشروع الويب (web)

set "DIR=%~dp0"
cd /d "%DIR%"
echo ============================================
echo  تثبيت تبعيات مشروع الويب (React + Vite)
echo ============================================
echo.
echo مكان المشروع: %DIR%
echo.

if not exist "%DIR%node_modules" (
    echo [1/2] تثبيت التبعيات باستخدام npm...
    echo.
    call npm install
    if errorlevel 1 (
        echo.
        echo [X] فشل التثبيت عبر npm!
        pause
        exit /b 1
    )
) else (
    echo [1/2] مجلد node_modules موجود مسبقاً - تمرير التثبيت.
)

echo.
echo [2/2] التحقق من اكتمال التبعيات...
if exist "%DIR%node_modules" (
    echo.
    echo ============================================
    echo  تم تثبيت جميع التبعيات بنجاح!
    echo  لتشغيل المشروع استخدم:  npm run dev
    echo  ثم افتح المتصفح على:    http://localhost:3000
    echo ============================================
) else (
    echo [X] لم يتم العثور على node_modules بعد التثبيت!
)

echo.
pause