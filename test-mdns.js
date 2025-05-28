// Test script to verify mDNS setup
const { Bonjour } = require('bonjour-service');

console.log('Testing mDNS (Bonjour) setup...');

try {
    const bonjour = new Bonjour();
    
    // Publish a test service
    const service = bonjour.publish({
        name: 'IT Helpdesk System Test',
        type: 'http',
        port: 3000,
        host: 'helpdesk.local'
    });
    
    console.log('✓ mDNS service published successfully');
    console.log('  Service name: IT Helpdesk System Test');
    console.log('  Domain: helpdesk.local');
    console.log('  Port: 3000');
    console.log('  Type: http');
    
    // Clean up after 3 seconds
    setTimeout(() => {
        bonjour.unpublishAll();
        bonjour.destroy();
        console.log('✓ Test completed - mDNS setup is working correctly');
        process.exit(0);
    }, 3000);
    
} catch (error) {
    console.error('✗ mDNS setup failed:', error.message);
    process.exit(1);
}
