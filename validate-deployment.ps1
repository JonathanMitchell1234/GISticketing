# IT Ticketing System - Deployment Validator
# Tests if the system is properly installed and working

param(
    [switch]$Detailed,
    [switch]$NetworkTest,
    [switch]$FixIssues
)

$Host.UI.RawUI.WindowTitle = "IT Ticketing System - Deployment Validator"
Clear-Host

function Write-TestHeader {
    param($Title)
    Write-Host ""
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Yellow
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host ""
}

function Write-Test {
    param($TestName)
    Write-Host "[TEST] $TestName" -ForegroundColor Cyan
}

function Write-Pass {
    param($Message)
    Write-Host "  ✓ PASS: $Message" -ForegroundColor Green
}

function Write-Fail {
    param($Message)
    Write-Host "  ✗ FAIL: $Message" -ForegroundColor Red
}

function Write-Warning {
    param($Message)
    Write-Host "  ⚠ WARN: $Message" -ForegroundColor Yellow
}

function Write-Info {
    param($Message)
    Write-Host "  ℹ INFO: $Message" -ForegroundColor Blue
}

function Test-NodeJS {
    Write-Test "Node.js Installation"
    try {
        $nodeVersion = node --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Pass "Node.js is installed: $nodeVersion"
            
            # Check if version is sufficient
            $versionNumber = $nodeVersion -replace 'v', ''
            $majorVersion = [int]($versionNumber.Split('.')[0])
            if ($majorVersion -ge 14) {
                Write-Pass "Node.js version is sufficient (>= 14.x)"
            } else {
                Write-Warning "Node.js version may be too old (< 14.x)"
            }
            return $true
        } else {
            Write-Fail "Node.js is not installed or not in PATH"
            return $false
        }
    } catch {
        Write-Fail "Error checking Node.js: $($_.Exception.Message)"
        return $false
    }
}

function Test-ProjectFiles {
    Write-Test "Project Files"
    $requiredFiles = @(
        "server.js",
        "package.json",
        "generate-cert.js"
    )
    
    $missingFiles = @()
    foreach ($file in $requiredFiles) {
        if (Test-Path $file) {
            Write-Pass "$file exists"
        } else {
            Write-Fail "$file is missing"
            $missingFiles += $file
        }
    }
    
    # Check optional but important files
    $optionalFiles = @(
        "public/index.html",
        "public/script.js",
        "public/styles.css",
        "certs/server.crt",
        "certs/server.key"
    )
    
    foreach ($file in $optionalFiles) {
        if (Test-Path $file) {
            Write-Pass "$file exists"
        } else {
            Write-Warning "$file is missing (may need generation)"
        }
    }
    
    return $missingFiles.Count -eq 0
}

function Test-Dependencies {
    Write-Test "Node.js Dependencies"
    if (Test-Path "package.json") {
        if (Test-Path "node_modules") {
            Write-Pass "node_modules directory exists"
            
            # Check for key dependencies
            $keyDeps = @("express", "sqlite3", "bcryptjs", "jsonwebtoken", "cors")
            foreach ($dep in $keyDeps) {
                if (Test-Path "node_modules/$dep") {
                    Write-Pass "$dep is installed"
                } else {
                    Write-Fail "$dep is missing"
                }
            }
            return $true
        } else {
            Write-Fail "node_modules directory not found - run 'npm install'"
            return $false
        }
    } else {
        Write-Fail "package.json not found"
        return $false
    }
}

function Test-Certificates {
    Write-Test "SSL Certificates"
    if (Test-Path "certs/server.crt" -and Test-Path "certs/server.key") {
        Write-Pass "SSL certificate files exist"
        
        # Check certificate validity
        try {
            $certContent = Get-Content "certs/server.crt" -Raw
            if ($certContent -match "BEGIN CERTIFICATE" -and $certContent -match "END CERTIFICATE") {
                Write-Pass "Certificate file format appears valid"
                return $true
            } else {
                Write-Warning "Certificate file format may be invalid"
                return $false
            }
        } catch {
            Write-Warning "Could not validate certificate format"
            return $false
        }
    } else {
        Write-Fail "SSL certificate files missing - run 'node generate-cert.js'"
        return $false
    }
}

function Test-DatabaseAccess {
    Write-Test "Database Access"
    if (Test-Path "ticketing.db") {
        Write-Pass "Database file exists"
        # Could add more sophisticated database testing here
        return $true
    } else {
        Write-Info "Database file will be created on first run"
        return $true
    }
}

function Test-PortAvailability {
    Write-Test "Port Availability"
    $ports = @(3000, 3443)
    $allAvailable = $true
    
    foreach ($port in $ports) {
        try {
            $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $port)
            $listener.Start()
            $listener.Stop()
            Write-Pass "Port $port is available"
        } catch {
            Write-Fail "Port $port is in use or blocked"
            $allAvailable = $false
        }
    }
    
    return $allAvailable
}

function Test-FirewallRules {
    Write-Test "Windows Firewall Rules"
    try {
        $rules = netsh advfirewall firewall show rule name="IT Ticketing HTTP" 2>$null
        if ($rules -match "IT Ticketing HTTP") {
            Write-Pass "HTTP firewall rule exists"
        } else {
            Write-Warning "HTTP firewall rule not found"
        }
        
        $rules = netsh advfirewall firewall show rule name="IT Ticketing HTTPS" 2>$null
        if ($rules -match "IT Ticketing HTTPS") {
            Write-Pass "HTTPS firewall rule exists"
        } else {
            Write-Warning "HTTPS firewall rule not found"
        }
    } catch {
        Write-Warning "Could not check firewall rules"
    }
    
    return $true # Non-critical for basic functionality
}

function Test-ServerStart {
    Write-Test "Server Startup Test"
    
    if (-not (Test-Path "server.js")) {
        Write-Fail "server.js not found"
        return $false
    }
    
    try {
        Write-Info "Starting server in test mode..."
        $process = Start-Process -FilePath "node" -ArgumentList "server.js" -PassThru -WindowStyle Hidden
        
        Start-Sleep -Seconds 3
        
        if (-not $process.HasExited) {
            Write-Pass "Server started successfully"
            
            # Test HTTP endpoint
            try {
                $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 5 -UseBasicParsing
                if ($response.StatusCode -eq 200) {
                    Write-Pass "HTTP endpoint responding"
                } else {
                    Write-Warning "HTTP endpoint returned status: $($response.StatusCode)"
                }
            } catch {
                Write-Warning "HTTP endpoint test failed: $($_.Exception.Message)"
            }
            
            # Test HTTPS endpoint (ignore certificate errors)
            try {
                add-type @"
                    using System.Net;
                    using System.Security.Cryptography.X509Certificates;
                    public class TrustAllCertsPolicy : ICertificatePolicy {
                        public bool CheckValidationResult(
                            ServicePoint srvPoint, X509Certificate certificate,
                            WebRequest request, int certificateProblem) {
                            return true;
                        }
                    }
"@
                [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
                
                $response = Invoke-WebRequest -Uri "https://localhost:3443" -TimeoutSec 5 -UseBasicParsing
                if ($response.StatusCode -eq 200) {
                    Write-Pass "HTTPS endpoint responding"
                } else {
                    Write-Warning "HTTPS endpoint returned status: $($response.StatusCode)"
                }
            } catch {
                Write-Warning "HTTPS endpoint test failed: $($_.Exception.Message)"
            }
            
            # Stop the test server
            $process.Kill()
            Write-Info "Test server stopped"
            return $true
        } else {
            Write-Fail "Server failed to start or exited immediately"
            return $false
        }
    } catch {
        Write-Fail "Error starting server: $($_.Exception.Message)"
        return $false
    }
}

function Test-NetworkConnectivity {
    if ($NetworkTest) {
        Write-Test "Network Connectivity"
        
        # Get local IP
        try {
            $networkAdapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up" -and $_.InterfaceDescription -notlike "*Loopback*"}
            $ipConfig = Get-NetIPAddress -InterfaceIndex $networkAdapter[0].InterfaceIndex -AddressFamily IPv4
            $localIP = $ipConfig.IPAddress
            
            Write-Pass "Local IP address: $localIP"
            Write-Info "Network access would be available at: https://$localIP:3443"
        } catch {
            Write-Warning "Could not determine local IP address"
        }
    }
}

function Repair-Installation {
    if ($FixIssues) {
        Write-TestHeader "Attempting to Fix Issues"
        
        # Install missing dependencies
        if (-not (Test-Path "node_modules")) {
            Write-Info "Installing Node.js dependencies..."
            npm install
        }
        
        # Generate missing certificates
        if (-not (Test-Path "certs/server.crt") -or -not (Test-Path "certs/server.key")) {
            Write-Info "Generating SSL certificates..."
            node generate-cert.js
        }
        
        # Create missing directories
        if (-not (Test-Path "certs")) {
            Write-Info "Creating certs directory..."
            New-Item -ItemType Directory -Path "certs" -Force
        }
        
        Write-Info "Repair attempts completed"
    }
}

function Show-Summary {
    param($Results)
    
    Write-TestHeader "Validation Summary"
    
    $passed = ($Results | Where-Object { $_ -eq $true }).Count
    $total = $Results.Count
    
    if ($passed -eq $total) {
        Write-Host "🎉 ALL TESTS PASSED! ($passed/$total)" -ForegroundColor Green
        Write-Host ""
        Write-Host "Your IT Ticketing System is ready to use!" -ForegroundColor Green
        Write-Host ""
        Write-Host "To start the server:" -ForegroundColor Cyan
        Write-Host "  • HTTPS Mode: start-https.bat" -ForegroundColor White
        Write-Host "  • Network Mode: start-network.bat" -ForegroundColor White
        Write-Host "  • Production: deploy-production.ps1" -ForegroundColor White
        Write-Host ""
        Write-Host "Access at: https://localhost:3443" -ForegroundColor Yellow
    } elseif ($passed -gt ($total / 2)) {
        Write-Host "⚠️  MOSTLY WORKING ($passed/$total tests passed)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "System should work but may have some issues." -ForegroundColor Yellow
        Write-Host "Run with -FixIssues parameter to attempt repairs." -ForegroundColor Yellow
    } else {
        Write-Host "❌ VALIDATION FAILED ($passed/$total tests passed)" -ForegroundColor Red
        Write-Host ""
        Write-Host "System needs attention before it will work properly." -ForegroundColor Red
        Write-Host "Run with -FixIssues parameter to attempt repairs." -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "For detailed help, see:" -ForegroundColor Gray
    Write-Host "  • DEPLOYMENT-README.md" -ForegroundColor Gray
    Write-Host "  • HTTPS_SETUP.md" -ForegroundColor Gray
    Write-Host "  • TRANSFER-INSTRUCTIONS.md" -ForegroundColor Gray
}

# Main validation process
Write-TestHeader "IT Ticketing System Deployment Validator"

Write-Host "Validating installation..." -ForegroundColor Yellow
Write-Host "Working Directory: $(Get-Location)" -ForegroundColor Gray
Write-Host ""

# Run repair first if requested
Repair-Installation

# Run all tests
$results = @()
$results += Test-NodeJS
$results += Test-ProjectFiles
$results += Test-Dependencies
$results += Test-Certificates
$results += Test-DatabaseAccess
$results += Test-PortAvailability
$results += Test-FirewallRules

# Only run server test if basic requirements are met
if ($results[0] -and $results[1] -and $results[2]) {
    $results += Test-ServerStart
} else {
    Write-Test "Server Startup Test"
    Write-Fail "Skipped due to missing prerequisites"
    $results += $false
}

# Run network test if requested
Test-NetworkConnectivity

# Show summary
Show-Summary $results

Write-Host ""
Write-Host "Validation completed." -ForegroundColor Gray
