// Test CORS configuration for backend at 192.168.21.94:3443
console.log('Testing CORS for Vercel frontend to remote backend...\n');

const vercelOrigin = 'https://graphicinfohelpdesk.vercel.app';
const backendUrl = 'https://192.168.21.94:3443';

console.log(`Frontend (Vercel): ${vercelOrigin}`);
console.log(`Backend Server: ${backendUrl}`);
console.log();

// Test if the CORS configuration allows the Vercel origin
const allowedOrigins = [
    'http://localhost:3000',
    'https://localhost:3443',
    'http://helpdesk.local:3000',
    'https://helpdesk.local:3443',
    'https://graphicinfohelpdesk.vercel.app',  // Vercel hosted frontend
    /^https:\/\/.*\.sharepoint\.com$/,  // SharePoint Online
    /^https:\/\/.*\.sharepointonline\.com$/,  // SharePoint Online alternative
    /^https:\/\/.*\.office\.com$/,  // Office 365
    /^http:\/\/localhost:\d+$/,  // Local development
    /^https:\/\/localhost:\d+$/,  // Local development HTTPS
    /^https?:\/\/192\.168\.\d+\.\d+:\d+$/,  // Local network IP addresses
    /^https?:\/\/10\.\d+\.\d+\.\d+:\d+$/,  // Private network 10.x.x.x
    /^https?:\/\/172\.(1[6-9]|2[0-9]|3[0-1])\.\d+\.\d+:\d+$/,  // Private network 172.16-31.x.x
];

const isAllowed = allowedOrigins.some(allowed => {
    if (typeof allowed === 'string') {
        return vercelOrigin === allowed;
    } else if (allowed instanceof RegExp) {
        return allowed.test(vercelOrigin);
    }
    return false;
});

console.log('CORS Configuration Test:');
console.log(`Origin: ${vercelOrigin}`);
console.log(`Status: ${isAllowed ? '✅ ALLOWED' : '❌ BLOCKED'}`);
console.log();

if (isAllowed) {
    console.log('✅ CORS Configuration is correct!');
    console.log('Your Vercel frontend should be able to communicate with the backend.');
    console.log();
    console.log('Next steps:');
    console.log('1. Ensure the backend server at 192.168.21.94:3443 is running');
    console.log('2. Test connectivity from your Vercel frontend');
    console.log('3. Check that the backend server has the same CORS configuration');
} else {
    console.log('❌ CORS Configuration issue detected!');
    console.log('The backend needs to include your Vercel domain in its allowed origins.');
}

console.log();
console.log('Network Requirements:');
console.log('• Backend server (192.168.21.94:3443) must be accessible from the internet');
console.log('• Firewall must allow inbound connections on port 3443');
console.log('• SSL certificate must be valid for HTTPS connections');
console.log('• Router may need port forwarding if behind NAT');

// Test function to check if backend is accessible (for manual testing)
console.log();
console.log('Manual Test:');
console.log(`Try accessing: ${backendUrl}/api/stats`);
console.log('This should return JSON with ticket statistics if the server is running.');
