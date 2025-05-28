# IT Ticketing System

A modern, web-based IT help desk ticketing system built with Node.js, Express, and SQLite.

## Features

- **User Authentication**: Secure login and registration system
- **Role-Based Access**: Admin and regular user roles with different permissions
- **Ticket Management**: Create, view, update, and track tickets
- **Priority Levels**: Low, Medium, High, and Critical priority levels
- **Status Tracking**: Open, In Progress, and Closed ticket statuses
- **Comments System**: Add comments and updates to tickets
- **Assignment System**: Admins can assign tickets to users
- **Dashboard**: Overview of ticket statistics and recent activity
- **Responsive Design**: Works on desktop and mobile devices

## Demo Credentials

- **Admin**: username: `admin`, password: `admin123`

## Installation

1. Clone or download this repository
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   npm install
   ```

## Usage

### Basic Usage
1. Start the server:
   ```bash
   npm start
   ```
   
   For development with auto-restart:
   ```bash
   npm run dev
   ```

2. Open your browser and go to `http://localhost:3000`

### Network Access with mDNS (.local domain)

For easy network access, this system supports mDNS (Bonjour) service discovery:

1. **Windows**: Run the setup script and start the server:
   ```bash
   start-helpdesk-local.bat
   ```
   or
   ```bash
   powershell -ExecutionPolicy Bypass -File "./setup-mdns.ps1"
   npm start
   ```

2. **Access from any device on your network**:
   - **Recommended**: `http://helpdesk.local:3000`
   - **Fallback**: `http://[your-ip]:3000`
   - **Local only**: `http://localhost:3000`

### Client Device Requirements for .local domains:
- **Windows**: Install iTunes or Bonjour Print Services from Apple
- **macOS**: Built-in support
- **iOS/Android**: Most modern browsers support .local domains
- **Linux**: Install avahi-daemon package

### Troubleshooting Network Access:
1. Wait 30-60 seconds after starting the server for mDNS to propagate
2. Ensure Windows Firewall allows Node.js (port 3000)
3. If helpdesk.local doesn't work, use the IP address as fallback
4. Check that client devices have Bonjour/mDNS support installed

3. Log in with the admin credentials or register a new account

## Project Structure

```
├── server.js                    # Main server file with mDNS support
├── package.json                 # Dependencies and scripts
├── ticketing.db                 # SQLite database (created automatically)
├── setup-mdns.ps1              # PowerShell script for mDNS setup
├── start-network.bat            # Batch file for network startup
├── start-helpdesk-local.bat     # Batch file for mDNS startup
├── public/
│   ├── index.html               # Main HTML file
│   ├── styles.css               # CSS styles
│   ├── script.js                # Frontend JavaScript
│   └── GIS-logo-3.png          # Logo image
└── README.md                    # This file
```

## Database Schema

The system uses SQLite with the following tables:

- **users**: User accounts and authentication
- **tickets**: Ticket information and metadata
- **comments**: Comments and updates on tickets

## API Endpoints

### Authentication
- `POST /api/register` - Register new user
- `POST /api/login` - User login
- `POST /api/logout` - User logout
- `GET /api/me` - Get current user info

### Tickets
- `GET /api/tickets` - Get all tickets (filtered by user role)
- `POST /api/tickets` - Create new ticket
- `PUT /api/tickets/:id` - Update ticket (admin only)
- `GET /api/tickets/:id/comments` - Get ticket comments
- `POST /api/tickets/:id/comments` - Add comment to ticket

### Admin
- `GET /api/users` - Get all users (admin only)
- `GET /api/stats` - Get dashboard statistics

## Features for Users

- Create new tickets with detailed descriptions
- View their own tickets and assigned tickets
- Add comments to tickets
- Track ticket status and priority

## Features for Admins

- View all tickets in the system
- Assign tickets to users
- Change ticket status (Open, In Progress, Closed)
- Modify ticket priority levels
- Access to user management
- Dashboard with system statistics

## Technologies Used

- **Backend**: Node.js, Express.js
- **Database**: SQLite3
- **Authentication**: JWT (JSON Web Tokens)
- **Frontend**: Vanilla HTML, CSS, JavaScript
- **Styling**: Modern CSS with gradients and animations
- **Icons**: Font Awesome

## Security Features

- Password hashing with bcryptjs
- JWT-based authentication
- HTTP-only cookies for token storage
- Input sanitization and validation
- Role-based access control

## Customization

You can easily customize the system by:

1. **Adding Categories**: Modify the category options in the frontend
2. **Changing Priorities**: Update priority levels in both frontend and backend
3. **Styling**: Modify `styles.css` for different themes
4. **Adding Fields**: Extend the database schema and forms
5. **Email Notifications**: Integrate with email services for notifications

## Production Deployment

For production deployment:

1. Change the JWT_SECRET in `server.js`
2. Use environment variables for configuration
3. Set up a production database (PostgreSQL, MySQL)
4. Configure HTTPS
5. Set up proper logging
6. Use a process manager like PM2

## License

MIT License - feel free to use this project for your organization's needs.

## Support

This is a basic ticketing system suitable for small to medium-sized IT departments. For enterprise features, consider extending the system or using commercial solutions.
# GISticketing
