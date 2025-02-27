const assert = require('assert');
const mysql = require('mysql2/promise');

describe('Database Connection Test', () => {
    it('should connect to the MySQL database', async () => {
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.DB_NAME
        });
        await connection.ping();
        await connection.end();
        assert.ok(true, 'Database connection successful');
    });
});