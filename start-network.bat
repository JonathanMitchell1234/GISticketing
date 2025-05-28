@echo off
echo Starting IT Ticketing System for Network Access...
echo.
echo Setting up mDNS (Bonjour) service...
powershell -ExecutionPolicy Bypass -File "./setup-mdns.ps1"
echo.
echo Make sure Windows Firewall allows Node.js through the firewall
echo or manually allow port 3000 through Windows Firewall.
echo.
echo Your ticketing system will be available at:
echo   - http://helpdesk.local:3000 (recommended)
echo   - http://localhost:3000 (local only)
echo   - http://[your-ip]:3000 (fallback)
echo.
echo Press Ctrl+C to stop the server
echo.
npm start
pause
