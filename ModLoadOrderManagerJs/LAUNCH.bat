@echo off
cd /d "%~dp0"
if not exist "node_modules" (
    start "" npm install
    timeout /t 5
)
start "" npm start
