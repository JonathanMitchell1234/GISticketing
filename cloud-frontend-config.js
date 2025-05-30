// Frontend Configuration for Cloud Deployment (Vercel)
// This file contains the configuration for connecting your Vercel-hosted frontend
// to your local backend server

const FRONTEND_CONFIG = {
    // Your backend server configuration
    // Backend is hosted at 192.168.21.94
    LOCAL_BACKEND: {
        // For HTTPS (recommended if you have SSL certificates)
        HTTPS_URL: 'https://192.168.21.94:3443',
        
        // For HTTP (fallback if HTTPS is not available)
        HTTP_URL: 'http://192.168.21.94:3000',
        
        // mDNS URL (if configured and working on your network)
        MDNS_HTTPS_URL: 'https://helpdesk.local:3443',
        MDNS_HTTP_URL: 'http://helpdesk.local:3000'
    },
    
    // API endpoints
    API_ENDPOINTS: {
        LOGIN: '/api/login',
        REGISTER: '/api/register',
        LOGOUT: '/api/logout',
        ME: '/api/me',
        TICKETS: '/api/tickets',
        USERS: '/api/users',
        STATS: '/api/stats',
        COMMENTS: (ticketId) => `/api/tickets/${ticketId}/comments`
    },
    
    // Request configuration for cross-origin requests
    REQUEST_CONFIG: {
        credentials: 'include', // Include cookies for authentication
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }
    }
};

// Helper function to get the base URL for API requests
function getBackendUrl() {
    // Try HTTPS first, then fall back to HTTP
    // You may need to adjust this based on your specific setup
    
    // For production, you might want to detect if HTTPS is available
    // For now, we'll default to HTTPS on port 3443
    return FRONTEND_CONFIG.LOCAL_BACKEND.HTTPS_URL;
}

// Helper function to make API requests with proper CORS handling
async function makeApiRequest(endpoint, options = {}) {
    const baseUrl = getBackendUrl();
    const url = `${baseUrl}${endpoint}`;
    
    const config = {
        ...FRONTEND_CONFIG.REQUEST_CONFIG,
        ...options,
        headers: {
            ...FRONTEND_CONFIG.REQUEST_CONFIG.headers,
            ...(options.headers || {})
        }
    };
    
    // Add Authorization header if token is available (for cases where cookies don't work)
    const token = localStorage.getItem('authToken');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    
    try {
        const response = await fetch(url, config);
        
        // If response includes a token, store it for future requests
        const data = await response.json();
        if (data.token) {
            localStorage.setItem('authToken', data.token);
        }
        
        return { response, data };
    } catch (error) {
        console.error('API request failed:', error);
        throw error;
    }
}

// Instructions for frontend integration
const INTEGRATION_INSTRUCTIONS = `
FRONTEND INTEGRATION INSTRUCTIONS:
=================================

1. **Find Your Local IP Address:**
   - On Windows: Run 'ipconfig' in Command Prompt
   - Look for your network adapter's IPv4 Address (e.g., 192.168.1.100)
   - Replace 'YOUR_LOCAL_IP' in the configuration above

2. **Update Your Frontend Code:**
   - Use the 'makeApiRequest' function instead of direct fetch calls
   - Example: 
     const { data } = await makeApiRequest('/api/login', {
       method: 'POST',
       body: JSON.stringify({ username, password })
     });

3. **Handle Authentication:**
   - The helper function automatically handles both cookie and token-based auth
   - Tokens are stored in localStorage as a fallback for cross-origin scenarios

4. **Test the Connection:**
   - Make sure your local backend is running
   - Try accessing the API from your Vercel frontend
   - Check browser console for any CORS or connection errors

5. **Firewall Configuration:**
   - Ensure your Windows Firewall allows connections on ports 3000 and 3443
   - You may need to create firewall rules for inbound connections

6. **Network Accessibility:**
   - Your local backend must be accessible from the internet for Vercel to reach it
   - Consider using ngrok or similar tools if you're behind a strict firewall
   - Alternative: Set up a VPN or use port forwarding on your router

7. **SSL Certificate (for HTTPS):**
   - If using HTTPS, ensure your SSL certificates are valid
   - Browsers may block self-signed certificates from remote origins
   - Consider using a tool like mkcert for locally-trusted certificates
`;

// Export configuration for use in frontend
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { FRONTEND_CONFIG, makeApiRequest, getBackendUrl };
}

// For browser environments
if (typeof window !== 'undefined') {
    window.FRONTEND_CONFIG = FRONTEND_CONFIG;
    window.makeApiRequest = makeApiRequest;
    window.getBackendUrl = getBackendUrl;
}

console.log(INTEGRATION_INSTRUCTIONS);