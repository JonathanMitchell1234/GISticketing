# IT Helpdesk System - PowerShell Setup Script
# This script will install all dependencies and set up the system

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   IT Helpdesk System Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will:" -ForegroundColor Yellow
Write-Host "1. Check for Node.js installation" -ForegroundColor White
Write-Host "2. Install all required dependencies" -ForegroundColor White
Write-Host "3. Generate SSL certificates for HTTPS" -ForegroundColor White
Write-Host "4. Create the database" -ForegroundColor White
Write-Host "5. Start the server" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to continue..."

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
    Write-Host "Please download and install Node.js from: https://nodejs.org/" -ForegroundColor Yellow
    Write-Host "After installation, restart this script." -ForegroundColor Yellow
    Read-Host "Press Enter to exit..."
    exit 1
}

# Check if npm is available
Write-Host "Checking for npm..." -ForegroundColor Yellow
try {
    $npmVersion = npm --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ npm is available: $npmVersion" -ForegroundColor Green
    } else {
        throw "npm not found"
    }
} catch {
    Write-Host "ERROR: npm is not available!" -ForegroundColor Red
    Write-Host "Please ensure Node.js is properly installed." -ForegroundColor Yellow
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host ""

# Install dependencies
Write-Host "Installing project dependencies..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor White
try {
    npm install
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Dependencies installed successfully" -ForegroundColor Green
    } else {
        throw "npm install failed"
    }
} catch {
    Write-Host "ERROR: Failed to install dependencies!" -ForegroundColor Red
    Write-Host "Please check your internet connection and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host ""

# Generate SSL certificates if they don't exist
if (-not (Test-Path "certs\server.key")) {
    Write-Host "Generating SSL certificates for HTTPS..." -ForegroundColor Yellow
    try {
        node generate-cert.js
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ SSL certificates generated" -ForegroundColor Green
        } else {
            throw "Certificate generation failed"
        }
    } catch {
        Write-Host "ERROR: Failed to generate SSL certificates!" -ForegroundColor Red
        Read-Host "Press Enter to exit..."
        exit 1
    }
} else {
    Write-Host "✓ SSL certificates already exist" -ForegroundColor Green
}

Write-Host ""
Write-Host "✓ Database will be initialized on first start" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Setup Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "The IT Helpdesk System is ready to run." -ForegroundColor Green
Write-Host ""
Write-Host "Available start options:" -ForegroundColor Yellow
Write-Host "1. HTTP only:  .\start-network.bat" -ForegroundColor White
Write-Host "2. HTTPS only: .\start-https.bat" -ForegroundColor White
Write-Host "3. Both:       node server.js" -ForegroundColor White
Write-Host ""
Write-Host "Default admin credentials:" -ForegroundColor Yellow
Write-Host "Username: admin" -ForegroundColor White
Write-Host "Password: admin123" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Would you like to start the server now? (Y/N)"

if ($choice -eq "Y" -or $choice -eq "y") {
    Write-Host ""
    Write-Host "Starting IT Helpdesk System..." -ForegroundColor Green
    Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Server will be available at:" -ForegroundColor Cyan
    Write-Host "- HTTP:  http://localhost:3000" -ForegroundColor White
    Write-Host "- HTTPS: https://localhost:3443" -ForegroundColor White
    Write-Host ""
    
    # Start the server
    node server.js
} else {
    Write-Host ""
    Write-Host "Setup complete. You can start the server later using one of the batch files." -ForegroundColor Green
    Write-Host ""
    Read-Host "Press Enter to exit..."
}
