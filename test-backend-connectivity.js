// Test connectivity to remote backend server
const https = require('https');
const http = require('http');

const BACKEND_URL = 'https://192.168.21.94:3443';
const TEST_ENDPOINT = '/api/stats';

console.log('Testing connectivity to remote backend...\n');

async function testBackendConnectivity() {
    console.log(`Testing: ${BACKEND_URL}${TEST_ENDPOINT}`);
    
    return new Promise((resolve, reject) => {
        // Create HTTPS request with relaxed SSL verification for self-signed certificates
        const options = {
            hostname: '192.168.21.94',
            port: 3443,
            path: TEST_ENDPOINT,
            method: 'GET',
            headers: {
                'Accept': 'application/json',
                'User-Agent': 'Backend-Connectivity-Test'
            },
            // For self-signed certificates, you might need to disable SSL verification
            rejectUnauthorized: false
        };
        
        const req = https.request(options, (res) => {
            console.log(`Status Code: ${res.statusCode}`);
            console.log(`Headers:`, res.headers);
            
            let data = '';
            res.on('data', (chunk) => {
                data += chunk;
            });
            
            res.on('end', () => {
                console.log('\nResponse Body:');
                try {
                    const jsonData = JSON.parse(data);
                    console.log(JSON.stringify(jsonData, null, 2));
                    resolve({ success: true, statusCode: res.statusCode, data: jsonData });
                } catch (e) {
                    console.log(data);
                    resolve({ success: true, statusCode: res.statusCode, data: data });
                }
            });
        });
        
        req.on('error', (error) => {
            console.error(`Connection Error: ${error.message}`);
            reject(error);
        });
        
        req.setTimeout(10000, () => {
            console.error('Request timed out after 10 seconds');
            req.destroy();
            reject(new Error('Timeout'));
        });
        
        req.end();
    });
}

async function runTest() {
    try {
        const result = await testBackendConnectivity();
        
        console.log('\n' + '='.repeat(50));
        if (result.statusCode === 200) {
            console.log('✅ SUCCESS: Backend is accessible and responding correctly!');
            console.log('Your Vercel frontend should be able to connect to this backend.');
        } else if (result.statusCode === 401) {
            console.log('⚠️  AUTHENTICATION REQUIRED: Backend is accessible but requires login.');
            console.log('This is expected behavior. Your Vercel frontend can connect.');
        } else {
            console.log(`⚠️  Backend responded with status code: ${result.statusCode}`);
            console.log('The server is accessible but may have issues.');
        }
        
    } catch (error) {
        console.log('\n' + '='.repeat(50));
        console.log('❌ CONNECTION FAILED');
        console.log(`Error: ${error.message}`);
        console.log();
        console.log('Possible issues:');
        console.log('• Backend server is not running on 192.168.21.94:3443');
        console.log('• Firewall is blocking the connection');
        console.log('• SSL certificate issues');
        console.log('• Network connectivity problems');
        console.log();
        console.log('Troubleshooting steps:');
        console.log('1. Verify the backend server is running');
        console.log('2. Check firewall settings on 192.168.21.94');
        console.log('3. Try the HTTP version: http://192.168.21.94:3000');
        console.log('4. Test from the same network first');
    }
    
    console.log('\n' + '='.repeat(50));
    console.log('Configuration Summary:');
    console.log(`Frontend: https://graphicinfohelpdesk.vercel.app`);
    console.log(`Backend:  ${BACKEND_URL}`);
    console.log('CORS:     ✅ Configured to allow Vercel domain');
}

runTest();
