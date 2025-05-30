// Test CORS configuration for Vercel domain
console.log('Testing CORS for Vercel domain...\n');

const vercelOrigin = 'https://graphicinfohelpdesk.vercel.app';

// This is the same CORS logic from your server.js
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

console.log(`Testing origin: ${vercelOrigin}`);
console.log(`Result: ${isAllowed ? '✓ ALLOWED' : '✗ BLOCKED'}`);

if (isAllowed) {
    console.log('\n✅ Your Vercel frontend will be able to communicate with your local backend!');
    console.log('\nNext steps:');
    console.log('1. Make sure your local backend server is running');
    console.log('2. Ensure your frontend code uses the correct local backend URL');
    console.log('3. Remember that your local backend needs to be accessible on your network');
} else {
    console.log('\n❌ There may be an issue with the CORS configuration.');
}
