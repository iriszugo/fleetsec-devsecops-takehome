const express = require("express");

const router = express.Router();

/**
 * LABORATORIO VULNERABLE CONTROLADO
 * CWE-307: Improper Restriction of Excessive Authentication Attempts
 * Escenario: endpoint de autenticación sin limitación de intentos.
 */

router.post("/login", (req, res) => {
  const { username, password } = req.body;

  if (username === "admin" && password === "FleetSec123!") {
    return res.status(200).json({
      laboratory: true,
      vulnerable: true,
      authenticated: true
    });
  }

  return res.status(401).json({
    laboratory: true,
    vulnerable: true,
    authenticated: false,
    error: "Invalid credentials"
  });
});

module.exports = router;
