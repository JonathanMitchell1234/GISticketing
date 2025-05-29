// Test CORS configuration
const testOrigins = [
    'https://192.168.21.40:3443',
    'http://192.168.21.40:3000',
    'https://localhost:3443',
    'http://localhost:3000',
    'https://contoso.sharepoint.com',
    'https://mytenant.sharepoint.com',
    'https://invalid-origin.com'
];

console.log('Testing CORS patterns...\n');

testOrigins.forEach(origin => {
    const allowedOrigins = [
        'http://localhost:3000',
        'https://localhost:3443',
        'http://helpdesk.local:3000',
        'https://helpdesk.local:3443',
        /^https:\/\/.*\.sharepoint\.com$/,
        /^https:\/\/.*\.sharepointonline\.com$/,
        /^https:\/\/.*\.office\.com$/,
        /^http:\/\/localhost:\d+$/,
        /^https:\/\/localhost:\d+$/,
        /^https?:\/\/192\.168\.\d+\.\d+:\d+$/,
        /^https?:\/\/10\.\d+\.\d+\.\d+:\d+$/,
        /^https?:\/\/172\.(1[6-9]|2[0-9]|3[0-1])\.\d+\.\d+:\d+$/,
    ];

    const isAllowed = allowedOrigins.some(allowed => {
        if (typeof allowed === 'string') {
            return origin === allowed;
        } else if (allowed instanceof RegExp) {
            return allowed.test(origin);
        }
        return false;
    });

    console.log(`${origin}: ${isAllowed ? '✓ ALLOWED' : '✗ BLOCKED'}`);
});
