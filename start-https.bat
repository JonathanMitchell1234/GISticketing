@echo off
echo Starting IT Helpdesk System with HTTPS support...
echo.
echo This will start both HTTP and HTTPS servers:
echo - HTTP:  http://localhost:3000
echo - HTTPS: https://localhost:3443
echo.
echo For SharePoint embedding, use the HTTPS URL.
echo You may need to accept the security warning for the self-signed certificate.
echo.
node server.js
pause
