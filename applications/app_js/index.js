const express = require('express');
const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
const app = express();
const port = process.env.PORT || 3000;

app.set('view engine', 'ejs');
app.use(express.urlencoded({ extended: true }));

// Database connection with SSL
const dbConfig = {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    ssl: {
        ca: fs.readFileSync(path.join(__dirname, 'BaltimoreCyberTrustRoot.crt.pem')),
        rejectUnauthorized: true
    }
};

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).send('OK');
});

// Initialize database and table
async function initDb() {
    console.log('Connecting to DB with config:', {
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        database: process.env.DB_NAME
    });

    try {
        const db = await mysql.createConnection({ ...dbConfig, database: null });
        await db.query(`CREATE DATABASE IF NOT EXISTS ${dbConfig.database}`);
        await db.end();

        const connection = await mysql.createConnection(dbConfig);
        await connection.query(`
      CREATE TABLE IF NOT EXISTS messages (
        id INT AUTO_INCREMENT PRIMARY KEY,
        content VARCHAR(255) NOT NULL
      )
    `);
        await connection.end();
        console.log('Database initialized successfully');
    } catch (error) {
        console.error('Database initialization failed:', error);
        throw error; // Ensure the app exits with an error code if DB fails
    }
}

initDb().catch((error) => {
    console.error('Failed to initialize app:', error);
    process.exit(1); // Explicitly exit with error code 1
});

// Routes
app.get('/', async (req, res) => {
    try {
        const connection = await mysql.createConnection(dbConfig);
        const [rows] = await connection.query('SELECT * FROM messages');
        await connection.end();
        res.render('index', { messages: rows });
    } catch (error) {
        console.error('Error fetching messages:', error);
        res.status(500).send('Internal Server Error');
    }
});

app.post('/add', async (req, res) => {
    try {
        const { content } = req.body;
        const connection = await mysql.createConnection(dbConfig);
        await connection.query('INSERT INTO messages (content) VALUES (?)', [content]);
        await connection.end();
        res.redirect('/');
    } catch (error) {
        console.error('Error adding message:', error);
        res.status(500).send('Internal Server Error');
    }
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});