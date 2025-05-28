# PowerShell script to setup mDNS for the IT Ticketing System
# This script helps configure Windows for mDNS (.local domain) support

Write-Host "Setting up mDNS for IT Ticketing System..." -ForegroundColor Green

# Check if Bonjour Print Services is installed (provides mDNS support on Windows)
$bonjourService = Get-Service -Name "Bonjour Service" -ErrorAction SilentlyContinue

if (-not $bonjourService) {
    Write-Host "Warning: Bonjour Service not found." -ForegroundColor Yellow
    Write-Host "For best .local domain support on Windows, consider installing:" -ForegroundColor Yellow
    Write-Host "  - iTunes (includes Bonjour)" -ForegroundColor Yellow
    Write-Host "  - Or download Bonjour Print Services from Apple" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host "✓ Bonjour Service is installed" -ForegroundColor Green
}

# Check Windows Defender Firewall
Write-Host "Checking Windows Defender Firewall..." -ForegroundColor Cyan

# Check if Node.js has firewall rules
$nodeRules = Get-NetFirewallRule -DisplayName "*Node*" -ErrorAction SilentlyContinue
if ($nodeRules) {
    Write-Host "✓ Found existing Node.js firewall rules" -ForegroundColor Green
} else {
    Write-Host "Creating firewall rules for Node.js..." -ForegroundColor Yellow
    
    try {
        # Allow Node.js through firewall
        New-NetFirewallRule -DisplayName "Node.js HTTP Server" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow -ErrorAction Stop
        Write-Host "✓ Created firewall rule for port 3000" -ForegroundColor Green
    } catch {
        Write-Host "⚠ Could not create firewall rule. You may need to run as Administrator." -ForegroundColor Yellow
        Write-Host "  Or manually allow Node.js through Windows Defender Firewall" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Setup Summary:" -ForegroundColor Cyan
Write-Host "  • Your app will be available at: http://helpdesk.local:3000" -ForegroundColor White
Write-Host "  • mDNS service will be published when you start the server" -ForegroundColor White
Write-Host "  • It may take 30-60 seconds for the domain to become discoverable" -ForegroundColor White
Write-Host ""
Write-Host "Usage on different devices:" -ForegroundColor Cyan
Write-Host "  • Windows: Install iTunes or Bonjour Print Services for best support" -ForegroundColor White
Write-Host "  • macOS: Built-in support for .local domains" -ForegroundColor White
Write-Host "  • iOS/Android: Most modern browsers support .local domains" -ForegroundColor White
Write-Host ""
Write-Host "If helpdesk.local doesn't work, you can still use:" -ForegroundColor Yellow
Write-Host "  • http://localhost:3000 (local machine only)" -ForegroundColor White
Write-Host "  • http://[your-ip]:3000 (any device on network)" -ForegroundColor White
