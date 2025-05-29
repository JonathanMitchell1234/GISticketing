@echo off
REM One-Click IT Helpdesk System Installer
REM This is the main entry point for installation

title IT Helpdesk System - One-Click Installer

echo.
echo  ██╗████████╗    ██╗  ██╗███████╗██╗     ██████╗ ██████╗ ███████╗███████╗██╗  ██╗
echo  ██║╚══██╔══╝    ██║  ██║██╔════╝██║     ██╔══██╗██╔══██╗██╔════╝██╔════╝██║ ██╔╝
echo  ██║   ██║       ███████║█████╗  ██║     ██████╔╝██║  ██║█████╗  ███████╗█████╔╝ 
echo  ██║   ██║       ██╔══██║██╔══╝  ██║     ██╔═══╝ ██║  ██║██╔══╝  ╚════██║██╔═██╗ 
echo  ██║   ██║       ██║  ██║███████╗███████╗██║     ██████╔╝███████╗███████║██║  ██╗
echo  ╚═╝   ╚═╝       ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝
echo.
echo                           One-Click Installer
echo.
echo ================================================================================
echo  Welcome to the IT Helpdesk System Installer!
echo ================================================================================
echo.
echo This installer will:
echo  ^> Check system requirements
echo  ^> Download and install Node.js (if needed)
echo  ^> Install all dependencies
echo  ^> Generate SSL certificates
echo  ^> Set up the database
echo  ^> Configure firewall rules
echo  ^> Start the server
echo.
echo Requirements:
echo  ^> Windows 10/11 or Windows Server 2016+
echo  ^> Internet connection for downloading dependencies
echo  ^> Administrator rights (recommended)
echo.
echo ================================================================================
echo.

set /p choice="Ready to install? (Y/N): "
if /i not "%choice%"=="Y" (
    echo Installation cancelled.
    pause
    exit /b 0
)

echo.
echo ================================================================================
echo  Starting Installation...
echo ================================================================================
echo.

REM Check for PowerShell
powershell -Command "Get-Host" >nul 2>&1
if errorlevel 1 (
    echo ERROR: PowerShell is not available!
    echo This installer requires PowerShell to run.
    pause
    exit /b 1
)

REM Run the PowerShell setup script
echo Running setup script...
powershell -ExecutionPolicy Bypass -File "setup.ps1"

if errorlevel 1 (
    echo.
    echo ================================================================================
    echo  Installation failed!
    echo ================================================================================
    echo.
    echo Please check the error messages above and try again.
    echo If you continue to have issues, please check the documentation.
    echo.
    pause
    exit /b 1
)

echo.
echo ================================================================================
echo  Installation completed successfully!
echo ================================================================================
echo.
echo The IT Helpdesk System is now installed and ready to use.
echo.
echo Next steps:
echo  1. The server should be running now
echo  2. Open a web browser and go to https://localhost:3443
echo  3. Accept the security warning (self-signed certificate)
echo  4. Log in with: admin / admin123
echo  5. Change the default password immediately!
echo.
echo For future use:
echo  - Double-click 'start-https.bat' to start the server
echo  - Use 'start-production.bat' for production deployment
echo.
pause
