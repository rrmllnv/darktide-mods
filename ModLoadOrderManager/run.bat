@echo off
chcp 65001 >nul 2>&1
cd /d "%~dp0"
echo Starting Mod Load Order Manager...

REM Try different Python commands
where python >nul 2>&1
if %errorlevel% equ 0 (
    python main.py
    goto :end
)

where python3 >nul 2>&1
if %errorlevel% equ 0 (
    python3 main.py
    goto :end
)

where py >nul 2>&1
if %errorlevel% equ 0 (
    py main.py
    goto :end
)

echo.
echo ERROR: Python not found!
echo Please install Python and add it to PATH, or use python.exe directly
echo.
pause
exit /b 1

:end
if errorlevel 1 (
    echo.
    echo Error occurred while running the program.
    pause
)
