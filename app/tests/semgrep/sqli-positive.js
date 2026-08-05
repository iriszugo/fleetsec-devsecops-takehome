const sqlite3 = require("sqlite3").verbose();

const db = new sqlite3.Database(":memory:");

const userInput = req.query.id;

const query = `SELECT * FROM users WHERE id = '${userInput}'`;

db.all(query, [], (err, rows) => {
  console.log(rows);
});
