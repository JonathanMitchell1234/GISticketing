# IT Helpdesk System - Production Deployment Script
# This script sets up the system for production use on a new Windows PC

param(
    [switch]$SkipNodeCheck,
    [string]$Port = "3000",
    [string]$HttpsPort = "3443",
    [switch]$HttpsOnly
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   IT Helpdesk System - Production Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check if running as administrator
if (-not (Test-Administrator)) {
    Write-Host "WARNING: This script is not running as administrator." -ForegroundColor Yellow
    Write-Host "Some features may not work properly without admin rights." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Production deployment options:" -ForegroundColor Yellow
Write-Host "- HTTP Port: $Port" -ForegroundColor White
Write-Host "- HTTPS Port: $HttpsPort" -ForegroundColor White
if ($HttpsOnly) {
    Write-Host "- Mode: HTTPS Only" -ForegroundColor White
} else {
    Write-Host "- Mode: HTTP + HTTPS" -ForegroundColor White
}
Write-Host ""

# Check Windows version and compatibility
$osVersion = [System.Environment]::OSVersion.Version
Write-Host "Operating System: Windows $($osVersion.Major).$($osVersion.Minor)" -ForegroundColor White

if (-not $SkipNodeCheck) {
    # Check if Node.js is installed
    Write-Host "Checking for Node.js installation..." -ForegroundColor Yellow
    try {
        $nodeVersion = node --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Node.js is installed: $nodeVersion" -ForegroundColor Green
        } else {
            throw "Node.js not found"
        }
    } catch {
        Write-Host "ERROR: Node.js is not installed!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Installing Node.js automatically..." -ForegroundColor Yellow
        
        # Try to install Node.js using Chocolatey if available
        try {
            choco --version 2>$null | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Found Chocolatey, installing Node.js..." -ForegroundColor Green
                choco install nodejs -y
            } else {
                throw "Chocolatey not available"
            }
        } catch {
            Write-Host "Please install Node.js manually:" -ForegroundColor Yellow
            Write-Host "1. Download from: https://nodejs.org/" -ForegroundColor White
            Write-Host "2. Run the installer" -ForegroundColor White
            Write-Host "3. Restart this script" -ForegroundColor White
            Read-Host "Press Enter to exit..."
            exit 1
        }
    }
}

# Create necessary directories
$directories = @("logs", "backup", "config")
foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "✓ Created directory: $dir" -ForegroundColor Green
    }
}

# Install dependencies
Write-Host "Installing production dependencies..." -ForegroundColor Yellow
try {
    npm install --production
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Production dependencies installed" -ForegroundColor Green
    } else {
        throw "npm install failed"
    }
} catch {
    Write-Host "ERROR: Failed to install dependencies!" -ForegroundColor Red
    exit 1
}

# Generate SSL certificates
if (-not (Test-Path "certs\server.key")) {
    Write-Host "Generating SSL certificates..." -ForegroundColor Yellow
    node generate-cert.js
    Write-Host "✓ SSL certificates generated" -ForegroundColor Green
} else {
    Write-Host "✓ SSL certificates already exist" -ForegroundColor Green
}

# Create Windows service configuration (optional)
$serviceScript = @"
@echo off
REM IT Helpdesk Service Wrapper
cd /d "%~dp0"
node server.js
"@

$serviceScript | Out-File -FilePath "service.bat" -Encoding ASCII
Write-Host "✓ Service wrapper created" -ForegroundColor Green

# Create firewall rules (if running as admin)
if (Test-Administrator) {
    Write-Host "Configuring Windows Firewall..." -ForegroundColor Yellow
    try {
        # Remove existing rules first
        netsh advfirewall firewall delete rule name="IT Helpdesk HTTP" 2>$null
        netsh advfirewall firewall delete rule name="IT Helpdesk HTTPS" 2>$null
        
        # Add new rules
        netsh advfirewall firewall add rule name="IT Helpdesk HTTP" dir=in action=allow protocol=TCP localport=$Port
        netsh advfirewall firewall add rule name="IT Helpdesk HTTPS" dir=in action=allow protocol=TCP localport=$HttpsPort
        
        Write-Host "✓ Firewall rules configured" -ForegroundColor Green
    } catch {
        Write-Host "⚠ Could not configure firewall automatically" -ForegroundColor Yellow
        Write-Host "  You may need to allow ports $Port and $HttpsPort manually" -ForegroundColor White
    }
} else {
    Write-Host "⚠ Skipping firewall configuration (not administrator)" -ForegroundColor Yellow
}

# Get network information
$networkInfo = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*" }
$primaryIP = $networkInfo[0].IPAddress

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Production Setup Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "The IT Helpdesk System is ready for production use." -ForegroundColor Green
Write-Host ""
Write-Host "Access URLs:" -ForegroundColor Yellow
Write-Host "- Local HTTP:    http://localhost:$Port" -ForegroundColor White
Write-Host "- Local HTTPS:   https://localhost:$HttpsPort" -ForegroundColor White
Write-Host "- Network HTTP:  http://$primaryIP:$Port" -ForegroundColor White
Write-Host "- Network HTTPS: https://$primaryIP:$HttpsPort" -ForegroundColor White
Write-Host ""
Write-Host "Default admin credentials:" -ForegroundColor Yellow
Write-Host "Username: admin" -ForegroundColor White
Write-Host "Password: admin123" -ForegroundColor White
Write-Host ""
Write-Host "IMPORTANT: Change the default admin password after first login!" -ForegroundColor Red
Write-Host ""

# Create startup script
$startupScript = @"
@echo off
echo Starting IT Helpdesk System in Production Mode...
cd /d "%~dp0"
set NODE_ENV=production
set PORT=$Port
set HTTPS_PORT=$HttpsPort
node server.js
pause
"@

$startupScript | Out-File -FilePath "start-production.bat" -Encoding ASCII
Write-Host "✓ Production startup script created: start-production.bat" -ForegroundColor Green

$choice = Read-Host "Would you like to start the server now? (Y/N)"

if ($choice -eq "Y" -or $choice -eq "y") {
    Write-Host ""
    Write-Host "Starting IT Helpdesk System in production mode..." -ForegroundColor Green
    Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
    Write-Host ""
    
    # Set environment variables for production
    $env:NODE_ENV = "production"
    $env:PORT = $Port
    $env:HTTPS_PORT = $HttpsPort
    
    # Start the server
    node server.js
} else {
    Write-Host ""
    Write-Host "Production setup complete!" -ForegroundColor Green
    Write-Host "Use 'start-production.bat' to start the server." -ForegroundColor White
    Write-Host ""
}
