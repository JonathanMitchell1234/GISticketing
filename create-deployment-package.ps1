# IT Helpdesk System - Deployment Package Creator
# This script creates a deployment package for installing on other Windows PCs

param(
    [string]$OutputPath = ".\IT-Helpdesk-Deployment",
    [switch]$IncludeNodeModules,
    [switch]$CreateZip
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Creating Deployment Package" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create output directory
if (Test-Path $OutputPath) {
    Remove-Item $OutputPath -Recurse -Force
}
New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null

Write-Host "Creating deployment package at: $OutputPath" -ForegroundColor Yellow
Write-Host ""

# Files and directories to include
$filesToCopy = @(
    "server.js",
    "package.json",
    "generate-cert.js",
    "setup.bat",
    "setup.ps1",
    "deploy-production.ps1",
    "INSTALL.bat",
    "start-https.bat",
    "start-network.bat",
    "HTTPS_SETUP.md",
    "README.md",
    "public"
)

# Optional: include node_modules if requested
if ($IncludeNodeModules -and (Test-Path "node_modules")) {
    $filesToCopy += "node_modules"
    Write-Host "Including node_modules directory..." -ForegroundColor Yellow
}

# Copy files
foreach ($item in $filesToCopy) {
    if (Test-Path $item) {
        if (Test-Path $item -PathType Container) {
            # It's a directory
            Copy-Item $item -Destination $OutputPath -Recurse -Force
            Write-Host "✓ Copied directory: $item" -ForegroundColor Green
        } else {
            # It's a file
            Copy-Item $item -Destination $OutputPath -Force
            Write-Host "✓ Copied file: $item" -ForegroundColor Green
        }
    } else {
        Write-Host "⚠ Skipped (not found): $item" -ForegroundColor Yellow
    }
}

# Create deployment-specific files
Write-Host ""
Write-Host "Creating deployment-specific files..." -ForegroundColor Yellow

# Create a deployment README
$deploymentReadme = @"
# IT Helpdesk System - Deployment Package

This package contains everything needed to deploy the IT Helpdesk System on a Windows PC.

## Quick Start

1. **Extract this package** to a folder on the target PC (e.g., C:\IT-Helpdesk)
2. **Right-click on INSTALL.bat** and select "Run as administrator"
3. **Follow the installation prompts**
4. **Access the system** at https://localhost:3443

## Default Credentials

- Username: `admin`
- Password: `admin123`

**⚠️ IMPORTANT: Change the default password immediately after first login!**

## Installation Options

### Option 1: One-Click Install (Recommended)
- Double-click `INSTALL.bat`
- Follow the prompts

### Option 2: Manual Setup
- Run `setup.ps1` in PowerShell
- Or run `setup.bat` from command prompt

### Option 3: Production Deployment
- Run `deploy-production.ps1` for production setup
- Includes firewall configuration and service setup

## System Requirements

- Windows 10/11 or Windows Server 2016+
- Internet connection (for downloading Node.js and dependencies)
- 2GB RAM minimum, 4GB recommended
- 500MB free disk space

## Ports Used

- HTTP: 3000
- HTTPS: 3443

Make sure these ports are not in use by other applications.

## Firewall Configuration

The installer will automatically configure Windows Firewall rules if run as administrator.
If not, you may need to manually allow:
- Inbound TCP port 3000 (HTTP)
- Inbound TCP port 3443 (HTTPS)

## Network Access

To access from other computers on the network:
- Use the server's IP address instead of localhost
- Example: https://192.168.1.100:3443

## SSL Certificate

A self-signed SSL certificate is automatically generated for HTTPS.
Your browser will show a security warning - this is normal for self-signed certificates.
Click "Advanced" → "Proceed to localhost" to continue.

## Troubleshooting

### Port Already in Use
If you get a "port already in use" error:
1. Check if another application is using ports 3000 or 3443
2. Stop the conflicting application or change ports in server.js

### Node.js Not Found
If Node.js is not detected:
1. Download from https://nodejs.org/
2. Install using the default options
3. Restart the installer

### Permission Errors
If you get permission errors:
1. Right-click the installer and select "Run as administrator"
2. Make sure the installation folder is writable

## Support

For issues and support, please refer to the documentation or contact your system administrator.

## Files Included

- `server.js` - Main server application
- `package.json` - Node.js dependencies
- `public/` - Web interface files
- `INSTALL.bat` - One-click installer
- `setup.ps1` - PowerShell setup script
- `deploy-production.ps1` - Production deployment script
- Various startup scripts and documentation

Package created on: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@

$deploymentReadme | Out-File -FilePath "$OutputPath\DEPLOYMENT-README.md" -Encoding UTF8
Write-Host "✓ Created deployment README" -ForegroundColor Green

# Create a quick start batch file
$quickStart = @"
@echo off
echo IT Helpdesk System - Quick Start
echo ================================
echo.
echo This will start the installation process.
echo.
echo Make sure you have:
echo - Administrator rights (recommended)
echo - Internet connection
echo.
echo Press any key to start installation...
pause >nul
echo.
call INSTALL.bat
"@

$quickStart | Out-File -FilePath "$OutputPath\QUICK-START.bat" -Encoding ASCII
Write-Host "✓ Created quick start script" -ForegroundColor Green

# Create version info file
$versionInfo = @"
IT Helpdesk System - Deployment Package
========================================

Package Version: 1.0.0
Created: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Platform: Windows
Node.js Required: 14.x or higher

Contents:
- Complete IT Helpdesk System
- Automated installer
- SSL certificate generation
- Production deployment scripts
- Documentation

For support and updates, visit:
https://github.com/your-repo/it-helpdesk-system
"@

$versionInfo | Out-File -FilePath "$OutputPath\VERSION.txt" -Encoding UTF8
Write-Host "✓ Created version info file" -ForegroundColor Green

# Create ZIP file if requested
if ($CreateZip) {
    Write-Host ""
    Write-Host "Creating ZIP archive..." -ForegroundColor Yellow
    
    $zipPath = "$OutputPath.zip"
    if (Test-Path $zipPath) {
        Remove-Item $zipPath -Force
    }
    
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($OutputPath, $zipPath)
    
    Write-Host "✓ Created ZIP archive: $zipPath" -ForegroundColor Green
    
    # Get file size
    $zipSize = [math]::Round((Get-Item $zipPath).Length / 1MB, 2)
    Write-Host "  Archive size: $zipSize MB" -ForegroundColor White
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Deployment Package Ready!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Package location: $OutputPath" -ForegroundColor Green
if ($CreateZip) {
    Write-Host "ZIP archive: $OutputPath.zip" -ForegroundColor Green
}
Write-Host ""
Write-Host "To deploy on another Windows PC:" -ForegroundColor Yellow
Write-Host "1. Copy the entire package to the target PC" -ForegroundColor White
Write-Host "2. Run INSTALL.bat as administrator" -ForegroundColor White
Write-Host "3. Follow the installation prompts" -ForegroundColor White
Write-Host ""
Write-Host "The deployment package includes:" -ForegroundColor Yellow

$packageContents = Get-ChildItem $OutputPath -Recurse | Where-Object { -not $_.PSIsContainer }
$totalSize = [math]::Round(($packageContents | Measure-Object -Property Length -Sum).Sum / 1MB, 2)

Write-Host "- $($packageContents.Count) files" -ForegroundColor White
Write-Host "- Total size: $totalSize MB" -ForegroundColor White
Write-Host "- Complete installer and setup scripts" -ForegroundColor White
Write-Host "- Documentation and troubleshooting guides" -ForegroundColor White

if (-not $IncludeNodeModules) {
    Write-Host ""
    Write-Host "Note: Node modules not included - will be downloaded during installation" -ForegroundColor Cyan
}

Write-Host ""
