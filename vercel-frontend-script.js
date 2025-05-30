// VERCEL FRONTEND SCRIPT - Updated for Remote Backend
// Copy this entire file to your Vercel frontend project

// Backend Configuration for Vercel Deployment
const API_CONFIG = {
    // Your backend server is hosted at this IP address
    BASE_URL: 'https://192.168.21.94:3443',
    // Fallback to HTTP if HTTPS doesn't work
    BASE_URL_HTTP: 'http://192.168.21.94:3000'
};

// Helper function to build full API URLs
function getApiUrl(endpoint) {
    return `${API_CONFIG.BASE_URL}${endpoint}`;
}

// Global variables
let currentUser = null;
let allTickets = [];
let allUsers = [];
let authToken = null; // Store authentication token

// Token management functions
function setAuthToken(token) {
    authToken = token;
    localStorage.setItem('authToken', token);
    console.log('Auth token stored');
}

function getAuthToken() {
    if (!authToken) {
        authToken = localStorage.getItem('authToken');
    }
    return authToken;
}

function clearAuthToken() {
    authToken = null;
    localStorage.removeItem('authToken');
    console.log('Auth token cleared');
}

// Enhanced fetch function that includes authentication
async function authenticatedFetch(endpoint, options = {}) {
    const token = getAuthToken();
    
    // Build full URL - if endpoint already includes protocol, use as-is, otherwise prepend base URL
    const url = endpoint.startsWith('http') ? endpoint : getApiUrl(endpoint);
    
    // Merge headers with authentication
    const headers = {
        'Content-Type': 'application/json',
        ...options.headers
    };
    
    // Add Authorization header if token exists
    if (token) {
        headers['Authorization'] = `Bearer ${token}`;
    }
    
    const requestOptions = {
        ...options,
        headers,
        credentials: 'include' // Include cookies for cross-origin requests
    };
    
    console.log(`Making API request to: ${url}`); // Debug logging
    
    try {
        const response = await fetch(url, requestOptions);
        console.log(`Response status: ${response.status}`);
        return response;
    } catch (error) {
        console.error(`Fetch error for ${url}:`, error);
        throw error;
    }
}

// Initialize the application
document.addEventListener('DOMContentLoaded', function() {
    console.log('Frontend initialized, backend URL:', API_CONFIG.BASE_URL);
    checkAuthentication();
    setupEventListeners();
});

// Setup event listeners
function setupEventListeners() {
    // Login form
    const loginForm = document.getElementById('loginForm');
    if (loginForm) {
        loginForm.addEventListener('submit', handleLogin);
    }
    
    // Register form
    const registerForm = document.getElementById('registerForm');
    if (registerForm) {
        registerForm.addEventListener('submit', handleRegister);
    }
    
    // Create ticket form
    const createTicketForm = document.getElementById('createTicketForm');
    if (createTicketForm) {
        createTicketForm.addEventListener('submit', handleCreateTicket);
    }
    
    // Add comment form
    const addCommentForm = document.getElementById('addCommentForm');
    if (addCommentForm) {
        addCommentForm.addEventListener('submit', handleAddComment);
    }
    
    // Modal close events
    window.addEventListener('click', function(event) {
        const modal = document.getElementById('ticketModal');
        if (modal && event.target === modal) {
            closeModal();
        }
    });
}

// Authentication functions
async function checkAuthentication() {
    // Initially hide navbar until we know the auth status
    const navbar = document.getElementById('mainNavbar');
    if (navbar) {
        navbar.style.display = 'none';
    }
    
    try {
        console.log('Checking authentication...');
        const response = await authenticatedFetch('/api/me');
        console.log('Auth check response status:', response.status);
        
        if (response.ok) {
            const data = await response.json();
            currentUser = data.user;
            console.log('User authenticated:', currentUser);
            showMainContent();
            loadDashboard();
        } else {
            console.log('Authentication failed, clearing token');
            // Clear invalid token if authentication fails
            clearAuthToken();
            showLogin();
        }
    } catch (error) {
        console.error('Authentication check failed:', error);
        clearAuthToken();
        showLogin();
    }
}

async function handleLogin(event) {
    event.preventDefault();
    console.log('Login attempt started');
    
    const username = document.getElementById('loginUsername').value;
    const password = document.getElementById('loginPassword').value;
    
    if (!username || !password) {
        showToast('Please enter both username and password', 'error');
        return;
    }
    
    try {
        showLoading(true);
        console.log('Sending login request...');
        
        const response = await authenticatedFetch('/api/login', {
            method: 'POST',
            body: JSON.stringify({ username, password }),
        });
        
        console.log('Login response status:', response.status);
        
        // Check if response is JSON
        const contentType = response.headers.get('content-type');
        if (!contentType || !contentType.includes('application/json')) {
            const textResponse = await response.text();
            console.error('Non-JSON response:', textResponse);
            throw new Error('Server returned non-JSON response. Check if backend is running correctly.');
        }
        
        const data = await response.json();
        console.log('Login response data:', data);
        
        if (response.ok) {
            currentUser = data.user;
            // Store the authentication token
            if (data.token) {
                setAuthToken(data.token);
            }
            console.log('Login successful for user:', currentUser.username);
            showToast('Login successful!', 'success');
            showMainContent();
            loadDashboard();
        } else {
            console.error('Login failed:', data.error);
            showToast(data.error || 'Login failed', 'error');
        }
    } catch (error) {
        console.error('Login error:', error);
        showToast('Login failed: ' + error.message, 'error');
    } finally {
        showLoading(false);
    }
}

async function handleRegister(event) {
    event.preventDefault();
    console.log('Registration attempt started');
    
    const username = document.getElementById('registerUsername').value;
    const email = document.getElementById('registerEmail').value;
    const password = document.getElementById('registerPassword').value;
    
    if (!username || !email || !password) {
        showToast('Please fill in all fields', 'error');
        return;
    }
    
    try {
        showLoading(true);
        console.log('Sending registration request...');
        
        const response = await authenticatedFetch('/api/register', {
            method: 'POST',
            body: JSON.stringify({ username, email, password }),
        });
        
        console.log('Registration response status:', response.status);
        
        // Check if response is JSON
        const contentType = response.headers.get('content-type');
        if (!contentType || !contentType.includes('application/json')) {
            const textResponse = await response.text();
            console.error('Non-JSON response:', textResponse);
            throw new Error('Server returned non-JSON response. Check if backend is running correctly.');
        }
        
        const data = await response.json();
        console.log('Registration response data:', data);
        
        if (response.ok) {
            currentUser = data.user;
            // Store the authentication token
            if (data.token) {
                setAuthToken(data.token);
            }
            console.log('Registration successful for user:', currentUser.username);
            showToast('Registration successful!', 'success');
            showMainContent();
            loadDashboard();
        } else {
            console.error('Registration failed:', data.error);
            showToast(data.error || 'Registration failed', 'error');
        }
    } catch (error) {
        console.error('Registration error:', error);
        showToast('Registration failed: ' + error.message, 'error');
    } finally {
        showLoading(false);
    }
}

async function logout() {
    try {
        console.log('Logging out...');
        await authenticatedFetch('/api/logout', { method: 'POST' });
        currentUser = null;
        clearAuthToken(); // Clear the stored token
        showToast('Logged out successfully', 'success');
        showLogin();
    } catch (error) {
        console.error('Logout error:', error);
        // Still clear local state even if server request fails
        currentUser = null;
        clearAuthToken();
        showToast('Logged out', 'info');
        showLogin();
    }
}

// UI navigation functions
function showLogin() {
    console.log('Showing login screen');
    const loginSection = document.getElementById('login-section');
    const registerSection = document.getElementById('register-section');
    const mainContent = document.getElementById('main-content');
    const navbar = document.getElementById('mainNavbar');
    
    if (loginSection) loginSection.style.display = 'flex';
    if (registerSection) registerSection.style.display = 'none';
    if (mainContent) mainContent.style.display = 'none';
    if (navbar) navbar.style.display = 'none';
}

function showRegister() {
    console.log('Showing register screen');
    const loginSection = document.getElementById('login-section');
    const registerSection = document.getElementById('register-section');
    const mainContent = document.getElementById('main-content');
    const navbar = document.getElementById('mainNavbar');
    
    if (loginSection) loginSection.style.display = 'none';
    if (registerSection) registerSection.style.display = 'flex';
    if (mainContent) mainContent.style.display = 'none';
    if (navbar) navbar.style.display = 'none';
}

function showMainContent() {
    console.log('Showing main content for user:', currentUser?.username);
    const loginSection = document.getElementById('login-section');
    const registerSection = document.getElementById('register-section');
    const mainContent = document.getElementById('main-content');
    const navbar = document.getElementById('mainNavbar');
    
    if (loginSection) loginSection.style.display = 'none';
    if (registerSection) registerSection.style.display = 'none';
    if (mainContent) mainContent.style.display = 'block';
    if (navbar) navbar.style.display = 'block';
    
    // Update navigation
    const navUser = document.getElementById('navUser');
    const username = document.getElementById('username');
    if (navUser) navUser.style.display = 'flex';
    if (username && currentUser) username.textContent = currentUser.username;
    
    // Show/hide admin features
    if (currentUser && currentUser.role === 'admin') {
        document.body.classList.add('admin-user');
    }
}

function showSection(sectionName) {
    console.log('Switching to section:', sectionName);
    
    // Hide all sections
    document.querySelectorAll('.section').forEach(section => {
        section.classList.remove('active');
    });
    
    // Remove active class from nav links
    document.querySelectorAll('.nav-link').forEach(link => {
        link.classList.remove('active');
    });
    
    // Show selected section
    const targetSection = document.getElementById(sectionName);
    if (targetSection) {
        targetSection.classList.add('active');
    }
    
    // Add active class to nav link
    const navLink = document.querySelector(`[onclick="showSection('${sectionName}')"]`);
    if (navLink) {
        navLink.classList.add('active');
    }
    
    // Load section-specific data
    switch(sectionName) {
        case 'dashboard':
            loadDashboard();
            break;
        case 'tickets':
            loadTickets();
            break;
        case 'create-ticket':
            // Reset form
            const form = document.getElementById('createTicketForm');
            if (form) form.reset();
            break;
    }
}

// Dashboard functions
async function loadDashboard() {
    try {
        console.log('Loading dashboard...');
        showLoading(true);
        
        // Load stats
        const statsResponse = await authenticatedFetch('/api/stats');
        if (!statsResponse.ok) {
            throw new Error(`Stats request failed: ${statsResponse.status}`);
        }
        const stats = await statsResponse.json();
        console.log('Dashboard stats loaded:', stats);
        
        // Update stats display
        const totalElement = document.getElementById('totalTickets');
        const openElement = document.getElementById('openTickets');
        const progressElement = document.getElementById('progressTickets');
        const closedElement = document.getElementById('closedTickets');
        
        if (totalElement) totalElement.textContent = stats.total || 0;
        if (openElement) openElement.textContent = stats.open || 0;
        if (progressElement) progressElement.textContent = stats.in_progress || 0;
        if (closedElement) closedElement.textContent = stats.closed || 0;
        
        // Load recent tickets
        const ticketsResponse = await authenticatedFetch('/api/tickets');
        if (!ticketsResponse.ok) {
            throw new Error(`Tickets request failed: ${ticketsResponse.status}`);
        }
        const tickets = await ticketsResponse.json();
        console.log('Recent tickets loaded:', tickets.length);
        
        allTickets = tickets;
        displayRecentTickets(tickets.slice(0, 5));
        
    } catch (error) {
        console.error('Dashboard load error:', error);
        showToast('Failed to load dashboard: ' + error.message, 'error');
    } finally {
        showLoading(false);
    }
}

function displayRecentTickets(tickets) {
    const container = document.getElementById('recentTicketsList');
    if (!container) {
        console.warn('Recent tickets container not found');
        return;
    }
    
    if (tickets.length === 0) {
        container.innerHTML = '<p class="text-center">No tickets found</p>';
        return;
    }
    
    container.innerHTML = tickets.map(ticket => `
        <div class="ticket-item priority-${ticket.priority.toLowerCase()}" onclick="openTicketModal(${ticket.id})">
            <div class="ticket-header">
                <div>
                    <div class="ticket-title">${escapeHtml(ticket.title)}</div>
                    <div class="ticket-meta">
                        <span><i class="fas fa-user"></i> ${escapeHtml(ticket.creator_name || 'Unknown')}</span>
                        <span><i class="fas fa-calendar"></i> ${formatDate(ticket.created_at)}</span>
                        ${ticket.category ? `<span><i class="fas fa-tag"></i> ${escapeHtml(ticket.category)}</span>` : ''}
                    </div>
                </div>
                <div class="ticket-status">
                    <span class="status-badge status-${ticket.status.toLowerCase().replace(' ', '-')}">${ticket.status}</span>
                    <span class="priority-badge priority-${ticket.priority.toLowerCase()}">${ticket.priority}</span>
                </div>
            </div>
        </div>
    `).join('');
}

// Utility functions
function showLoading(show) {
    const spinner = document.getElementById('loadingSpinner');
    if (spinner) {
        spinner.style.display = show ? 'block' : 'none';
    }
}

function showToast(message, type = 'info') {
    console.log(`Toast [${type}]: ${message}`);
    
    const toast = document.getElementById('toast');
    if (toast) {
        toast.textContent = message;
        toast.className = `toast ${type}`;
        toast.style.display = 'block';
        
        setTimeout(() => {
            toast.style.display = 'none';
        }, 5000); // Show for 5 seconds
    } else {
        // Fallback to alert if toast element not found
        alert(`${type.toUpperCase()}: ${message}`);
    }
}

function formatDate(dateString) {
    try {
        const date = new Date(dateString);
        return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
    } catch (error) {
        return 'Invalid Date';
    }
}

function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Test connection function - call this from browser console to test
function testConnection() {
    console.log('Testing connection to backend...');
    authenticatedFetch('/api/stats')
        .then(response => {
            console.log('Test response status:', response.status);
            return response.json();
        })
        .then(data => {
            console.log('Test successful! Data:', data);
            showToast('Connection test successful!', 'success');
        })
        .catch(error => {
            console.error('Test failed:', error);
            showToast('Connection test failed: ' + error.message, 'error');
        });
}

// Placeholder functions for features not yet implemented in this simplified version
function loadTickets() {
    console.log('loadTickets() - implement this function for full ticket management');
    showToast('Ticket management feature needs to be implemented', 'info');
}

function handleCreateTicket(event) {
    event.preventDefault();
    console.log('handleCreateTicket() - implement this function for ticket creation');
    showToast('Ticket creation feature needs to be implemented', 'info');
}

function handleAddComment(event) {
    event.preventDefault();
    console.log('handleAddComment() - implement this function for comments');
    showToast('Comment feature needs to be implemented', 'info');
}

function openTicketModal(ticketId) {
    console.log('openTicketModal() - implement this function for ticket details');
    showToast('Ticket modal feature needs to be implemented', 'info');
}

function closeModal() {
    const modal = document.getElementById('ticketModal');
    if (modal) {
        modal.style.display = 'none';
    }
}

// Expose test function globally for debugging
window.testConnection = testConnection;

console.log('✅ Vercel frontend script loaded successfully!');
console.log('Backend URL:', API_CONFIG.BASE_URL);
console.log('Run testConnection() in console to test backend connectivity');
