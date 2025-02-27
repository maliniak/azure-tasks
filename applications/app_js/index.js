const express = require('express');
const mysql = require('mysql2/promise');
const app = express();
const port = process.env.PORT || 3000;

app.set('view engine', 'ejs');
app.use(express.urlencoded({ extended: true }));

// Database connection
const dbConfig = {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
};

// Initialize database and table
async function initDb() {
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
}

initDb().catch(console.error);

// Routes
app.get('/', async (req, res) => {
    const connection = await mysql.createConnection(dbConfig);
    const [rows] = await connection.query('SELECT * FROM messages');
    await connection.end();
    res.render('index', { messages: rows });
});

app.post('/add', async (req, res) => {
    const { content } = req.body;
    const connection = await mysql.createConnection(dbConfig);
    await connection.query('INSERT INTO messages (content) VALUES (?)', [content]);
    await connection.end();
    res.redirect('/');
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
    console.log('Connecting to DB with config:', {
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        database: process.env.DB_NAME
    });
});