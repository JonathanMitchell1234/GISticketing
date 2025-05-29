# ================================================================
# IT Ticketing System - Full Deployment Package Creator
# Creates a complete deployment package for easy installation
# on other Windows PCs
# ================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  IT Ticketing System Deployment" -ForegroundColor Yellow
Write-Host "  Full Package Creator" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get current directory
$sourceDir = $PSScriptRoot
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$deploymentName = "TicketingSystem-Deploy-$timestamp"
$outputDir = Join-Path $env:USERPROFILE "Desktop\$deploymentName"

Write-Host "Creating deployment package..." -ForegroundColor Green
Write-Host "Source: $sourceDir" -ForegroundColor Gray
Write-Host "Output: $outputDir" -ForegroundColor Gray
Write-Host ""

# Create output directory
if (Test-Path $outputDir) {
    Remove-Item $outputDir -Recurse -Force
}
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

# Files and folders to include
$includeItems = @(
    "server.js",
    "package.json",
    "package-lock.json",
    "generate-cert.js",
    "public",
    "certs",
    ".env",
    "README.md",
    "HTTPS_SETUP.md",
    "DOMAIN_SETUP.md"
)

# Scripts to include
$scriptItems = @(
    "INSTALL.bat",
    "setup.bat",
    "setup.ps1",
    "deploy-production.ps1",
    "start-https.bat",
    "start-network.bat"
)

Write-Host "Copying core application files..." -ForegroundColor Yellow
foreach ($item in $includeItems) {
    $sourcePath = Join-Path $sourceDir $item
    if (Test-Path $sourcePath) {
        if (Test-Path $sourcePath -PathType Container) {
            # It's a directory
            Copy-Item $sourcePath $outputDir -Recurse -Force
            Write-Host "  ✓ Copied folder: $item" -ForegroundColor Green
        } else {
            # It's a file
            Copy-Item $sourcePath $outputDir -Force
            Write-Host "  ✓ Copied file: $item" -ForegroundColor Green
        }
    } else {
        Write-Host "  ⚠ Skipped (not found): $item" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Copying deployment scripts..." -ForegroundColor Yellow
foreach ($script in $scriptItems) {
    $sourcePath = Join-Path $sourceDir $script
    if (Test-Path $sourcePath) {
        Copy-Item $sourcePath $outputDir -Force
        Write-Host "  ✓ Copied script: $script" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Skipped (not found): $script" -ForegroundColor Yellow
    }
}

# Create an enhanced main installer script
Write-Host ""
Write-Host "Creating enhanced installer..." -ForegroundColor Yellow

$installerContent = @'
@echo off
title IT Ticketing System - Complete Installer
color 0B

echo.
echo ========================================
echo   IT Ticketing System Installer
echo   Complete Setup for Windows
echo ========================================
echo.

echo [INFO] Starting installation process...
echo.

:: Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Running with Administrator privileges
) else (
    echo [WARNING] Not running as Administrator
    echo Some features may require elevated privileges
)
echo.

:: Check if Node.js is installed
echo [STEP 1] Checking Node.js installation...
node --version >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Node.js is installed
    node --version
) else (
    echo [ERROR] Node.js is not installed!
    echo.
    echo Please download and install Node.js from:
    echo https://nodejs.org/
    echo.
    echo After installing Node.js, run this installer again.
    pause
    exit /b 1
)
echo.

:: Install dependencies
echo [STEP 2] Installing dependencies...
if exist "package.json" (
    npm install
    if %errorLevel% == 0 (
        echo [OK] Dependencies installed successfully
    ) else (
        echo [ERROR] Failed to install dependencies
        pause
        exit /b 1
    )
) else (
    echo [ERROR] package.json not found!
    pause
    exit /b 1
)
echo.

:: Generate SSL certificates
echo [STEP 3] Generating SSL certificates...
if exist "generate-cert.js" (
    node generate-cert.js
    if %errorLevel% == 0 (
        echo [OK] SSL certificates generated
    ) else (
        echo [WARNING] Certificate generation failed
    )
) else (
    echo [WARNING] Certificate generator not found
)
echo.

:: Create startup shortcuts
echo [STEP 4] Creating startup shortcuts...
if exist "start-https.bat" (
    echo [OK] HTTPS startup script available
) else (
    echo [INFO] Creating HTTPS startup script...
    echo @echo off > start-https.bat
    echo title IT Ticketing System - HTTPS Server >> start-https.bat
    echo node server.js >> start-https.bat
    echo pause >> start-https.bat
)

if exist "start-network.bat" (
    echo [OK] Network startup script available
) else (
    echo [INFO] Creating network startup script...
    echo @echo off > start-network.bat
    echo title IT Ticketing System - Network Server >> start-network.bat
    echo set NETWORK_MODE=true >> start-network.bat
    echo node server.js >> start-network.bat
    echo pause >> start-network.bat
)
echo.

:: Firewall configuration prompt
echo [STEP 5] Firewall Configuration
echo.
echo The system uses these ports:
echo   - HTTP:  3000
echo   - HTTPS: 3443
echo.
echo Would you like to configure Windows Firewall rules? (y/n)
set /p firewall_choice="Enter choice: "
if /i "%firewall_choice%"=="y" (
    echo [INFO] Configuring firewall rules...
    netsh advfirewall firewall add rule name="IT Ticketing HTTP" dir=in action=allow protocol=TCP localport=3000 2>nul
    netsh advfirewall firewall add rule name="IT Ticketing HTTPS" dir=in action=allow protocol=TCP localport=3443 2>nul
    echo [OK] Firewall rules added
) else (
    echo [SKIP] Firewall configuration skipped
)
echo.

:: Installation complete
echo ========================================
echo   Installation Complete!
echo ========================================
echo.
echo Quick Start Options:
echo   1. Double-click 'start-https.bat' for HTTPS server
echo   2. Double-click 'start-network.bat' for network access
echo   3. Run 'deploy-production.ps1' for service installation
echo.
echo Access URLs:
echo   Local:    https://localhost:3443
echo   Network:  https://[YOUR-IP]:3443
echo.
echo NOTE: You may need to accept the self-signed certificate
echo       warning in your browser for HTTPS access.
echo.
echo Press any key to exit...
pause >nul
'@

$installerPath = Join-Path $outputDir "INSTALL-COMPLETE.bat"
$installerContent | Set-Content $installerPath -Encoding ASCII
Write-Host "  ✓ Created: INSTALL-COMPLETE.bat" -ForegroundColor Green

# Create a PowerShell installer as well
$psInstallerContent = @'
# IT Ticketing System - PowerShell Installer
# Enhanced installer with better error handling and user interaction

param(
    [switch]$Unattended,
    [switch]$SkipFirewall,
    [switch]$CreateService
)

# Set up console
$Host.UI.RawUI.WindowTitle = "IT Ticketing System Installer"
Clear-Host

function Write-Banner {
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host "  IT Ticketing System - PowerShell Installer" -ForegroundColor Yellow
    Write-Host "  Complete Setup for Windows" -ForegroundColor Yellow
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param($StepNumber, $Description)
    Write-Host "[STEP $StepNumber] $Description" -ForegroundColor Cyan
}

function Write-Success {
    param($Message)
    Write-Host "  ✓ $Message" -ForegroundColor Green
}

function Write-Warning {
    param($Message)
    Write-Host "  ⚠ $Message" -ForegroundColor Yellow
}

function Write-Error {
    param($Message)
    Write-Host "  ✗ $Message" -ForegroundColor Red
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-NodeDependencies {
    if (Test-Path "package.json") {
        Write-Host "Installing Node.js dependencies..." -ForegroundColor Yellow
        $result = Start-Process -FilePath "npm" -ArgumentList "install" -Wait -PassThru -NoNewWindow
        if ($result.ExitCode -eq 0) {
            Write-Success "Dependencies installed successfully"
            return $true
        } else {
            Write-Error "Failed to install dependencies"
            return $false
        }
    } else {
        Write-Error "package.json not found!"
        return $false
    }
}

function Install-SSLCertificates {
    if (Test-Path "generate-cert.js") {
        Write-Host "Generating SSL certificates..." -ForegroundColor Yellow
        $result = Start-Process -FilePath "node" -ArgumentList "generate-cert.js" -Wait -PassThru -NoNewWindow
        if ($result.ExitCode -eq 0) {
            Write-Success "SSL certificates generated"
            return $true
        } else {
            Write-Warning "Certificate generation failed"
            return $false
        }
    } else {
        Write-Warning "Certificate generator not found"
        return $false
    }
}

function Install-FirewallRules {
    if (Test-Administrator) {
        try {
            Write-Host "Configuring Windows Firewall..." -ForegroundColor Yellow
            netsh advfirewall firewall add rule name="IT Ticketing HTTP" dir=in action=allow protocol=TCP localport=3000 2>$null
            netsh advfirewall firewall add rule name="IT Ticketing HTTPS" dir=in action=allow protocol=TCP localport=3443 2>$null
            Write-Success "Firewall rules configured"
            return $true
        } catch {
            Write-Warning "Firewall configuration failed: $($_.Exception.Message)"
            return $false
        }
    } else {
        Write-Warning "Administrator privileges required for firewall configuration"
        return $false
    }
}

function Get-NetworkIP {
    try {
        $networkAdapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up" -and $_.InterfaceDescription -notlike "*Loopback*"}
        $ipConfig = Get-NetIPAddress -InterfaceIndex $networkAdapter[0].InterfaceIndex -AddressFamily IPv4
        return $ipConfig.IPAddress
    } catch {
        return "Unable to determine"
    }
}

# Main installation process
Write-Banner

# Check Administrator privileges
if (Test-Administrator) {
    Write-Success "Running with Administrator privileges"
} else {
    Write-Warning "Not running as Administrator - some features may be limited"
}
Write-Host ""

# Step 1: Check Node.js
Write-Step 1 "Checking Node.js installation"
try {
    $nodeVersion = node --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Node.js is installed: $nodeVersion"
    } else {
        throw "Node.js not found"
    }
} catch {
    Write-Error "Node.js is not installed!"
    Write-Host ""
    Write-Host "Please download and install Node.js from: https://nodejs.org/" -ForegroundColor Yellow
    Write-Host "After installing Node.js, run this installer again." -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Step 2: Install dependencies
Write-Step 2 "Installing dependencies"
if (-not (Install-NodeDependencies)) {
    exit 1
}
Write-Host ""

# Step 3: Generate SSL certificates
Write-Step 3 "Setting up SSL certificates"
Install-SSLCertificates
Write-Host ""

# Step 4: Firewall configuration
if (-not $SkipFirewall) {
    Write-Step 4 "Configuring firewall"
    if (-not $Unattended) {
        $firewallChoice = Read-Host "Configure Windows Firewall rules for ports 3000 and 3443? (y/n)"
        if ($firewallChoice -eq 'y' -or $firewallChoice -eq 'Y') {
            Install-FirewallRules
        } else {
            Write-Warning "Firewall configuration skipped"
        }
    } else {
        Install-FirewallRules
    }
} else {
    Write-Warning "Firewall configuration skipped (parameter)"
}
Write-Host ""

# Step 5: Create service (optional)
if ($CreateService -and (Test-Administrator)) {
    Write-Step 5 "Creating Windows Service"
    # This would require additional service creation logic
    Write-Warning "Service creation feature coming soon"
    Write-Host ""
}

# Installation complete
$networkIP = Get-NetworkIP
Write-Host "=" * 60 -ForegroundColor Green
Write-Host "  Installation Complete!" -ForegroundColor Yellow
Write-Host "=" * 60 -ForegroundColor Green
Write-Host ""
Write-Host "Quick Start Options:" -ForegroundColor Cyan
Write-Host "  1. Run 'start-https.bat' for HTTPS server" -ForegroundColor White
Write-Host "  2. Run 'start-network.bat' for network access" -ForegroundColor White
Write-Host "  3. Run 'deploy-production.ps1' for service installation" -ForegroundColor White
Write-Host ""
Write-Host "Access URLs:" -ForegroundColor Cyan
Write-Host "  Local HTTPS:  " -NoNewline -ForegroundColor White
Write-Host "https://localhost:3443" -ForegroundColor Green
Write-Host "  Network HTTPS: " -NoNewline -ForegroundColor White
Write-Host "https://$networkIP:3443" -ForegroundColor Green
Write-Host "  Local HTTP:   " -NoNewline -ForegroundColor White
Write-Host "http://localhost:3000" -ForegroundColor Green
Write-Host ""
Write-Host "NOTE: " -NoNewline -ForegroundColor Yellow
Write-Host "You may need to accept the self-signed certificate warning in your browser."
Write-Host ""

if (-not $Unattended) {
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
'@

$psInstallerPath = Join-Path $outputDir "INSTALL-COMPLETE.ps1"
$psInstallerContent | Set-Content $psInstallerPath -Encoding UTF8
Write-Host "  ✓ Created: INSTALL-COMPLETE.ps1" -ForegroundColor Green

# Create a README for the deployment package
$readmeContent = @"
# IT Ticketing System - Deployment Package

This package contains everything needed to install and run the IT Ticketing System on a Windows PC.

## Quick Installation

### Option 1: Simple Installation (Recommended)
1. Right-click on `INSTALL-COMPLETE.bat`
2. Select "Run as administrator" (recommended)
3. Follow the prompts

### Option 2: PowerShell Installation (Advanced)
1. Right-click on PowerShell and select "Run as administrator"
2. Navigate to this folder
3. Run: `.\INSTALL-COMPLETE.ps1`

### Option 3: Manual Installation
1. Install Node.js from https://nodejs.org/
2. Open Command Prompt in this folder
3. Run: `npm install`
4. Run: `node generate-cert.js`
5. Run: `node server.js`

## Starting the Application

After installation, you can start the server using:

- **HTTPS Mode**: Double-click `start-https.bat`
- **Network Mode**: Double-click `start-network.bat`
- **Production Mode**: Run `deploy-production.ps1` as administrator

## Access URLs

- **Local Access**: https://localhost:3443
- **Network Access**: https://[YOUR-IP-ADDRESS]:3443
- **HTTP Access**: http://localhost:3000

## SharePoint Integration

To embed in SharePoint:
1. Start the server in network mode
2. Use the network HTTPS URL in SharePoint
3. You may need to accept the certificate warning

## Troubleshooting

### Certificate Warnings
The system uses self-signed certificates. Your browser will show a security warning. Click "Advanced" and "Proceed to localhost" to continue.

### Firewall Issues
If you can't access the server from other computers:
1. Run the installer as administrator
2. Choose to configure firewall rules
3. Or manually allow ports 3000 and 3443 in Windows Firewall

### Node.js Not Found
Download and install Node.js from https://nodejs.org/

## Support

For issues or questions, refer to the included documentation files:
- `HTTPS_SETUP.md` - HTTPS configuration details
- `DOMAIN_SETUP.md` - Domain and network setup
- `README.md` - General application information

## Files Included

- `server.js` - Main application server
- `package.json` - Node.js dependencies
- `generate-cert.js` - SSL certificate generator
- `public/` - Web interface files
- `certs/` - SSL certificates directory
- Installation scripts and documentation
"@

$deployReadmePath = Join-Path $outputDir "DEPLOYMENT-README.md"
$readmeContent | Set-Content $deployReadmePath -Encoding UTF8
Write-Host "  ✓ Created: DEPLOYMENT-README.md" -ForegroundColor Green

# Create a version info file
$versionInfo = @"
IT Ticketing System - Deployment Package
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Source: $sourceDir
Package: $deploymentName

Included Components:
- Core application files
- SSL certificate generation
- Installation scripts (Batch and PowerShell)
- Documentation and setup guides
- Startup scripts for different modes

System Requirements:
- Windows 7/8/10/11
- Node.js 14.x or higher
- Administrator privileges (recommended)

Installation Methods:
1. INSTALL-COMPLETE.bat - Simple batch installer
2. INSTALL-COMPLETE.ps1 - Advanced PowerShell installer
3. Manual installation using included scripts

For complete setup instructions, see DEPLOYMENT-README.md
"@

$versionPath = Join-Path $outputDir "VERSION-INFO.txt"
$versionInfo | Set-Content $versionPath -Encoding UTF8
Write-Host "  ✓ Created: VERSION-INFO.txt" -ForegroundColor Green

Write-Host ""
Write-Host "Creating deployment archive..." -ForegroundColor Yellow

# Create a ZIP file if possible
try {
    $zipPath = "$outputDir.zip"
    Compress-Archive -Path "$outputDir\*" -DestinationPath $zipPath -Force
    Write-Success "Created ZIP archive: $zipPath"
} catch {
    Write-Warning "Could not create ZIP archive: $($_.Exception.Message)"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Deployment Package Created!" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Package Location: " -NoNewline -ForegroundColor White
Write-Host $outputDir -ForegroundColor Green
Write-Host ""
Write-Host "To deploy on another PC:" -ForegroundColor Cyan
Write-Host "1. Copy the entire folder to the target PC" -ForegroundColor White
Write-Host "2. Run INSTALL-COMPLETE.bat as administrator" -ForegroundColor White
Write-Host "3. Follow the installation prompts" -ForegroundColor White
Write-Host ""
Write-Host "Package includes:" -ForegroundColor Cyan
Write-Host "  ✓ Complete application files" -ForegroundColor Green
Write-Host "  ✓ Automated installers" -ForegroundColor Green
Write-Host "  ✓ SSL certificate generation" -ForegroundColor Green
Write-Host "  ✓ Firewall configuration" -ForegroundColor Green
Write-Host "  ✓ Startup scripts" -ForegroundColor Green
Write-Host "  ✓ Complete documentation" -ForegroundColor Green
Write-Host ""

# Open the deployment folder
if (-not $env:CI) {
    $openChoice = Read-Host "Open deployment folder now? (y/n)"
    if ($openChoice -eq 'y' -or $openChoice -eq 'Y') {
        Start-Process explorer.exe $outputDir
    }
}

Write-Host "Deployment package creation complete!" -ForegroundColor Green
