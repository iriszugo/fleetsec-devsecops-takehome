const express = require("express");

const router = express.Router();
const db = require("../database");

/*
 * SECURE IMPLEMENTATION
 *
 * CWE-89: SQL Injection
 * Consulta parametrizada mediante marcador ?.
 */

router.get("/search", (req, res) => {
  const username = req.query.username || "";

  const query =
    "SELECT id, username, role FROM users WHERE username = ?";

  db.all(query, [username], (err, rows) => {
    if (err) {
      return res.status(500).json({
        error: "Database query failed"
      });
    }

    return res.status(200).json({
      laboratory: false,
      secure: true,
      users: rows
    });
  });
});

module.exports = router;
