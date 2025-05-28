# System Status Check for helpdesk.local setup
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   IT Ticketing System Status Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Node.js
Write-Host "Checking Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    Write-Host "✓ Node.js version: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Node.js not found or not working" -ForegroundColor Red
}

# Check npm dependencies
Write-Host "Checking dependencies..." -ForegroundColor Yellow
if (Test-Path "node_modules") {
    Write-Host "✓ Node modules installed" -ForegroundColor Green
} else {
    Write-Host "⚠ Node modules not found - run 'npm install'" -ForegroundColor Yellow
}

# Check for bonjour-service
if (Test-Path "node_modules/bonjour-service") {
    Write-Host "✓ bonjour-service package installed" -ForegroundColor Green
} else {
    Write-Host "✗ bonjour-service package missing" -ForegroundColor Red
}

# Check Bonjour Service on Windows
Write-Host "Checking Bonjour Service..." -ForegroundColor Yellow
$bonjourService = Get-Service -Name "Bonjour Service" -ErrorAction SilentlyContinue
if ($bonjourService) {
    if ($bonjourService.Status -eq "Running") {
        Write-Host "✓ Bonjour Service is running" -ForegroundColor Green
    } else {
        Write-Host "⚠ Bonjour Service exists but not running" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠ Bonjour Service not installed (install iTunes or Bonjour Print Services)" -ForegroundColor Yellow
}

# Check firewall rules
Write-Host "Checking firewall rules..." -ForegroundColor Yellow
$nodeRules = Get-NetFirewallRule -DisplayName "*Node*" -ErrorAction SilentlyContinue
if ($nodeRules) {
    Write-Host "✓ Found Node.js firewall rules" -ForegroundColor Green
} else {
    Write-Host "⚠ No Node.js firewall rules found" -ForegroundColor Yellow
}

# Check if port 3000 is in use
Write-Host "Checking port 3000..." -ForegroundColor Yellow
$port3000 = Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue
if ($port3000) {
    Write-Host "⚠ Port 3000 is already in use" -ForegroundColor Yellow
} else {
    Write-Host "✓ Port 3000 is available" -ForegroundColor Green
}

# Get local IP address
Write-Host "Network Information..." -ForegroundColor Yellow
$localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -like "192.168.*" -or $_.IPAddress -like "10.*" -or $_.IPAddress -like "172.*"} | Select-Object -First 1).IPAddress
if ($localIP) {
    Write-Host "✓ Local IP Address: $localIP" -ForegroundColor Green
} else {
    Write-Host "⚠ Could not determine local IP address" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "When you start the server, it will be accessible at:" -ForegroundColor White
Write-Host "  • http://helpdesk.local:3000 (if mDNS is working)" -ForegroundColor Green
if ($localIP) {
    Write-Host "  • http://$localIP`:3000 (reliable fallback)" -ForegroundColor Green
}
Write-Host "  • http://localhost:3000 (local machine only)" -ForegroundColor Green
Write-Host ""
Write-Host "To start the server:" -ForegroundColor White
Write-Host "  • Double-click: start-helpdesk-local.bat" -ForegroundColor Cyan
Write-Host "  • Or run: npm start" -ForegroundColor Cyan
Write-Host ""
