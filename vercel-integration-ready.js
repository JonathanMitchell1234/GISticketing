// Final Frontend Integration Code for Vercel
// Your backend is confirmed working at: https://192.168.21.94:3443

// ===================================================================
// READY-TO-USE CONFIGURATION - COPY THIS TO YOUR VERCEL FRONTEND
// ===================================================================

const API_CONFIG = {
    BASE_URL: 'https://192.168.21.94:3443',
    ENDPOINTS: {
        LOGIN: '/api/login',
        REGISTER: '/api/register',
        LOGOUT: '/api/logout',
        ME: '/api/me',
        TICKETS: '/api/tickets',
        USERS: '/api/users',
        STATS: '/api/stats',
        COMMENTS: (ticketId) => `/api/tickets/${ticketId}/comments`
    }
};

// Enhanced API request function with better error handling
async function apiRequest(endpoint, options = {}) {
    const url = `${API_CONFIG.BASE_URL}${endpoint}`;
    
    const defaultConfig = {
        credentials: 'include', // Important for cookies
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }
    };
    
    // Merge configurations
    const config = {
        ...defaultConfig,
        ...options,
        headers: {
            ...defaultConfig.headers,
            ...(options.headers || {})
        }
    };
    
    // Add auth token if available (fallback for when cookies don't work)
    const token = localStorage.getItem('authToken');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    
    try {
        console.log(`Making API request to: ${url}`);
        const response = await fetch(url, config);
        
        // Handle different response types
        const contentType = response.headers.get('content-type');
        let data;
        
        if (contentType && contentType.includes('application/json')) {
            data = await response.json();
        } else {
            data = await response.text();
        }
        
        // Store auth token if provided
        if (data && data.token) {
            localStorage.setItem('authToken', data.token);
            console.log('Auth token stored');
        }
        
        // Handle errors
        if (!response.ok) {
            console.error(`API Error ${response.status}:`, data);
            throw new Error(data.error || `Request failed with status ${response.status}`);
        }
        
        console.log('API request successful');
        return data;
        
    } catch (error) {
        console.error('API request failed:', error);
        
        // Handle specific error types
        if (error.name === 'TypeError' && error.message.includes('fetch')) {
            throw new Error('Cannot connect to backend server. Please check if the server is running.');
        }
        
        throw error;
    }
}

// ===================================================================
// EXAMPLE USAGE IN YOUR REACT/VERCEL FRONTEND
// ===================================================================

// Login function
async function login(username, password) {
    try {
        const data = await apiRequest(API_CONFIG.ENDPOINTS.LOGIN, {
            method: 'POST',
            body: JSON.stringify({ username, password })
        });
        
        console.log('Login successful:', data.user);
        return data;
    } catch (error) {
        console.error('Login failed:', error.message);
        throw error;
    }
}

// Get tickets function
async function getTickets() {
    try {
        const tickets = await apiRequest(API_CONFIG.ENDPOINTS.TICKETS);
        console.log('Tickets loaded:', tickets.length);
        return tickets;
    } catch (error) {
        console.error('Failed to load tickets:', error.message);
        throw error;
    }
}

// Create ticket function
async function createTicket(ticketData) {
    try {
        const result = await apiRequest(API_CONFIG.ENDPOINTS.TICKETS, {
            method: 'POST',
            body: JSON.stringify(ticketData)
        });
        
        console.log('Ticket created:', result);
        return result;
    } catch (error) {
        console.error('Failed to create ticket:', error.message);
        throw error;
    }
}

// Get dashboard stats
async function getDashboardStats() {
    try {
        const stats = await apiRequest(API_CONFIG.ENDPOINTS.STATS);
        console.log('Dashboard stats:', stats);
        return stats;
    } catch (error) {
        console.error('Failed to load dashboard stats:', error.message);
        throw error;
    }
}

// Check authentication status
async function checkAuth() {
    try {
        const userData = await apiRequest(API_CONFIG.ENDPOINTS.ME);
        console.log('User authenticated:', userData.user);
        return userData.user;
    } catch (error) {
        console.log('User not authenticated');
        localStorage.removeItem('authToken'); // Clean up invalid token
        return null;
    }
}

// Logout function
async function logout() {
    try {
        await apiRequest(API_CONFIG.ENDPOINTS.LOGOUT, {
            method: 'POST'
        });
        
        localStorage.removeItem('authToken');
        console.log('Logout successful');
    } catch (error) {
        console.error('Logout error:', error.message);
        // Clean up anyway
        localStorage.removeItem('authToken');
    }
}

// ===================================================================
// EXPORT FOR MODULE SYSTEMS (React, etc.)
// ===================================================================

if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        API_CONFIG,
        apiRequest,
        login,
        getTickets,
        createTicket,
        getDashboardStats,
        checkAuth,
        logout
    };
}

// ===================================================================
// EXAMPLE REACT COMPONENT USAGE
// ===================================================================

/*
// Example React component
import React, { useState, useEffect } from 'react';
import { login, getTickets, checkAuth } from './api-config';

function App() {
    const [user, setUser] = useState(null);
    const [tickets, setTickets] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        // Check if user is already authenticated
        checkAuth().then(userData => {
            if (userData) {
                setUser(userData);
                loadTickets();
            } else {
                setLoading(false);
            }
        });
    }, []);

    const loadTickets = async () => {
        try {
            const ticketData = await getTickets();
            setTickets(ticketData);
        } catch (error) {
            console.error('Failed to load tickets:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleLogin = async (username, password) => {
        try {
            const result = await login(username, password);
            setUser(result.user);
            loadTickets();
        } catch (error) {
            alert('Login failed: ' + error.message);
        }
    };

    if (loading) return <div>Loading...</div>;
    
    return (
        <div>
            {user ? (
                <div>
                    <h1>Welcome, {user.username}!</h1>
                    <div>Tickets: {tickets.length}</div>
                </div>
            ) : (
                <LoginForm onLogin={handleLogin} />
            )}
        </div>
    );
}
*/

console.log('🎉 Backend Configuration Complete!');
console.log('Backend URL:', API_CONFIG.BASE_URL);
console.log('Ready to integrate with your Vercel frontend!');
