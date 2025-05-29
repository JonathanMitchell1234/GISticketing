@echo off
title IT Ticketing System - Transfer Kit Creator
color 0A

echo.
echo ========================================
echo   IT Ticketing System Transfer Kit
echo   Creating Portable Installation
echo ========================================
echo.

:: Get current directory
set "SOURCE_DIR=%~dp0"
set "TIMESTAMP=%date:~10,4%%date:~4,2%%date:~7,2%-%time:~0,2%%time:~3,2%%time:~6,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"
set "DEPLOY_NAME=TicketingSystem-Kit-%TIMESTAMP%"
set "OUTPUT_DIR=%USERPROFILE%\Desktop\%DEPLOY_NAME%"

echo [INFO] Creating transfer kit...
echo Source: %SOURCE_DIR%
echo Output: %OUTPUT_DIR%
echo.

:: Create output directory
if exist "%OUTPUT_DIR%" rmdir /s /q "%OUTPUT_DIR%"
mkdir "%OUTPUT_DIR%"

:: Copy essential files
echo [STEP 1] Copying core application files...
copy "%SOURCE_DIR%server.js" "%OUTPUT_DIR%\" >nul 2>&1 && echo   ✓ server.js
copy "%SOURCE_DIR%package.json" "%OUTPUT_DIR%\" >nul 2>&1 && echo   ✓ package.json
copy "%SOURCE_DIR%package-lock.json" "%OUTPUT_DIR%\" >nul 2>&1 && echo   ✓ package-lock.json
copy "%SOURCE_DIR%generate-cert.js" "%OUTPUT_DIR%\" >nul 2>&1 && echo   ✓ generate-cert.js

if exist "%SOURCE_DIR%.env" (
    copy "%SOURCE_DIR%.env" "%OUTPUT_DIR%\" >nul 2>&1 && echo   ✓ .env
)

:: Copy folders
echo   [Copying folders...]
if exist "%SOURCE_DIR%public" (
    xcopy "%SOURCE_DIR%public" "%OUTPUT_DIR%\public" /E /I /Q >nul 2>&1 && echo   ✓ public folder
)

if exist "%SOURCE_DIR%certs" (
    xcopy "%SOURCE_DIR%certs" "%OUTPUT_DIR%\certs" /E /I /Q >nul 2>&1 && echo   ✓ certs folder
)

:: Copy scripts
echo.
echo [STEP 2] Copying installation scripts...
copy "%SOURCE_DIR%INSTALL.bat" "%OUTPUT_DIR%\" >nul 2>&1 && echo   ✓ INSTALL.bat
copy "%SOURCE_DIR%setup.bat" "%OUTPUT_DIR%\" >nul 2>&1 && echo   ✓ setup.bat
copy "%SOURCE_DIR%setup.ps1" "%OUTPUT_DIR%\" >nul 2>&1 && echo   ✓ setup.ps1
copy "%SOURCE_DIR%deploy-production.ps1" "%OUTPUT_DIR%\" >nul 2>&1 && echo   ✓ deploy-production.ps1
copy "%SOURCE_DIR%start-https.bat" "%OUTPUT_DIR%\" >nul 2>&1 && echo   ✓ start-https.bat
copy "%SOURCE_DIR%start-network.bat" "%OUTPUT_DIR%\" >nul 2>&1 && echo   ✓ start-network.bat

:: Copy documentation
echo.
echo [STEP 3] Copying documentation...
copy "%SOURCE_DIR%README.md" "%OUTPUT_DIR%\" >nul 2>&1 && echo   ✓ README.md
copy "%SOURCE_DIR%HTTPS_SETUP.md" "%OUTPUT_DIR%\" >nul 2>&1 && echo   ✓ HTTPS_SETUP.md
copy "%SOURCE_DIR%DOMAIN_SETUP.md" "%OUTPUT_DIR%\" >nul 2>&1 && echo   ✓ DOMAIN_SETUP.md

:: Create transfer-specific installer
echo.
echo [STEP 4] Creating transfer installer...

echo @echo off > "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo title IT Ticketing System - Quick Install >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo color 0B >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo. >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo echo ======================================== >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo echo   IT Ticketing System - Quick Install >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo echo   Transfer Kit Installation >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo echo ======================================== >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo echo. >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo. >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo echo [STEP 1] Checking Node.js... >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo node --version ^>nul 2^>^&1 >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo if %%errorLevel%% == 0 ^( >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo     echo [OK] Node.js is installed >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo ^) else ^( >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo     echo [ERROR] Node.js not found! >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo     echo Please install Node.js from: https://nodejs.org/ >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo     pause >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo     exit /b 1 >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo ^) >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo echo. >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo. >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo echo [STEP 2] Installing dependencies... >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo npm install >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo echo. >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo. >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo echo [STEP 3] Generating SSL certificates... >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo node generate-cert.js >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo echo. >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo. >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo echo ======================================== >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo echo   Installation Complete! >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo echo ======================================== >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo echo. >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo echo To start the server: >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo echo   - HTTPS: Double-click start-https.bat >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo echo   - Network: Double-click start-network.bat >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo echo. >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo echo Access at: https://localhost:3443 >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo echo. >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"
echo pause >> "%OUTPUT_DIR%\QUICK-INSTALL.bat"

echo   ✓ QUICK-INSTALL.bat created

:: Create transfer instructions
echo.
echo [STEP 5] Creating transfer instructions...

echo # IT Ticketing System - Transfer Kit > "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo. >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo ## Quick Setup Instructions >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo. >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo ### Prerequisites >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo 1. Windows PC ^(Windows 7/8/10/11^) >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo 2. Node.js installed ^(download from https://nodejs.org/^) >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo. >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo ### Installation Steps >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo 1. Copy this entire folder to the target PC >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo 2. Right-click on `QUICK-INSTALL.bat` and select "Run as administrator" >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo 3. Wait for installation to complete >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo 4. Double-click `start-https.bat` to start the server >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo 5. Open browser to https://localhost:3443 >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo. >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo ### Alternative Installation >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo - Use `INSTALL.bat` for full installation with firewall setup >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo - Use `setup.ps1` for PowerShell-based installation >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo - Use `deploy-production.ps1` for Windows service installation >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo. >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo ### Network Access >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo For SharePoint embedding or network access: >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo 1. Use `start-network.bat` instead of `start-https.bat` >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo 2. Access via https://[PC-IP-ADDRESS]:3443 >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo 3. Configure firewall to allow ports 3000 and 3443 >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo. >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo ### Troubleshooting >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo - **Certificate Warning**: Click "Advanced" then "Proceed to localhost" >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo - **Cannot Access**: Check firewall settings and run installer as administrator >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"
echo - **Node.js Errors**: Ensure Node.js is properly installed >> "%OUTPUT_DIR%\TRANSFER-INSTRUCTIONS.md"

echo   ✓ TRANSFER-INSTRUCTIONS.md created

:: Create transfer info file
echo.
echo [STEP 6] Creating transfer information...

echo IT Ticketing System - Transfer Kit > "%OUTPUT_DIR%\TRANSFER-INFO.txt"
echo Generated: %date% %time% >> "%OUTPUT_DIR%\TRANSFER-INFO.txt"
echo Source: %COMPUTERNAME% >> "%OUTPUT_DIR%\TRANSFER-INFO.txt"
echo. >> "%OUTPUT_DIR%\TRANSFER-INFO.txt"
echo This transfer kit contains: >> "%OUTPUT_DIR%\TRANSFER-INFO.txt"
echo - Complete IT Ticketing System application >> "%OUTPUT_DIR%\TRANSFER-INFO.txt"
echo - Installation scripts for easy setup >> "%OUTPUT_DIR%\TRANSFER-INFO.txt"
echo - SSL certificate generation tools >> "%OUTPUT_DIR%\TRANSFER-INFO.txt"
echo - Startup scripts for different modes >> "%OUTPUT_DIR%\TRANSFER-INFO.txt"
echo - Documentation and setup guides >> "%OUTPUT_DIR%\TRANSFER-INFO.txt"
echo. >> "%OUTPUT_DIR%\TRANSFER-INFO.txt"
echo Quick Start: >> "%OUTPUT_DIR%\TRANSFER-INFO.txt"
echo 1. Install Node.js from https://nodejs.org/ >> "%OUTPUT_DIR%\TRANSFER-INFO.txt"
echo 2. Run QUICK-INSTALL.bat as administrator >> "%OUTPUT_DIR%\TRANSFER-INFO.txt"
echo 3. Start server with start-https.bat >> "%OUTPUT_DIR%\TRANSFER-INFO.txt"
echo 4. Access at https://localhost:3443 >> "%OUTPUT_DIR%\TRANSFER-INFO.txt"

echo   ✓ TRANSFER-INFO.txt created

echo.
echo ========================================
echo   Transfer Kit Creation Complete!
echo ========================================
echo.
echo Package Location: %OUTPUT_DIR%
echo.
echo Transfer Methods:
echo   1. Copy folder to USB drive
echo   2. ZIP and email/share
echo   3. Network file sharing
echo.
echo Installation on Target PC:
echo   1. Copy entire folder
echo   2. Run QUICK-INSTALL.bat as admin
echo   3. Start with start-https.bat
echo.
echo The transfer kit is ready for deployment!
echo.

:: Ask to open folder
set /p open_choice="Open transfer kit folder? (y/n): "
if /i "%open_choice%"=="y" (
    explorer "%OUTPUT_DIR%"
)

echo.
echo Transfer kit creation complete!
pause
