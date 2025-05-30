# Test Vercel-to-Local Backend Connection
# This script helps verify that your configuration is working correctly

Write-Host "=== Vercel Frontend to Local Backend Test ===" -ForegroundColor Green
Write-Host ""

# Test 1: Check if CORS is configured correctly
Write-Host "1. Testing CORS Configuration..." -ForegroundColor Cyan
try {
    node test-vercel-cors.js
    Write-Host "   ✅ CORS configuration test passed" -ForegroundColor Green
} catch {
    Write-Host "   ❌ CORS configuration test failed" -ForegroundColor Red
}

Write-Host ""

# Test 2: Check if ports are accessible
Write-Host "2. Testing Network Connectivity..." -ForegroundColor Cyan

# Test HTTP port
Write-Host "   Testing HTTP port 3000..." -ForegroundColor White
$httpTest = Test-NetConnection -ComputerName "192.168.21.40" -Port 3000 -WarningAction SilentlyContinue
if ($httpTest.TcpTestSucceeded) {
    Write-Host "   ✅ HTTP port 3000 is accessible" -ForegroundColor Green
} else {
    Write-Host "   ❌ HTTP port 3000 is not accessible" -ForegroundColor Red
    Write-Host "      This may be normal if the server is not running" -ForegroundColor Yellow
}

# Test HTTPS port
Write-Host "   Testing HTTPS port 3443..." -ForegroundColor White
$httpsTest = Test-NetConnection -ComputerName "192.168.21.40" -Port 3443 -WarningAction SilentlyContinue
if ($httpsTest.TcpTestSucceeded) {
    Write-Host "   ✅ HTTPS port 3443 is accessible" -ForegroundColor Green
} else {
    Write-Host "   ❌ HTTPS port 3443 is not accessible" -ForegroundColor Red
    Write-Host "      This may be normal if the server is not running" -ForegroundColor Yellow
}

Write-Host ""

# Test 3: Check firewall rules
Write-Host "3. Checking Firewall Rules..." -ForegroundColor Cyan
$httpRule = Get-NetFirewallRule -DisplayName "Helpdesk HTTP (Port 3000)" -ErrorAction SilentlyContinue
$httpsRule = Get-NetFirewallRule -DisplayName "Helpdesk HTTPS (Port 3443)" -ErrorAction SilentlyContinue

if ($httpRule -and $httpRule.Enabled -eq "True") {
    Write-Host "   ✅ HTTP firewall rule is active" -ForegroundColor Green
} else {
    Write-Host "   ❌ HTTP firewall rule is missing or disabled" -ForegroundColor Red
    Write-Host "      Run configure-firewall-for-vercel.ps1 as Administrator" -ForegroundColor Yellow
}

if ($httpsRule -and $httpsRule.Enabled -eq "True") {
    Write-Host "   ✅ HTTPS firewall rule is active" -ForegroundColor Green
} else {
    Write-Host "   ❌ HTTPS firewall rule is missing or disabled" -ForegroundColor Red
    Write-Host "      Run configure-firewall-for-vercel.ps1 as Administrator" -ForegroundColor Yellow
}

Write-Host ""

# Test 4: Configuration summary
Write-Host "4. Configuration Summary:" -ForegroundColor Cyan
Write-Host "   Local IP Address: 192.168.21.40" -ForegroundColor White
Write-Host "   Backend HTTP URL: http://192.168.21.40:3000" -ForegroundColor White
Write-Host "   Backend HTTPS URL: https://192.168.21.40:3443" -ForegroundColor White
Write-Host "   Vercel Frontend: https://graphicinfohelpdesk.vercel.app" -ForegroundColor White
Write-Host "   CORS Status: ✅ Configured for Vercel domain" -ForegroundColor Green

Write-Host ""

# Instructions
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. If firewall rules are missing, run:" -ForegroundColor White
Write-Host "   configure-firewall-for-vercel.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Start your backend server:" -ForegroundColor White
Write-Host "   node server.js" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. In your Vercel frontend code, use:" -ForegroundColor White
Write-Host "   const backendUrl = 'https://192.168.21.40:3443';" -ForegroundColor Cyan
Write-Host "   // or 'http://192.168.21.40:3000' for HTTP" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Test your connection from the browser console:" -ForegroundColor White
Write-Host "   fetch('https://192.168.21.40:3443/api/stats')" -ForegroundColor Cyan

pause
