# HTTPS Setup for SharePoint Integration

This document explains how to set up and use HTTPS with your IT Ticketing System for SharePoint embedding.

## ✅ What's Been Configured

### 1. SSL Certificate
- Self-signed certificate generated and stored in `certs/` folder
- Valid for `localhost`, `helpdesk.local`, and network IP addresses
- Certificate valid for 1 year from generation date

### 2. Server Configuration
- **HTTP Server**: Running on port 3000
- **HTTPS Server**: Running on port 3443
- Both servers run simultaneously
- Enhanced CORS configuration for cross-origin requests
- Cookie settings optimized for SharePoint embedding

### 3. Authentication Improvements
- **Dual Authentication**: Supports both cookies and Bearer tokens
- **Cross-Origin Compatible**: Works in SharePoint iframes
- **Token Storage**: Automatically stores tokens in localStorage
- **Fallback Support**: If cookies fail, uses Authorization headers

### 4. CORS Configuration
- Allows requests from SharePoint domains
- Supports network IP addresses
- Includes proper headers for iframe embedding
- Credentials support for cross-origin requests

## 🚀 How to Start the Server

### Option 1: Command Line
```powershell
cd "c:\Users\JMITCHELL\Desktop\TicketingSystem"
node server.js
```

### Option 2: Batch File
Double-click `start-https.bat` in the project folder

### Option 3: NPM Script
```powershell
npm run https
```

## 🌐 Access URLs

After starting the server, you can access the application at:

- **Local HTTPS**: https://localhost:3443
- **Network HTTPS**: https://192.168.21.40:3443
- **mDNS HTTPS**: https://helpdesk.local:3443

## 📋 SharePoint Integration Steps

### 1. Accept the Certificate
1. Open https://localhost:3443 or your network IP
2. Click "Advanced" when you see the security warning
3. Click "Proceed to localhost (unsafe)" or similar
4. This only needs to be done once per browser

### 2. Embed in SharePoint
1. Add a "Web Part" to your SharePoint page
2. Choose "Embed" or "Iframe" web part
3. Use your HTTPS URL: `https://YOUR_IP:3443`
4. The app will work cross-origin with proper authentication

### 3. Network Access
For other devices on your network:
- Replace `localhost` with your actual IP address
- Ensure Windows Firewall allows port 3443
- Use the HTTPS URL for secure embedding

## 🔒 Security Features

### Authentication
- JWT tokens with 24-hour expiration
- Secure cookie settings for HTTPS
- Bearer token fallback for cross-origin scenarios
- Automatic token refresh handling

### CORS Policy
- Specific origin allowlist
- Supports credentials for authenticated requests
- SharePoint-compatible headers
- Network IP address support

### SSL/TLS
- Self-signed certificate for development
- Supports modern TLS protocols
- Valid SAN (Subject Alternative Names) for multiple domains

## 🛠️ Troubleshooting

### "Connection is not secure" Warning
This is expected with self-signed certificates. Click "Advanced" → "Proceed" to continue.

### CORS Errors
The server automatically allows your network IP. If you get CORS errors:
1. Check the server logs for "CORS allowed origin" messages
2. Verify you're using the HTTPS URL
3. Clear browser cache and cookies

### Authentication Issues
If login fails:
1. Check browser Developer Tools → Network tab
2. Verify the server shows "User authenticated" messages
3. Clear localStorage and cookies, then try again

### SharePoint Embedding Issues
1. Ensure you're using HTTPS (not HTTP)
2. Accept the certificate warning first in a regular browser tab
3. Use the network IP address rather than localhost
4. Check that port 3443 is not blocked by firewall

## 📁 Generated Files

The setup creates these files:
- `certs/server.key` - Private key
- `certs/server.crt` - SSL certificate
- `start-https.bat` - Quick start script

## 🔄 Regenerating Certificates

If you need to regenerate the SSL certificate:
```powershell
npm run generate-cert
```

## 📞 Support

Default admin credentials:
- **Username**: admin
- **Password**: admin123

The system logs authentication and CORS events to help with troubleshooting.

## 🎯 For Production

⚠️ **Important**: This setup uses self-signed certificates suitable for development and internal use only. For production environments:

1. Obtain proper SSL certificates from a trusted CA
2. Update server.js to use production certificates
3. Configure proper environment variables
4. Set up proper firewall rules
5. Use a reverse proxy like nginx for production deployment
