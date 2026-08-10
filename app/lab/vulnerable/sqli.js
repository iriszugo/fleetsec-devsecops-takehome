const express = require("express");

const router = express.Router();
const db = require("../../src/database");

/*
 * INTENTIONAL VULNERABILITY — LAB USE ONLY
 *
 * CWE-89: SQL Injection
 *
 * La entrada controlada por el usuario se concatena directamente
 * dentro de la consulta SQL.
 */

router.get("/search", (req, res) => {
  const username = req.query.username || "";

  const query =
    `SELECT id, username, role FROM users WHERE username = '${username}'`;

  db.all(query, [], (err, rows) => {
    if (err) {
      return res.status(500).json({
        error: "Laboratory query failed"
      });
    }

    return res.status(200).json({
      laboratory: true,
      vulnerable: true,
      cwe: "CWE-89",
      users: rows
    });
  });
});

module.exports = router;
