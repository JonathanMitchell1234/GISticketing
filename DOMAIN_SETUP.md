# Domain Setup Guide - helpdesk.local

This guide explains how to access your IT Ticketing System using the friendly domain name `helpdesk.local` instead of IP addresses.

## Overview

Your IT Ticketing System now supports mDNS (Multicast DNS) which allows devices on your local network to access the application using the domain name `helpdesk.local:3000` instead of remembering IP addresses.

## Quick Start

### For Windows (Server Machine)
1. **Easy Start**: Double-click `start-helpdesk-local.bat`
   - This automatically configures mDNS and starts the server
   - Look for the message "✓ mDNS service published as 'helpdesk.local'"

2. **Manual Start**: 
   ```powershell
   npm start
   ```

### Accessing the System

Once the server is running, you can access it from any device on your network:

- **Recommended**: `http://helpdesk.local:3000`
- **Backup**: `http://[server-ip]:3000` (use the IP shown in console)
- **Local only**: `http://localhost:3000` (server machine only)

## Client Device Setup

### Windows Clients
**Option 1: Install iTunes** (Recommended)
- Download and install iTunes from Apple
- iTunes includes Bonjour service for .local domain support
- No additional configuration needed

**Option 2: Bonjour Print Services**
- Download "Bonjour Print Services for Windows" from Apple's website
- Smaller download than iTunes, provides just the Bonjour service
- Install and restart your computer

### macOS Clients
- ✅ Built-in support for .local domains
- No additional software needed

### iOS/Android Devices
- ✅ Most modern browsers support .local domains
- Works with Safari, Chrome, Firefox, Edge
- No additional apps needed

### Linux Clients
```bash
# Install Avahi daemon for mDNS support
sudo apt-get install avahi-daemon  # Ubuntu/Debian
sudo yum install avahi             # CentOS/RHEL
```

## Network Requirements

### Firewall Configuration
The setup script automatically attempts to create firewall rules, but you may need to manually configure:

**Windows Defender Firewall:**
1. Open Windows Defender Firewall
2. Click "Allow an app through firewall"
3. Add Node.js or allow port 3000
4. Enable for both Private and Public networks

### Router Configuration
- Most home/office routers support mDNS by default
- Corporate networks may block multicast traffic
- If .local doesn't work, use IP address as fallback

## Troubleshooting

### Common Issues

**1. "helpdesk.local" doesn't resolve**
- Wait 30-60 seconds after starting the server
- Check that Bonjour service is installed on client device
- Try refreshing the browser page
- Use IP address as temporary workaround

**2. Connection refused**
- Check Windows Firewall settings
- Ensure port 3000 is open
- Verify the server is running (check console output)

**3. Slow initial connection**
- First connection may take longer as mDNS propagates
- Subsequent connections should be faster
- Consider bookmarking the working URL

### Verification Steps

**1. Test mDNS Service:**
```powershell
node test-mdns.js
```

**2. Check Network Connectivity:**
```powershell
ping helpdesk.local
```

**3. Test Direct Port Access:**
```powershell
telnet [server-ip] 3000
```

### Windows-Specific Diagnostics

**Check Bonjour Service:**
```powershell
Get-Service -Name "Bonjour Service"
```

**Check Firewall Rules:**
```powershell
Get-NetFirewallRule -DisplayName "*Node*"
```

**Find Local IP Address:**
```powershell
ipconfig | findstr IPv4
```

## Alternative Solutions

If mDNS doesn't work in your environment:

### 1. Static Host File Entry
Add to `C:\Windows\System32\drivers\etc\hosts`:
```
[server-ip] helpdesk.local
```

### 2. DNS Server Configuration
Configure your local DNS server to resolve helpdesk.local to the server IP.

### 3. Use IP Addresses
Continue using `http://[server-ip]:3000` as a reliable fallback.

## Security Considerations

- mDNS only works on local networks (not internet-accessible)
- .local domains are automatically resolved to local IP addresses
- Firewall rules only allow local network access
- HTTPS is not configured by default (suitable for internal use)

## Advanced Configuration

### Custom Domain Name
To change from "helpdesk.local" to another name:

1. Edit `server.js`:
```javascript
bonjour.publish({
    name: 'IT Helpdesk System',
    type: 'http',
    port: PORT,
    host: 'your-custom-name.local'  // Change this
});
```

2. Update documentation and scripts accordingly

### Multiple Instances
To run multiple instances:
- Use different ports (3000, 3001, 3002, etc.)
- Use different hostnames (helpdesk1.local, helpdesk2.local, etc.)

## Benefits of .local Domain

✅ **Easy to remember**: `helpdesk.local` vs `192.168.1.100`
✅ **Works across devices**: Same URL for phones, laptops, tablets
✅ **Dynamic IP support**: Works even if server IP changes
✅ **Professional appearance**: Looks more polished to users
✅ **Bookmark friendly**: Users can bookmark the friendly name

## Support

If you continue having issues with .local domain resolution:
1. Use the IP address method as a reliable fallback
2. Consider setting up a local DNS server
3. Check with your network administrator about mDNS support
4. Verify antivirus software isn't blocking mDNS traffic

The ticketing system will work perfectly with IP addresses if .local domains aren't suitable for your environment.