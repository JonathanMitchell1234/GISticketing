const forge = require('node-forge');
const fs = require('fs');
const path = require('path');

// Create certs directory if it doesn't exist
const certsDir = path.join(__dirname, 'certs');
if (!fs.existsSync(certsDir)) {
    fs.mkdirSync(certsDir);
}

// Generate a key pair
console.log('Generating RSA key pair...');
const keys = forge.pki.rsa.generateKeyPair(2048);

// Create a certificate
console.log('Creating certificate...');
const cert = forge.pki.createCertificate();
cert.publicKey = keys.publicKey;
cert.serialNumber = '01';
cert.validity.notBefore = new Date();
cert.validity.notAfter = new Date();
cert.validity.notAfter.setFullYear(cert.validity.notBefore.getFullYear() + 1);

// Set certificate subject and issuer
const attrs = [
    { name: 'commonName', value: 'localhost' },
    { name: 'countryName', value: 'US' },
    { shortName: 'ST', value: 'State' },
    { name: 'localityName', value: 'City' },
    { name: 'organizationName', value: 'Test' },
    { shortName: 'OU', value: 'Test' }
];
cert.setSubject(attrs);
cert.setIssuer(attrs);

// Add extensions
cert.setExtensions([
    {
        name: 'basicConstraints',
        cA: true
    },
    {
        name: 'keyUsage',
        keyCertSign: true,
        digitalSignature: true,
        nonRepudiation: true,
        keyEncipherment: true,
        dataEncipherment: true
    },
    {
        name: 'extKeyUsage',
        serverAuth: true,
        clientAuth: true,
        codeSigning: true,
        emailProtection: true,
        timeStamping: true
    },
    {
        name: 'nsCertType',
        client: true,
        server: true,
        email: true,
        objsign: true,
        sslCA: true,
        emailCA: true,
        objCA: true
    },
    {
        name: 'subjectAltName',
        altNames: [
            {
                type: 2, // DNS
                value: 'localhost'
            },
            {
                type: 2, // DNS
                value: 'helpdesk.local'
            },
            {
                type: 7, // IP
                ip: '127.0.0.1'
            },
            {
                type: 7, // IP
                ip: '::1'
            }
        ]
    }
]);

// Self-sign certificate
cert.sign(keys.privateKey);

// Convert to PEM format
const privatePem = forge.pki.privateKeyToPem(keys.privateKey);
const certPem = forge.pki.certificateToPem(cert);

// Write files
fs.writeFileSync(path.join(certsDir, 'server.key'), privatePem);
fs.writeFileSync(path.join(certsDir, 'server.crt'), certPem);

console.log('✓ SSL certificate generated successfully!');
console.log('  Private key: certs/server.key');
console.log('  Certificate: certs/server.crt');
console.log('');
console.log('Note: This is a self-signed certificate for development use only.');
console.log('Your browser will show a security warning that you can safely ignore for local development.');
