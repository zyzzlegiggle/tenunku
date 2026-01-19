const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');
const bodyParser = require('body-parser');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());

// Database Setup
const db = new sqlite3.Database('tenunku.db', (err) => {
    if (err) {
        console.error('Error opening database', err);
    } else {
        console.log('Connected to SQLite database');
        createTables();
    }
});

function createTables() {
    db.run(`CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        fullName TEXT,
        phone TEXT UNIQUE,
        email TEXT,
        password TEXT,
        role TEXT,
        otp TEXT,
        isVerified INTEGER DEFAULT 0
    )`);
}

// Routes

// Register
app.post('/auth/register', (req, res) => {
    const { fullName, phone, email, password, role } = req.body;
    const id = uuidv4();
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    // In a real app, hash password and send OTP via SMS/Email
    console.log(`[Mock OTP] Generated for ${phone}: ${otp}`);

    // Insert user
    // For "disable otp for now", we might want to set isVerified to 1 immediately?
    // User requested: "disable otp for now but make the function in the server". 
    // So we will store the OTP but perhaps return success assuming verification will be skipped or done silently.
    
    // However, if we skip UI for OTP, the user is effectively "verified" or we just don't check it on login.
    // Let's set isVerified = 1 for convenience now, or just ignore it in login.
    
    const stmt = db.prepare('INSERT INTO users (id, fullName, phone, email, password, role, otp, isVerified) VALUES (?, ?, ?, ?, ?, ?, ?, ?)');
    stmt.run(id, fullName, phone, email, password, role, otp, 1, function(err) {
        if (err) {
            console.error(err);
            return res.status(400).json({ error: 'User already exists or other error' });
        }
        res.json({ message: 'Registration successful', userId: id, token: 'mock-token-' + id });
    });
    stmt.finalize();
});

// Login
app.post('/auth/login', (req, res) => {
    const { username, password, role } = req.body; 
    // Note: Frontend sends "username" (which seems to be name or phone?)
    // In Register we took phone/email. Let's assume login uses 'phone' or 'email' as username?
    // The design says "Username" in the placeholder "Masukkan Nama Lengkap" (Enter Full Name) which is odd for login.
    // Usually it's Email or Phone. Listing implies "Username" but placeholder says "Name".
    // I'll assume we map 'username' input to 'fullName' or 'phone' in DB for now. 
    // Let's check against 'fullName' since that's what the UI asks for in Register.
    // Actually Login UI says "Username" > "Masukkan Nama Lengkap". 
    // I'll check against fullName.

    db.get('SELECT * FROM users WHERE fullName = ? AND password = ? AND role = ?', [username, password, role], (err, row) => {
        if (err) {
            res.status(500).json({ error: 'Internal server error' });
        } else if (row) {
            res.json({ message: 'Login successful', userId: row.id, token: 'mock-token-' + row.id });
        } else {
            res.status(401).json({ error: 'Invalid credentials' });
        }
    });
});

// Verify OTP (Placeholder)
app.post('/auth/verify-otp', (req, res) => {
    const { phone, otp } = req.body;
    db.get('SELECT * FROM users WHERE phone = ? AND otp = ?', [phone, otp], (err, row) => {
        if (err || !row) {
            return res.status(400).json({ error: 'Invalid OTP' });
        }
        // Update verified status
        db.run('UPDATE users SET isVerified = 1 WHERE id = ?', [row.id], (err) => {
            if (err) {
                res.status(500).json({ error: 'Error updating user' });
            } else {
                res.json({ message: 'Verification successful' });
            }
        });
    });
});

app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
