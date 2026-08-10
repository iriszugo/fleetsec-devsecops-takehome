const express = require("express");
const helmet = require("helmet");
const db = require("./database");

const sqliRouter = require("./routes/sqli");
const { router: systemRouter } = require("./routes/system");
const { router: loginRouter } = require("./routes/login");
const authRouter = require("./routes/auth");

const app = express();

app.disable("x-powered-by");

app.use(helmet());

app.use(
  express.json({
    limit: "10kb"
  })
);

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

// Ruta segura contra SQL Injection.
app.use("/secure/users", sqliRouter);

// Ruta segura contra Command Injection.
app.use("/api/v1/system", systemRouter);

// Login con rate limiting.
app.use("/auth", loginRouter);

// Emisión y validación JWT para DAST autenticado.
app.use("/auth", authRouter);

// Manejador básico de errores.
app.use((err, req, res, next) => {
  console.error(err);

  return res.status(500).json({
    error: "Internal Server Error"
  });
});

module.exports = app;
