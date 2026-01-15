@echo off
cd /d "%~dp0"
python.exe main.py
if errorlevel 1 (
    python main.py
    if errorlevel 1 (
        py main.py
    )
)
pause
