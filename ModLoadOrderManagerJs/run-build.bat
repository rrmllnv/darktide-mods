@echo off
chcp 65001 >nul 2>&1
cd /d "%~dp0"
echo Building Darktide Mod Load Order Manager for Windows...

REM Check if node_modules exists
if not exist "node_modules" (
    echo Installing dependencies...
    call npm install
    if errorlevel 1 (
        echo.
        echo ERROR: Failed to install dependencies!
        echo Please check if Node.js is installed.
        pause
        exit /b 1
    )
)

REM Check if electron-builder is installed
call npm list electron-builder >nul 2>&1
if errorlevel 1 (
    echo Installing electron-builder...
    call npm install --save-dev electron-builder
    if errorlevel 1 (
        echo.
        echo ERROR: Failed to install electron-builder!
        pause
        exit /b 1
    )
)

echo.
echo Starting build process...
echo.

REM Build for Windows
call npm run build

if errorlevel 1 (
    echo.
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo.
echo Build completed successfully!
echo Check the 'dist' folder for the output files.
echo.
pause
