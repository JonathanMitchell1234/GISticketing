@echo off
REM IT Helpdesk System - Complete Setup Script
REM This script will install all dependencies and set up the system

echo ========================================
echo   IT Helpdesk System Setup
echo ========================================
echo.
echo This script will:
echo 1. Check for Node.js installation
echo 2. Install all required dependencies
echo 3. Generate SSL certificates for HTTPS
echo 4. Create the database
echo 5. Start the server
echo.
pause

REM Check if Node.js is installed
echo Checking for Node.js installation...
node --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js is not installed!
    echo Please download and install Node.js from: https://nodejs.org/
    echo After installation, restart this script.
    pause
    exit /b 1
)

echo ✓ Node.js is installed
node --version

REM Check if npm is available
echo Checking for npm...
npm --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: npm is not available!
    echo Please ensure Node.js is properly installed.
    pause
    exit /b 1
)

echo ✓ npm is available
npm --version
echo.

REM Install dependencies
echo Installing project dependencies...
echo This may take a few minutes...
npm install
if errorlevel 1 (
    echo ERROR: Failed to install dependencies!
    echo Please check your internet connection and try again.
    pause
    exit /b 1
)

echo ✓ Dependencies installed successfully
echo.

REM Generate SSL certificates if they don't exist
if not exist "certs\server.key" (
    echo Generating SSL certificates for HTTPS...
    node generate-cert.js
    if errorlevel 1 (
        echo ERROR: Failed to generate SSL certificates!
        pause
        exit /b 1
    )
    echo ✓ SSL certificates generated
) else (
    echo ✓ SSL certificates already exist
)
echo.

REM Create the database (it will be created automatically when the server starts)
echo ✓ Database will be initialized on first start
echo.

echo ========================================
echo   Setup Complete!
echo ========================================
echo.
echo The IT Helpdesk System is ready to run.
echo.
echo Available start options:
echo 1. HTTP only:  start-network.bat
echo 2. HTTPS only: start-https.bat
echo 3. Both:       node server.js
echo.
echo Default admin credentials:
echo Username: admin
echo Password: admin123
echo.
echo Would you like to start the server now? (Y/N)
set /p choice=Enter your choice: 

if /i "%choice%"=="Y" (
    echo.
    echo Starting IT Helpdesk System...
    echo Press Ctrl+C to stop the server
    echo.
    node server.js
) else (
    echo.
    echo Setup complete. You can start the server later using one of the batch files.
    echo.
)

pause
