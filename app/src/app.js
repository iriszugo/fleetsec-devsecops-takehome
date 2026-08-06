const express = require("express");
const db = require("./database");

const sqliRouter = require("./routes/sqli");

const app = express();

app.use(express.json());

app.get("/", (req, res) => {
  return res.json({
    application: "FleetSec Vulnerable Lab",
    status: "running"
  });
});

app.get("/health", (req, res) => {
  return res.status(200).json({
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

      return res.status(200).json(rows);
    }
  );
});

// Ruta segura SQL Injection.
app.use("/secure/users", sqliRouter);

// Manejador básico de errores.
app.use((err, req, res, next) => {
  console.error(err);

  return res.status(500).json({
    error: "Internal Server Error"
  });
});

module.exports = app;
