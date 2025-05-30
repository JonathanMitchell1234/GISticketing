# Configure Windows Firewall for Vercel Frontend Access
# This script opens the necessary ports for your Vercel frontend to access your local backend

Write-Host "Configuring Windows Firewall for Helpdesk System..." -ForegroundColor Green

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires administrator privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    pause
    exit 1
}

try {
    # Remove existing rules if they exist
    Write-Host "Removing existing firewall rules..." -ForegroundColor Yellow
    Remove-NetFirewallRule -DisplayName "Helpdesk HTTP (Port 3000)" -ErrorAction SilentlyContinue
    Remove-NetFirewallRule -DisplayName "Helpdesk HTTPS (Port 3443)" -ErrorAction SilentlyContinue

    # Create new inbound rules for HTTP and HTTPS
    Write-Host "Creating firewall rule for HTTP (Port 3000)..." -ForegroundColor Cyan
    New-NetFirewallRule -DisplayName "Helpdesk HTTP (Port 3000)" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow -Profile Any

    Write-Host "Creating firewall rule for HTTPS (Port 3443)..." -ForegroundColor Cyan
    New-NetFirewallRule -DisplayName "Helpdesk HTTPS (Port 3443)" -Direction Inbound -Protocol TCP -LocalPort 3443 -Action Allow -Profile Any

    Write-Host ""
    Write-Host "✅ Firewall configuration completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your local backend is now accessible from:" -ForegroundColor White
    Write-Host "  HTTP:  http://192.168.21.40:3000" -ForegroundColor Cyan
    Write-Host "  HTTPS: https://192.168.21.40:3443" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Your Vercel frontend can now connect to your local backend!" -ForegroundColor Green

} catch {
    Write-Host "❌ Error configuring firewall: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Start your backend server: node server.js" -ForegroundColor White
Write-Host "2. Test from another device: http://192.168.21.40:3000" -ForegroundColor White
Write-Host "3. Update your Vercel frontend code with the backend URL" -ForegroundColor White

pause
