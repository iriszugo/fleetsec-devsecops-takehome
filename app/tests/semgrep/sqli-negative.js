const sqlite3 = require("sqlite3").verbose();

const db = new sqlite3.Database(":memory:");

const userInput = req.query.id;

db.all(
  "SELECT * FROM users WHERE id = ?",
  [userInput],
  (err, rows) => {
    console.log(rows);
  }
);
