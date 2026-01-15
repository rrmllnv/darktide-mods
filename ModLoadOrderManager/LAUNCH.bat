@echo off
cd /d "%~dp0"
start "" python.exe main.py
if errorlevel 1 (
    start "" python main.py
    if errorlevel 1 (
        start "" py main.py
    )
)
