const express = require("express");
const db = require("./database");

const app = express();

app.use(express.json());

app.get("/", (req, res) => {
    res.json({
        application: "FleetSec Vulnerable Lab",
        status: "running"
    });
});

app.get("/health", (req, res) => {
    res.status(200).json({
        status: "UP",
        timestamp: new Date().toISOString()
    });
});

// Endpoint seguro de referencia.
app.get("/users", (req, res) => {
    db.all(
        "SELECT id, username, role FROM users",
        [],
        (err, rows) => {
            if (err) {
                return res.status(500).json({
                    error: "Database query failed"
                });
            }

            return res.json(rows);
        }
    );
});

/*
 * INTENTIONAL VULNERABILITY — LAB USE ONLY
 * CWE-89: Improper Neutralization of Special Elements used in an SQL Command.
 *
 * La entrada controlada por el usuario se concatena directamente en la consulta.
 * Este endpoint existe únicamente para validar explotación, Semgrep y remediación.
 */
app.get("/lab/users/search", (req, res) => {
    const username = req.query.username || "";

    const query =
        `SELECT id, username, role FROM users WHERE username = '${username}'`;

    db.all(query, [], (err, rows) => {
        if (err) {
            return res.status(500).json({
                error: "Laboratory query failed"
            });
        }

        return res.json({
            laboratory: true,
            cwe: "CWE-89",
            users: rows
        });
    });
});

// Manejador básico de errores.
app.use((err, req, res, next) => {
    console.error(err);

    return res.status(500).json({
        error: "Internal Server Error"
    });
});

module.exports = app;
