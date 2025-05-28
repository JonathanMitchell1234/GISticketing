@echo off
title IT Ticketing System - helpdesk.local
echo =====================================
echo   IT Ticketing System with mDNS
echo =====================================
echo.
echo Checking mDNS setup...
powershell -ExecutionPolicy Bypass -File "./setup-mdns.ps1"
echo.
echo Starting server with mDNS support...
echo Your helpdesk will be available at: http://helpdesk.local:3000
echo.
echo Note: If helpdesk.local doesn't work immediately:
echo   1. Wait 30-60 seconds for mDNS to propagate
echo   2. Try refreshing your browser
echo   3. Ensure Bonjour service is installed on client devices
echo.
echo Press Ctrl+C to stop the server
echo.
npm start
echo.
echo Server stopped. Press any key to exit...
pause > nul
