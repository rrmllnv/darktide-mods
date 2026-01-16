@echo off
chcp 65001 >nul 2>&1
cd /d "%~dp0"
echo Starting Mod Load Order Manager (JavaScript) in DEV mode...
echo DevTools will be opened automatically.
echo.

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

REM Try to run the application in dev mode
where npm >nul 2>&1
if %errorlevel% equ 0 (
    npm run dev
    goto :end
)

echo.
echo ERROR: npm not found!
echo Please install Node.js and add it to PATH
echo.
pause
exit /b 1

:end
if errorlevel 1 (
    echo.
    echo Error occurred while running the program.
    pause
)
