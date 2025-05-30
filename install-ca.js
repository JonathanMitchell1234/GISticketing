// Auto-install Root CA Certificate
const { execSync } = require('child_process');
const path = require('path');

try {
    console.log('Installing Root CA Certificate...');
    const certPath = path.join(__dirname, 'certs', 'ca.crt');
    
    // Import certificate to Local Machine Trusted Root store
    execSync(`powershell -Command "Import-Certificate -FilePath '${certPath}' -CertStoreLocation Cert:\\LocalMachine\\Root"`, {
        stdio: 'inherit'
    });
    
    console.log('✅ Root CA Certificate installed successfully!');
    console.log('🎉 Your HTTPS certificates are now trusted by Windows!');
    console.log('');
    console.log('🌐 Access your application securely:');
    console.log('   https://localhost:3443');
    
} catch (error) {
    console.error('❌ Installation failed:', error.message);
    console.log('');
    console.log('💡 Manual installation required:');
    console.log('1. Right-click on "certs/ca.crt"');
    console.log('2. Select "Install Certificate"');
    console.log('3. Choose "Local Machine"');
    console.log('4. Place in "Trusted Root Certification Authorities"');
}