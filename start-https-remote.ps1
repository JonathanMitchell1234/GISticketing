# Remote HTTPS Server Startup Script
# Run this script to start the HTTPS server on the remote machine

Write-Host "🚀 Starting HTTPS Server for Vercel Integration" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Check if we're on the correct machine
$currentIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "192.168.21.*" }).IPAddress
if ($currentIP -eq "192.168.21.94") {
    Write-Host "✅ Detected server machine IP: $currentIP" -ForegroundColor Green
    
    # Navigate to the project directory
    Set-Location "C:\Users\JMITCHELL\Desktop\TicketingSystem"
    
    # Check if certificates exist
    if (Test-Path "certs\server.crt" -and Test-Path "certs\server.key") {
        Write-Host "✅ SSL certificates found" -ForegroundColor Green
        
        # Start the HTTPS server
        Write-Host "🔒 Starting HTTPS server on port 3443..." -ForegroundColor Yellow
        Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
        Write-Host "==========================================" -ForegroundColor Green
        
        # Set environment variables for HTTPS
        $env:HTTPS_PORT = "3443"
        $env:HTTP_PORT = "3000"
        
        # Start the server
        node server.js
        
    } else {
        Write-Host "❌ SSL certificates not found!" -ForegroundColor Red
        Write-Host "Running certificate generation..." -ForegroundColor Yellow
        
        # Generate certificates
        node generate-cert.js
        
        if (Test-Path "certs\server.crt") {
            Write-Host "✅ Certificates generated successfully" -ForegroundColor Green
            Write-Host "🔒 Starting HTTPS server..." -ForegroundColor Yellow
            
            $env:HTTPS_PORT = "3443"
            $env:HTTP_PORT = "3000"
            node server.js
        } else {
            Write-Host "❌ Failed to generate certificates" -ForegroundColor Red
            exit 1
        }
    }
} else {
    Write-Host "⚠️  This script should be run on the server machine (192.168.21.94)" -ForegroundColor Yellow
    Write-Host "Current machine IP: $currentIP" -ForegroundColor Yellow
    Write-Host "" 
    Write-Host "To start the HTTPS server remotely:" -ForegroundColor Cyan
    Write-Host "1. Remote Desktop to 192.168.21.94" -ForegroundColor White
    Write-Host "2. Open PowerShell as Administrator" -ForegroundColor White
    Write-Host "3. Run: cd 'C:\Users\JMITCHELL\Desktop\TicketingSystem'" -ForegroundColor White
    Write-Host "4. Run: .\start-https-remote.ps1" -ForegroundColor White
    Write-Host "" 
    Write-Host "Or use the batch file:" -ForegroundColor Cyan
    Write-Host "Double-click: start-https.bat" -ForegroundColor White
}
