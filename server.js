const express = require('express');
const https = require('https');
const fs = require('fs');
const sqlite3 = require('sqlite3').verbose();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cookieParser = require('cookie-parser');
const cors = require('cors');
const path = require('path');
const { Bonjour } = require('bonjour-service');

const app = express();
const PORT = process.env.PORT || 3000;
const HTTPS_PORT = process.env.HTTPS_PORT || 3443;
const HOST = process.env.HOST || '0.0.0.0'; // Bind to all network interfaces
const JWT_SECRET = 'your-secret-key-change-in-production';

// CORS Configuration for SharePoint integration
const corsOptions = {
    origin: function (origin, callback) {        // Allow requests with no origin (like mobile apps or curl requests)
        if (!origin) return callback(null, true);
        
        // List of allowed origins
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
            /^https?:\/\/10\.\d+\.\d+\.\d+:\d+$/,  // Private network 10.x.x.x            /^https?:\/\/172\.(1[6-9]|2[0-9]|3[0-1])\.\d+\.\d+:\d+$/,  // Private network 172.16-31.x.x
        ];
        
        // Check if origin is allowed
        const isAllowed = allowedOrigins.some(allowed => {
            if (typeof allowed === 'string') {
                return origin === allowed;
            } else if (allowed instanceof RegExp) {
                return allowed.test(origin);
            }
            return false;
        });
        
        if (isAllowed) {
            console.log('CORS allowed origin:', origin);
            callback(null, true);
        } else {
            console.log('CORS blocked origin:', origin);
            console.log('Allowed origins patterns:', allowedOrigins);
            callback(new Error('Not allowed by CORS'));
        }
    },
    credentials: true, // Allow cookies to be sent
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: [
        'Content-Type', 
        'Authorization', 
        'X-Requested-With',
        'Accept',
        'Origin',
        'Cache-Control'
    ],
    optionsSuccessStatus: 200 // Some legacy browsers (IE11, various SmartTVs) choke on 204
};

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(cors(corsOptions));

// Additional headers for SharePoint and iframe compatibility
app.use((req, res, next) => {
    // Allow embedding in iframes (for SharePoint web parts)
    res.setHeader('X-Frame-Options', 'ALLOWALL');
    res.setHeader('Content-Security-Policy', "frame-ancestors *;");
    
    // Cache control for static assets
    if (req.url.match(/\.(css|js|png|jpg|jpeg|gif|ico|svg)$/)) {
        res.setHeader('Cache-Control', 'public, max-age=3600');
    }
    
    next();
});

app.use(express.static(path.join(__dirname, 'public')));

// Database setup
const db = new sqlite3.Database('./ticketing.db');

// Initialize database tables
db.serialize(() => {
    // Users table
    db.run(`CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        email TEXT UNIQUE,
        password TEXT,
        role TEXT DEFAULT 'user',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);

    // Tickets table
    db.run(`CREATE TABLE IF NOT EXISTS tickets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        priority TEXT DEFAULT 'Medium',
        status TEXT DEFAULT 'Open',
        category TEXT,
        assigned_to INTEGER,
        created_by INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (assigned_to) REFERENCES users (id),
        FOREIGN KEY (created_by) REFERENCES users (id)
    )`);

    // Comments table
    db.run(`CREATE TABLE IF NOT EXISTS comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ticket_id INTEGER,
        user_id INTEGER,
        comment TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (ticket_id) REFERENCES tickets (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
    )`);

    // Create default admin user
    const adminPassword = bcrypt.hashSync('admin123', 10);
    db.run(`INSERT OR IGNORE INTO users (username, email, password, role) 
            VALUES ('admin', 'admin@company.com', ?, 'admin')`, [adminPassword]);
});

// Authentication middleware
const authenticateToken = (req, res, next) => {
    // Try to get token from multiple sources
    let token = req.cookies.token;
    
    // If no token in cookies, check Authorization header
    if (!token) {
        const authHeader = req.headers.authorization;
        if (authHeader && authHeader.startsWith('Bearer ')) {
            token = authHeader.substring(7);
        }
    }
    
    // If still no token, check for token in request body or query (for development)
    if (!token) {
        token = req.body.token || req.query.token;
    }
    
    if (!token) {
        console.log('No token found in cookies, headers, or body');
        return res.status(401).json({ error: 'Access denied - Please log in again' });
    }

    try {
        const verified = jwt.verify(token, JWT_SECRET);
        req.user = verified;
        console.log('User authenticated:', req.user.username, 'via', req.cookies.token ? 'cookie' : 'header/body');
        next();
    } catch (error) {
        console.log('Token verification failed:', error.message);
        res.status(400).json({ error: 'Invalid token - Please log in again' });
    }
};

// Check if user is admin
const isAdmin = (req, res, next) => {
    if (req.user.role !== 'admin') {
        return res.status(403).json({ error: 'Admin access required' });
    }
    next();
};

// Routes

// Serve main page
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Authentication routes
app.post('/api/register', async (req, res) => {
    try {
        const { username, email, password } = req.body;
        
        if (!username || !email || !password) {
            return res.status(400).json({ error: 'All fields are required' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        
        db.run(
            'INSERT INTO users (username, email, password) VALUES (?, ?, ?)',
            [username, email, hashedPassword],
            function(err) {
                if (err) {
                    if (err.message.includes('UNIQUE constraint failed')) {
                        return res.status(400).json({ error: 'Username or email already exists' });
                    }
                    return res.status(500).json({ error: 'Registration failed' });
                }
                  const token = jwt.sign(
                    { id: this.lastID, username, role: 'user' },
                    JWT_SECRET,
                    { expiresIn: '24h' }
                );
                
                // Set cookie with proper settings for cross-origin
                res.cookie('token', token, { 
                    httpOnly: true, 
                    maxAge: 24 * 60 * 60 * 1000,
                    sameSite: 'none',
                    secure: true // Required for SameSite=none
                });
                
                // Also send token in response for cross-origin scenarios
                res.json({ 
                    message: 'Registration successful', 
                    user: { id: this.lastID, username, role: 'user' },
                    token: token
                });
            }
        );
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
});

app.post('/api/login', async (req, res) => {
    try {
        const { username, password } = req.body;
        
        db.get(
            'SELECT * FROM users WHERE username = ?',
            [username],
            async (err, user) => {
                if (err) {
                    return res.status(500).json({ error: 'Server error' });
                }
                
                if (!user || !await bcrypt.compare(password, user.password)) {
                    return res.status(400).json({ error: 'Invalid credentials' });
                }
                  const token = jwt.sign(
                    { id: user.id, username: user.username, role: user.role },
                    JWT_SECRET,
                    { expiresIn: '24h' }
                );
                
                // Set cookie with proper settings for cross-origin
                res.cookie('token', token, { 
                    httpOnly: true, 
                    maxAge: 24 * 60 * 60 * 1000,
                    sameSite: 'none',
                    secure: true // Required for SameSite=none
                });
                
                // Also send token in response for cross-origin scenarios where cookies might not work
                res.json({ 
                    message: 'Login successful', 
                    user: { id: user.id, username: user.username, role: user.role },
                    token: token // Include token in response
                });
            }
        );
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
});

app.post('/api/logout', (req, res) => {
    res.clearCookie('token');
    res.json({ message: 'Logout successful' });
});

// Get current user
app.get('/api/me', authenticateToken, (req, res) => {
    res.json({ user: req.user });
});

// Ticket routes
app.get('/api/tickets', authenticateToken, (req, res) => {
    let query = `
        SELECT t.*, 
               creator.username as creator_name,
               assignee.username as assignee_name
        FROM tickets t
        LEFT JOIN users creator ON t.created_by = creator.id
        LEFT JOIN users assignee ON t.assigned_to = assignee.id
        ORDER BY t.created_at DESC
    `;
    
    // All logged-in users can now see all tickets
    db.all(query, (err, tickets) => {
        if (err) {
            return res.status(500).json({ error: 'Failed to fetch tickets' });
        }
        res.json(tickets);
    });
});

app.post('/api/tickets', authenticateToken, (req, res) => {
    const { title, description, priority, category } = req.body;
    
    if (!title || !description) {
        return res.status(400).json({ error: 'Title and description are required' });
    }
    
    db.run(
        'INSERT INTO tickets (title, description, priority, category, created_by) VALUES (?, ?, ?, ?, ?)',
        [title, description, priority || 'Medium', category, req.user.id],
        function(err) {
            if (err) {
                return res.status(500).json({ error: 'Failed to create ticket' });
            }
            res.json({ message: 'Ticket created successfully', ticketId: this.lastID });
        }
    );
});

app.put('/api/tickets/:id', authenticateToken, (req, res) => {
    const ticketId = req.params.id;
    const { status, assigned_to, priority } = req.body;
    
    // Check if ticket exists
    db.get(
        'SELECT * FROM tickets WHERE id = ?',
        [ticketId],
        (err, ticket) => {
            if (err) {
                return res.status(500).json({ error: 'Server error' });
            }
            
            if (!ticket) {
                return res.status(404).json({ error: 'Ticket not found' });
            }
            
            // All logged-in users can now update tickets, but admin-only features are restricted
            // Regular users can only change priority (if we want to restrict further, we can add more conditions)
            if (req.user.role !== 'admin' && (status || assigned_to !== undefined)) {
                return res.status(403).json({ error: 'Only admins can change status or assignments' });
            }
            
            let updateQuery = 'UPDATE tickets SET updated_at = CURRENT_TIMESTAMP';
            let params = [];
            
            if (status && req.user.role === 'admin') {
                updateQuery += ', status = ?';
                params.push(status);
            }
            
            if (assigned_to !== undefined && req.user.role === 'admin') {
                updateQuery += ', assigned_to = ?';
                params.push(assigned_to);
            }
            
            if (priority) {
                updateQuery += ', priority = ?';
                params.push(priority);
            }
            
            updateQuery += ' WHERE id = ?';
            params.push(ticketId);
            
            db.run(updateQuery, params, function(err) {
                if (err) {
                    return res.status(500).json({ error: 'Failed to update ticket' });
                }
                res.json({ message: 'Ticket updated successfully' });
            });
        }
    );
});

// Delete ticket (admin only)
app.delete('/api/tickets/:id', authenticateToken, isAdmin, (req, res) => {
    const ticketId = req.params.id;
    
    // First delete all comments associated with the ticket
    db.run('DELETE FROM comments WHERE ticket_id = ?', [ticketId], function(err) {
        if (err) {
            return res.status(500).json({ error: 'Failed to delete ticket comments' });
        }
        
        // Then delete the ticket
        db.run('DELETE FROM tickets WHERE id = ?', [ticketId], function(err) {
            if (err) {
                return res.status(500).json({ error: 'Failed to delete ticket' });
            }
            
            if (this.changes === 0) {
                return res.status(404).json({ error: 'Ticket not found' });
            }
            
            res.json({ message: 'Ticket deleted successfully' });
        });
    });
});

// Get users (for assignment dropdown)
app.get('/api/users', authenticateToken, isAdmin, (req, res) => {
    db.all(
        'SELECT id, username, email, role FROM users ORDER BY username',
        (err, users) => {
            if (err) {
                return res.status(500).json({ error: 'Failed to fetch users' });
            }
            res.json(users);
        }
    );
});

// Comments routes
app.get('/api/tickets/:id/comments', authenticateToken, (req, res) => {
    const ticketId = req.params.id;
    
    db.all(`
        SELECT c.*, u.username 
        FROM comments c
        JOIN users u ON c.user_id = u.id
        WHERE c.ticket_id = ?
        ORDER BY c.created_at ASC
    `, [ticketId], (err, comments) => {
        if (err) {
            return res.status(500).json({ error: 'Failed to fetch comments' });
        }
        res.json(comments);
    });
});

app.post('/api/tickets/:id/comments', authenticateToken, (req, res) => {
    const ticketId = req.params.id;
    const { comment } = req.body;
    
    if (!comment) {
        return res.status(400).json({ error: 'Comment is required' });
    }
    
    db.run(
        'INSERT INTO comments (ticket_id, user_id, comment) VALUES (?, ?, ?)',
        [ticketId, req.user.id, comment],
        function(err) {
            if (err) {
                return res.status(500).json({ error: 'Failed to add comment' });
            }
            res.json({ message: 'Comment added successfully' });
        }
    );
});

// Dashboard stats
app.get('/api/stats', authenticateToken, (req, res) => {
    const queries = [
        'SELECT COUNT(*) as total FROM tickets',
        "SELECT COUNT(*) as open FROM tickets WHERE status = 'Open'",
        "SELECT COUNT(*) as in_progress FROM tickets WHERE status = 'In Progress'",
        "SELECT COUNT(*) as closed FROM tickets WHERE status = 'Closed'"
    ];
    
    Promise.all(queries.map(query => {
        return new Promise((resolve, reject) => {
            db.get(query, (err, result) => {
                if (err) reject(err);
                else resolve(result);
            });
        });
    })).then(results => {
        res.json({
            total: results[0].total || results[0].open || results[0].in_progress || results[0].closed || 0,
            open: results[1].open || 0,
            in_progress: results[2].in_progress || 0,
            closed: results[3].closed || 0
        });
    }).catch(err => {
        res.status(500).json({ error: 'Failed to fetch stats' });
    });
});

// SSL Certificate configuration
let httpsOptions = null;
try {
    httpsOptions = {
        key: fs.readFileSync(path.join(__dirname, 'certs', 'server.key')),
        cert: fs.readFileSync(path.join(__dirname, 'certs', 'server.crt'))
    };
} catch (error) {
    console.log('SSL certificates not found. HTTPS will not be available.');
    console.log('Run "node generate-cert.js" to generate SSL certificates.');
}

// Start HTTP server
app.listen(PORT, HOST, () => {
    console.log(`IT Ticketing System running on:`);
    console.log(`  Local HTTP:     http://localhost:${PORT}`);
    console.log(`  Network HTTP:   http://${getLocalIP()}:${PORT}`);
    console.log(`  mDNS HTTP:      http://helpdesk.local:${PORT}`);
    
    if (httpsOptions) {
        console.log(`  Local HTTPS:    https://localhost:${HTTPS_PORT}`);
        console.log(`  Network HTTPS:  https://${getLocalIP()}:${HTTPS_PORT}`);
        console.log(`  mDNS HTTPS:     https://helpdesk.local:${HTTPS_PORT}`);
    }
    
    console.log('Default admin credentials: username: admin, password: admin123');
    console.log('\nTo access from other devices on your network, use any of the URLs above');
    console.log('Note: For HTTPS, you may need to accept the security warning for the self-signed certificate');
    
    // Start mDNS service for HTTP
    const bonjour = new Bonjour();
    bonjour.publish({
        name: 'IT Helpdesk System',
        type: 'http',
        port: PORT,
        host: 'helpdesk.local'
    });
    
    console.log('\n✓ mDNS service published as "helpdesk.local"');
    console.log('  Note: It may take a few moments for the domain to be discoverable');
});

// Start HTTPS server if certificates are available
if (httpsOptions) {
    https.createServer(httpsOptions, app).listen(HTTPS_PORT, HOST, () => {
        console.log(`✓ HTTPS server started on port ${HTTPS_PORT}`);
        
        // Start mDNS service for HTTPS
        const bonjour = new Bonjour();
        bonjour.publish({
            name: 'IT Helpdesk System (HTTPS)',
            type: 'https',
            port: HTTPS_PORT,
            host: 'helpdesk.local'
        });
    });
}

// Helper function to get local IP address
function getLocalIP() {
    const { networkInterfaces } = require('os');
    const nets = networkInterfaces();
    
    for (const name of Object.keys(nets)) {
        for (const net of nets[name]) {
            // Skip over non-IPv4 and internal (i.e. 127.0.0.1) addresses
            if (net.family === 'IPv4' && !net.internal) {
                return net.address;
            }
        }
    }
    return HOST;
}
