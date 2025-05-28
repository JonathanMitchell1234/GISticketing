@echo off
title Test mDNS Setup
echo ====================================
echo     Testing mDNS (Bonjour) Setup
echo ====================================
echo.
echo This will test if your system can publish .local domains...
echo.
npm run test-mdns
echo.
echo Test completed. If you saw "mDNS setup is working correctly" above,
echo then helpdesk.local should work when you start the server.
echo.
echo Press any key to exit...
pause > nul
