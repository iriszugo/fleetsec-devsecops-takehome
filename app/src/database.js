const sqlite3 = require("sqlite3").verbose();

const db = new sqlite3.Database(":memory:");

db.serialize(() => {
    db.run(`
        CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            username TEXT NOT NULL,
            role TEXT NOT NULL
        );
    `);

    db.run(`
        INSERT INTO users (username, role)
        VALUES
        ('admin', 'administrator'),
        ('alice', 'analyst'),
        ('bob', 'operator');
    `);
});

module.exports = db;
