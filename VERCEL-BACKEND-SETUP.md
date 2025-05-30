# Vercel Frontend to Remote Backend Setup Guide

## Overview
This guide helps you configure your Vercel-hosted frontend at `https://graphicinfohelpdesk.vercel.app/` to communicate with your backend server hosted at `https://192.168.21.94:3443/`.

## Current Status ✅
- **Backend Server**: ✅ Running and accessible at `192.168.21.94:3443`
- **CORS Configuration**: ✅ Properly configured to allow Vercel domain
- **Authentication**: ✅ Working correctly (returns 401 for unauthenticated requests)
- **SSL/HTTPS**: ✅ Backend is serving HTTPS correctly

## Configuration Complete! 🎉

Your setup is **ready to use**. The backend server is accessible and has the correct CORS configuration to allow your Vercel frontend to connect.

### 1. Find Your Local IP Address
```powershell
ipconfig
```
Look for your network adapter's IPv4 address (e.g., `192.168.1.100`)

### 2. Update Frontend Configuration
In your Vercel frontend code, replace `YOUR_LOCAL_IP` in `cloud-frontend-config.js` with your actual IP address.

### 3. Network Setup

#### Option A: Direct Network Access (Recommended)
- **Firewall**: Open ports 3000 (HTTP) and 3443 (HTTPS) in Windows Firewall
- **Router**: Ensure your local server is accessible from your network
- **Backend URL**: Use `https://YOUR_LOCAL_IP:3443` or `http://YOUR_LOCAL_IP:3000`

#### Option B: Tunnel Service (If behind firewall)
If your local network isn't accessible from the internet, use a tunneling service:

```powershell
# Install ngrok (if not already installed)
# Download from https://ngrok.com/download

# Tunnel your local server
ngrok http 3000  # For HTTP
# or
ngrok http 3443  # For HTTPS
```

### 4. Test Your Setup

1. **Start your local backend**:
   ```powershell
   cd "c:\Users\JMITCHELL\Desktop\TicketingSystem"
   node server.js
   ```

2. **Test CORS configuration**:
   ```powershell
   node test-vercel-cors.js
   ```

3. **Check network connectivity** from another device on your network:
   ```
   http://YOUR_LOCAL_IP:3000
   ```

### 5. Frontend Code Example

```javascript
// In your Vercel frontend, use the helper function:
import { makeApiRequest } from './cloud-frontend-config.js';

// Login example
const login = async (username, password) => {
  try {
    const { data } = await makeApiRequest('/api/login', {
      method: 'POST',
      body: JSON.stringify({ username, password })
    });
    
    console.log('Login successful:', data);
    return data;
  } catch (error) {
    console.error('Login failed:', error);
    throw error;
  }
};

// Fetch tickets example
const getTickets = async () => {
  try {
    const { data } = await makeApiRequest('/api/tickets');
    return data;
  } catch (error) {
    console.error('Failed to fetch tickets:', error);
    throw error;
  }
};
```

## Troubleshooting

### CORS Issues
- ✅ Already resolved - Vercel domain is in allowed origins
- If you get CORS errors, check that your local server is running

### Connection Issues
- **Can't reach server**: Check firewall settings and network connectivity
- **SSL Errors**: Use HTTP instead of HTTPS, or set up proper SSL certificates
- **Authentication Issues**: Check that tokens are being stored and sent correctly

### Firewall Configuration (Windows)
1. Open Windows Defender Firewall
2. Click "Advanced settings"
3. Create new Inbound Rules for:
   - Port 3000 (TCP)
   - Port 3443 (TCP)
4. Allow the connection

### Router Configuration (if needed)
If your Vercel app can't reach your local server:
1. Log into your router admin panel
2. Set up port forwarding for ports 3000 and 3443 to your local machine's IP
3. Use your public IP address instead of local IP

## Security Considerations

1. **Temporary Setup**: This configuration exposes your local server to the internet
2. **Firewall Rules**: Only open ports when needed, close them when done
3. **Authentication**: Always use strong passwords and secure tokens
4. **SSL**: Use HTTPS when possible for encrypted communication

## Quick Start Commands

```powershell
# Navigate to project directory
cd "c:\Users\JMITCHELL\Desktop\TicketingSystem"

# Test CORS configuration
node test-vercel-cors.js

# Start the server
node server.js

# Check your local IP
ipconfig | findstr IPv4
```

## Support

If you encounter issues:
1. Check the server console logs for CORS messages
2. Verify your local IP address is correct
3. Test connectivity from another device on your network
4. Consider using ngrok for testing if network issues persist
