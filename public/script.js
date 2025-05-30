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
    return fetch(url, requestOptions);
}

// Initialize the application
document.addEventListener('DOMContentLoaded', function() {
    checkAuthentication();
    setupEventListeners();
});

// Setup event listeners
function setupEventListeners() {
    // Login form
    document.getElementById('loginForm').addEventListener('submit', handleLogin);
    
    // Register form
    document.getElementById('registerForm').addEventListener('submit', handleRegister);
    
    // Create ticket form
    document.getElementById('createTicketForm').addEventListener('submit', handleCreateTicket);
    
    // Add comment form
    document.getElementById('addCommentForm').addEventListener('submit', handleAddComment);
    
    // Modal close events
    window.addEventListener('click', function(event) {
        const modal = document.getElementById('ticketModal');
        if (event.target === modal) {
            closeModal();
        }
    });
}

// Authentication functions
async function checkAuthentication() {
    // Initially hide navbar until we know the auth status
    document.getElementById('mainNavbar').style.display = 'none';
    
    try {
        const response = await authenticatedFetch('/api/me');
        if (response.ok) {
            const data = await response.json();
            currentUser = data.user;
            showMainContent();
            loadDashboard();
        } else {
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
    const username = document.getElementById('loginUsername').value;
    const password = document.getElementById('loginPassword').value;
    
    try {
        showLoading(true);        const response = await authenticatedFetch('/api/login', {
            method: 'POST',
            body: JSON.stringify({ username, password }),
        });
          const data = await response.json();
        
        if (response.ok) {
            currentUser = data.user;
            // Store the authentication token
            if (data.token) {
                setAuthToken(data.token);
            }
            showToast('Login successful!', 'success');
            showMainContent();
            loadDashboard();
        } else {
            showToast(data.error || 'Login failed', 'error');
        }
    } catch (error) {
        console.error('Login error:', error);
        showToast('Login failed. Please try again.', 'error');
    } finally {
        showLoading(false);
    }
}

async function handleRegister(event) {
    event.preventDefault();
    const username = document.getElementById('registerUsername').value;
    const email = document.getElementById('registerEmail').value;
    const password = document.getElementById('registerPassword').value;
    
    try {
        showLoading(true);        const response = await authenticatedFetch('/api/register', {
            method: 'POST',
            body: JSON.stringify({ username, email, password }),
        });
        
        const data = await response.json();
          if (response.ok) {
            currentUser = data.user;
            // Store the authentication token
            if (data.token) {
                setAuthToken(data.token);
            }
            showToast('Registration successful!', 'success');
            showMainContent();
            loadDashboard();
        } else {
            showToast(data.error || 'Registration failed', 'error');
        }
    } catch (error) {
        console.error('Registration error:', error);
        showToast('Registration failed. Please try again.', 'error');
    } finally {
        showLoading(false);
    }
}

async function logout() {
    try {
        await authenticatedFetch('/api/logout', { method: 'POST' });
        currentUser = null;
        clearAuthToken(); // Clear the stored token
        showToast('Logged out successfully', 'success');
        showLogin();
    } catch (error) {
        console.error('Logout error:', error);
        showToast('Logout failed', 'error');
    }
}

// UI navigation functions
function showLogin() {
    document.getElementById('login-section').style.display = 'flex';
    document.getElementById('register-section').style.display = 'none';
    document.getElementById('main-content').style.display = 'none';
    document.getElementById('mainNavbar').style.display = 'none'; // Hide navbar
}

function showRegister() {
    document.getElementById('login-section').style.display = 'none';
    document.getElementById('register-section').style.display = 'flex';
    document.getElementById('main-content').style.display = 'none';
    document.getElementById('mainNavbar').style.display = 'none'; // Hide navbar
}

function showMainContent() {
    document.getElementById('login-section').style.display = 'none';
    document.getElementById('register-section').style.display = 'none';
    document.getElementById('main-content').style.display = 'block';
    document.getElementById('mainNavbar').style.display = 'block'; // Show navbar
    
    // Update navigation
    document.getElementById('navUser').style.display = 'flex';
    document.getElementById('username').textContent = currentUser.username;
    
    // Show/hide admin features
    if (currentUser.role === 'admin') {
        document.body.classList.add('admin-user');
    }
}

function showSection(sectionName) {
    // Hide all sections
    document.querySelectorAll('.section').forEach(section => {
        section.classList.remove('active');
    });
    
    // Remove active class from nav links
    document.querySelectorAll('.nav-link').forEach(link => {
        link.classList.remove('active');
    });
    
    // Show selected section
    document.getElementById(sectionName).classList.add('active');
    
    // Add active class to nav link
    document.querySelector(`[onclick="showSection('${sectionName}')"]`).classList.add('active');
    
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
            document.getElementById('createTicketForm').reset();
            break;
    }
}

// Dashboard functions
async function loadDashboard() {
    try {
        showLoading(true);
          // Load stats
        const statsResponse = await authenticatedFetch('/api/stats');
        const stats = await statsResponse.json();
        
        document.getElementById('totalTickets').textContent = stats.total;
        document.getElementById('openTickets').textContent = stats.open;
        document.getElementById('progressTickets').textContent = stats.in_progress;
        document.getElementById('closedTickets').textContent = stats.closed;
        
        // Load recent tickets
        const ticketsResponse = await authenticatedFetch('/api/tickets');
        const tickets = await ticketsResponse.json();
        
        allTickets = tickets;
        displayRecentTickets(tickets.slice(0, 5));
        
    } catch (error) {
        console.error('Dashboard load error:', error);
        showToast('Failed to load dashboard', 'error');
    } finally {
        showLoading(false);
    }
}

function displayRecentTickets(tickets) {
    const container = document.getElementById('recentTicketsList');
    
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
                        <span><i class="fas fa-user"></i> ${escapeHtml(ticket.creator_name)}</span>
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

// Tickets functions
async function loadTickets() {
    try {
        showLoading(true);
          const response = await authenticatedFetch('/api/tickets');
        const tickets = await response.json();
        
        allTickets = tickets;
        displayTickets(tickets);
        
        // Load users for admin
        if (currentUser.role === 'admin') {
            const usersResponse = await authenticatedFetch('/api/users');
            allUsers = await usersResponse.json();
        }
        
    } catch (error) {
        console.error('Tickets load error:', error);
        showToast('Failed to load tickets', 'error');
    } finally {
        showLoading(false);
    }
}

function displayTickets(tickets) {
    const container = document.getElementById('ticketsList');
    
    if (tickets.length === 0) {
        container.innerHTML = '<p class="text-center">No tickets found</p>';
        return;
    }
    
    container.innerHTML = tickets.map(ticket => `
        <div class="ticket-item priority-${ticket.priority.toLowerCase()}" onclick="openTicketModal(${ticket.id})">
            <div class="ticket-header">
                <div>
                    <div class="ticket-title">#${ticket.id} - ${escapeHtml(ticket.title)}</div>
                    <div class="ticket-meta">
                        <span><i class="fas fa-user"></i> ${escapeHtml(ticket.creator_name)}</span>
                        <span><i class="fas fa-calendar"></i> ${formatDate(ticket.created_at)}</span>
                        ${ticket.category ? `<span><i class="fas fa-tag"></i> ${escapeHtml(ticket.category)}</span>` : ''}
                        ${ticket.assignee_name ? `<span><i class="fas fa-user-tie"></i> Assigned to ${escapeHtml(ticket.assignee_name)}</span>` : ''}
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

function filterTickets() {
    const statusFilter = document.getElementById('statusFilter').value;
    const priorityFilter = document.getElementById('priorityFilter').value;
    
    let filtered = allTickets;
    
    if (statusFilter) {
        filtered = filtered.filter(ticket => ticket.status === statusFilter);
    }
    
    if (priorityFilter) {
        filtered = filtered.filter(ticket => ticket.priority === priorityFilter);
    }
    
    displayTickets(filtered);
}

// Create ticket function
async function handleCreateTicket(event) {
    event.preventDefault();
    
    const title = document.getElementById('ticketTitle').value;
    const description = document.getElementById('ticketDescription').value;
    const priority = document.getElementById('ticketPriority').value;
    const category = document.getElementById('ticketCategory').value;
    
    try {
        showLoading(true);          const response = await authenticatedFetch('/api/tickets', {
            method: 'POST',
            body: JSON.stringify({ title, description, priority, category }),
        });
        
        const data = await response.json();
        
        if (response.ok) {
            showToast('Ticket created successfully!', 'success');
            document.getElementById('createTicketForm').reset();
            
            // Refresh dashboard if we're on it
            if (document.getElementById('dashboard').classList.contains('active')) {
                loadDashboard();
            }
        } else {
            if (response.status === 401) {
                showToast('Session expired. Please log in again.', 'error');
                setTimeout(() => {
                    currentUser = null;
                    showLogin();
                }, 2000);
            } else {
                showToast(data.error || 'Failed to create ticket', 'error');
            }
        }
    } catch (error) {
        console.error('Create ticket error:', error);
        showToast('Failed to create ticket', 'error');
    } finally {
        showLoading(false);
    }
}

// Modal functions
async function openTicketModal(ticketId) {
    const ticket = allTickets.find(t => t.id === ticketId);
    if (!ticket) return;
    
    try {
        showLoading(true);
          // Load comments
        const commentsResponse = await authenticatedFetch(`/api/tickets/${ticketId}/comments`);
        const comments = await commentsResponse.json();
        
        displayTicketModal(ticket, comments);
        document.getElementById('ticketModal').style.display = 'block';
        
    } catch (error) {
        console.error('Modal load error:', error);
        showToast('Failed to load ticket details', 'error');
    } finally {
        showLoading(false);
    }
}

function displayTicketModal(ticket, comments) {
    document.getElementById('modalTitle').textContent = `Ticket #${ticket.id} - ${ticket.title}`;
      const adminControls = currentUser.role === 'admin' ? `
        <div class="admin-controls">
            <h4>Admin Controls</h4>
            <div class="control-group">
                <label>Status:</label>
                <select id="modalStatus" onchange="updateTicket(${ticket.id})">
                    <option value="Open" ${ticket.status === 'Open' ? 'selected' : ''}>Open</option>
                    <option value="In Progress" ${ticket.status === 'In Progress' ? 'selected' : ''}>In Progress</option>
                    <option value="Closed" ${ticket.status === 'Closed' ? 'selected' : ''}>Closed</option>
                </select>
                
                <label>Priority:</label>
                <select id="modalPriority" onchange="updateTicket(${ticket.id})">
                    <option value="Low" ${ticket.priority === 'Low' ? 'selected' : ''}>Low</option>
                    <option value="Medium" ${ticket.priority === 'Medium' ? 'selected' : ''}>Medium</option>
                    <option value="High" ${ticket.priority === 'High' ? 'selected' : ''}>High</option>
                    <option value="Critical" ${ticket.priority === 'Critical' ? 'selected' : ''}>Critical</option>
                </select>
                
                <label>Assign to:</label>
                <select id="modalAssignee" onchange="updateTicket(${ticket.id})">
                    <option value="">Unassigned</option>
                    ${allUsers.map(user => `
                        <option value="${user.id}" ${ticket.assigned_to === user.id ? 'selected' : ''}>
                            ${escapeHtml(user.username)}
                        </option>
                    `).join('')}
                </select>
            </div>
            <div class="admin-actions">
                <button onclick="deleteTicket(${ticket.id})" class="btn-delete">
                    <i class="fas fa-trash"></i> Delete Ticket
                </button>
            </div>
        </div>
    ` : '';
    
    document.getElementById('ticketDetails').innerHTML = `
        <div class="ticket-detail">
            <div class="detail-row">
                <span class="detail-label">Status:</span>
                <span class="detail-value">
                    <span class="status-badge status-${ticket.status.toLowerCase().replace(' ', '-')}">${ticket.status}</span>
                </span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Priority:</span>
                <span class="detail-value">
                    <span class="priority-badge priority-${ticket.priority.toLowerCase()}">${ticket.priority}</span>
                </span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Category:</span>
                <span class="detail-value">${ticket.category || 'Not specified'}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Created by:</span>
                <span class="detail-value">${escapeHtml(ticket.creator_name)}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Assigned to:</span>
                <span class="detail-value">${ticket.assignee_name ? escapeHtml(ticket.assignee_name) : 'Unassigned'}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Created:</span>
                <span class="detail-value">${formatDate(ticket.created_at)}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Last Updated:</span>
                <span class="detail-value">${formatDate(ticket.updated_at)}</span>
            </div>
        </div>
        
        <div class="ticket-description">
            ${escapeHtml(ticket.description).replace(/\n/g, '<br>')}
        </div>
        
        ${adminControls}
    `;
    
    displayComments(comments);
}

function displayComments(comments) {
    const container = document.getElementById('commentsList');
    
    if (comments.length === 0) {
        container.innerHTML = '<p>No comments yet.</p>';
        return;
    }
    
    container.innerHTML = comments.map(comment => `
        <div class="comment">
            <div class="comment-header">
                ${escapeHtml(comment.username)}
                <span class="comment-time">${formatDate(comment.created_at)}</span>
            </div>
            <div class="comment-content">
                ${escapeHtml(comment.comment).replace(/\n/g, '<br>')}
            </div>
        </div>
    `).join('');
}

async function updateTicket(ticketId) {
    const status = document.getElementById('modalStatus')?.value;
    const priority = document.getElementById('modalPriority')?.value;
    const assigned_to = document.getElementById('modalAssignee')?.value || null;
    
    try {        const response = await authenticatedFetch(`/api/tickets/${ticketId}`, {
            method: 'PUT',
            body: JSON.stringify({ status, priority, assigned_to }),
        });
        
        const data = await response.json();
        
        if (response.ok) {
            showToast('Ticket updated successfully!', 'success');
            
            // Refresh tickets data
            await loadTickets();
            
            // Update the ticket in allTickets array
            const ticketIndex = allTickets.findIndex(t => t.id === ticketId);
            if (ticketIndex !== -1) {
                allTickets[ticketIndex].status = status;
                allTickets[ticketIndex].priority = priority;
                allTickets[ticketIndex].assigned_to = assigned_to;
                
                // Find assignee name
                const assignee = allUsers.find(u => u.id == assigned_to);
                allTickets[ticketIndex].assignee_name = assignee ? assignee.username : null;
                
                // Refresh modal display
                openTicketModal(ticketId);
            }
        } else {
            showToast(data.error || 'Failed to update ticket', 'error');
        }
    } catch (error) {
        console.error('Update ticket error:', error);
        showToast('Failed to update ticket', 'error');
    }
}

async function deleteTicket(ticketId) {
    // Confirm deletion
    if (!confirm('Are you sure you want to delete this ticket? This action cannot be undone.')) {
        return;
    }
      try {
        showLoading(true);
        
        const response = await authenticatedFetch(`/api/tickets/${ticketId}`, {
            method: 'DELETE',
        });
        
        const data = await response.json();
        
        if (response.ok) {
            showToast('Ticket deleted successfully!', 'success');
            
            // Close the modal
            closeModal();
            
            // Refresh the tickets list
            await loadTickets();
            
            // If we're on the dashboard, refresh it too
            if (document.getElementById('dashboard').classList.contains('active')) {
                await loadDashboard();
            }
        } else {
            if (response.status === 403) {
                showToast('Only administrators can delete tickets', 'error');
            } else {
                showToast(data.error || 'Failed to delete ticket', 'error');
            }
        }
    } catch (error) {
        console.error('Delete ticket error:', error);
        showToast('Failed to delete ticket', 'error');
    } finally {
        showLoading(false);
    }
}

async function handleAddComment(event) {
    event.preventDefault();
    
    const comment = document.getElementById('newComment').value.trim();
    if (!comment) return;
    
    // Get ticket ID from modal title
    const modalTitle = document.getElementById('modalTitle').textContent;
    const ticketId = modalTitle.match(/#(\d+)/)[1];
      try {
        const response = await authenticatedFetch(`/api/tickets/${ticketId}/comments`, {
            method: 'POST',
            body: JSON.stringify({ comment }),
        });
        
        const data = await response.json();
        
        if (response.ok) {
            showToast('Comment added successfully!', 'success');
            document.getElementById('newComment').value = '';
            
            // Reload comments
            const commentsResponse = await authenticatedFetch(`/api/tickets/${ticketId}/comments`);
            const comments = await commentsResponse.json();
            displayComments(comments);
        } else {
            showToast(data.error || 'Failed to add comment', 'error');
        }
    } catch (error) {
        console.error('Add comment error:', error);
        showToast('Failed to add comment', 'error');
    }
}

function closeModal() {
    document.getElementById('ticketModal').style.display = 'none';
}

// Utility functions
function showLoading(show) {
    document.getElementById('loadingSpinner').style.display = show ? 'block' : 'none';
}

function showToast(message, type = 'info') {
    const toast = document.getElementById('toast');
    toast.textContent = message;
    toast.className = `toast ${type}`;
    toast.style.display = 'block';
    
    setTimeout(() => {
        toast.style.display = 'none';
    }, 3000);
}

function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}
