# IT Ticketing System - Master Setup Guide

This guide provides complete instructions for deploying the IT Ticketing System on any Windows PC, including automated scripts for easy installation and SharePoint embedding.

## 📋 Quick Start (Recommended)

### Option 1: One-Click Installation
1. **Download/Copy** the complete project folder to your PC
2. **Right-click** on `INSTALL.bat` and select **"Run as administrator"**
3. **Follow the prompts** - the installer will handle everything automatically
4. **Start the server** by double-clicking `start-https.bat`
5. **Access** the system at `https://localhost:3443`

### Option 2: Transfer Kit Installation
1. **Create transfer kit** - Run `create-transfer-kit.bat` on the source PC
2. **Copy the kit** to the target PC (USB drive, email, network share)
3. **Run** `QUICK-INSTALL.bat` as administrator on the target PC
4. **Start** with `start-https.bat`

## 🎯 Installation Methods

### Method A: Automated Batch Installation
```batch
# Run as administrator
INSTALL.bat
```
**Features:**
- Checks Node.js installation
- Installs dependencies automatically
- Generates SSL certificates
- Configures Windows Firewall
- Creates startup shortcuts

### Method B: PowerShell Installation (Advanced)
```powershell
# Run as administrator
.\setup.ps1
```
**Features:**
- Enhanced error handling
- Colored output and progress indicators
- Optional service installation
- Network configuration detection

### Method C: Production Deployment
```powershell
# Run as administrator
.\deploy-production.ps1
```
**Features:**
- Windows Service installation
- Automatic startup configuration
- Advanced firewall rules
- Logging and monitoring setup

### Method D: Manual Installation
```batch
# Install Node.js from https://nodejs.org/
npm install
node generate-cert.js
node server.js
```

## 🔧 System Requirements

### Minimum Requirements
- **OS:** Windows 7/8/10/11 (32-bit or 64-bit)
- **RAM:** 512 MB available
- **Storage:** 100 MB free space
- **Network:** TCP ports 3000 and 3443 available

### Required Software
- **Node.js 14.x or higher** (download from https://nodejs.org/)
- **PowerShell 5.0+** (included in Windows 10/11)

### Recommended
- **Administrator privileges** for full installation features
- **Windows Defender Firewall** access for network configuration

## 🌐 Access Methods

### Local Access
- **HTTP:** `http://localhost:3000`
- **HTTPS:** `https://localhost:3443` (recommended)

### Network Access
- **Find your IP:** Run `ipconfig` in Command Prompt
- **Access URL:** `https://[YOUR-IP]:3443`
- **Example:** `https://192.168.1.100:3443`

### SharePoint Embedding
1. Start server in network mode: `start-network.bat`
2. Use HTTPS URL in SharePoint: `https://[PC-IP]:3443`
3. Accept certificate warning when prompted

## 🔐 SSL Certificate Setup

### Automatic Generation (Recommended)
The installation scripts automatically generate self-signed SSL certificates. No manual action required.

### Manual Generation
```batch
node generate-cert.js
```
This creates:
- `certs/server.key` - Private key
- `certs/server.crt` - SSL certificate

### Certificate Details
- **Valid for:** localhost, 127.0.0.1, and your network IP
- **Duration:** 365 days
- **Type:** Self-signed (browser will show warning)

## 🚀 Starting the Server

### Standard Startup Scripts
- **`start-https.bat`** - HTTPS mode (port 3443)
- **`start-network.bat`** - Network mode with CORS enabled
- **`start-helpdesk-local.bat`** - Local-only mode

### Manual Startup
```batch
# Basic startup
node server.js

# Network mode
set NETWORK_MODE=true
node server.js

# Debug mode
set DEBUG=true
node server.js
```

### Service Mode (Production)
```powershell
# Install as Windows Service
.\deploy-production.ps1

# Control service
net start "IT Ticketing System"
net stop "IT Ticketing System"
```

## 🔥 Firewall Configuration

### Automatic Configuration
The installers can automatically configure Windows Firewall rules:
- **Port 3000:** HTTP access
- **Port 3443:** HTTPS access

### Manual Configuration
1. Open **Windows Defender Firewall**
2. Click **"Allow an app or feature"**
3. Click **"Allow another app"** → Browse to `node.exe`
4. Or create specific port rules for 3000 and 3443

### Corporate Firewalls
If behind a corporate firewall:
1. Request ports 3000 and 3443 to be opened
2. Provide your PC's IP address to IT department
3. Consider using production deployment with proper certificates

## 📦 Deployment Scripts Overview

| Script | Purpose | Requirements |
|--------|---------|--------------|
| `INSTALL.bat` | Complete one-click installation | Admin privileges recommended |
| `setup.ps1` | PowerShell-based setup with options | PowerShell execution policy |
| `deploy-production.ps1` | Enterprise deployment with service | Admin privileges required |
| `create-transfer-kit.bat` | Creates portable installation | Source system access |
| `create-full-deployment.ps1` | Advanced deployment package | PowerShell 5.0+ |
| `validate-deployment.ps1` | Tests installation completeness | None |

## 🛠️ Troubleshooting

### Common Issues

#### "Node.js not found"
**Solution:** Download and install Node.js from https://nodejs.org/

#### "Certificate warnings in browser"
**Solution:** 
1. Click **"Advanced"** in the browser warning
2. Click **"Proceed to localhost (unsafe)"**
3. This is normal for self-signed certificates

#### "Cannot access from other computers"
**Solutions:**
1. Run installation as administrator
2. Allow firewall rules when prompted
3. Use `start-network.bat` instead of `start-https.bat`
4. Check Windows Firewall settings manually

#### "Port already in use"
**Solutions:**
1. Close other applications using ports 3000/3443
2. Restart the computer
3. Use Task Manager to find and close conflicting processes

#### "Permission denied errors"
**Solution:** Run installation as administrator

### Diagnostic Tools

#### Validate Installation
```powershell
.\validate-deployment.ps1
```
Tests all components and provides detailed status.

#### Network Test
```powershell
.\validate-deployment.ps1 -NetworkTest
```
Tests network connectivity and firewall configuration.

#### Auto-Repair
```powershell
.\validate-deployment.ps1 -FixIssues
```
Attempts to automatically fix common problems.

## 🔄 Updating and Maintenance

### Update Process
1. Stop the running server
2. Replace files with new version
3. Run `npm install` to update dependencies
4. Restart the server

### Backup Important Files
- `ticketing.db` - Database with all tickets and users
- `certs/` - SSL certificates (if customized)
- `.env` - Environment configuration (if customized)

### Maintenance Commands
```batch
# Update dependencies
npm update

# Regenerate certificates (yearly)
node generate-cert.js

# Clear database (CAUTION: deletes all data)
del ticketing.db
```

## 🏢 Enterprise Deployment

### Multiple PC Installation
1. Use `create-full-deployment.ps1` to create deployment package
2. Distribute package via network share or media
3. Run automated installer on each PC
4. Configure network access as needed

### Centralized Management
Consider using:
- Group Policy for firewall configuration
- Network shares for deployment packages
- PowerShell remoting for bulk installation

### Security Considerations
- Use proper certificates for production environments
- Configure appropriate firewall rules
- Consider VPN access for remote users
- Regular security updates for Node.js

## 📞 Support and Documentation

### Included Documentation
- `README.md` - Basic application information
- `HTTPS_SETUP.md` - Detailed HTTPS configuration
- `DOMAIN_SETUP.md` - Domain and network setup
- `DEPLOYMENT-README.md` - Deployment-specific instructions
- `TRANSFER-INSTRUCTIONS.md` - Transfer kit usage

### Getting Help
1. Run `validate-deployment.ps1` for diagnostic information
2. Check the browser console for JavaScript errors
3. Review Node.js console output for server errors
4. Verify firewall and network settings

### Log Files
- Server console output shows real-time status
- Browser developer tools show client-side issues
- Windows Event Viewer for service-related problems

---

## 🎉 Success Indicators

Your installation is successful when:
- ✅ Browser loads `https://localhost:3443` without connection errors
- ✅ Login page appears correctly
- ✅ Can create user accounts and tickets
- ✅ Network access works from other PCs (if needed)
- ✅ No critical errors in console output

**Ready to go!** Your IT Ticketing System is now ready for use and SharePoint embedding.
