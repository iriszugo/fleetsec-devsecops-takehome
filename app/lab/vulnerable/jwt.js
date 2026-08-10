const express = require("express");
const jwt = require("jsonwebtoken");

const router = express.Router();

/**
 * LABORATORIO VULNERABLE CONTROLADO
 * CWE-345: Insufficient Verification of Data Authenticity
 * Escenario: aceptación de JWT sin verificar firma.
 */

router.post("/token", (req, res) => {
  const { userId = "1001", role = "user" } = req.body;

  const token = jwt.sign(
    {
      sub: userId,
      role
    },
    "",
    {
      algorithm: "none"
    }
  );

  return res.status(200).json({
    laboratory: true,
    vulnerable: true,
    token
  });
});

router.get("/profile", (req, res) => {
  const authorization = req.headers.authorization || "";
  const token = authorization.replace(/^Bearer\s+/i, "");

  if (!token) {
    return res.status(401).json({
      error: "Missing bearer token"
    });
  }

  const decoded = jwt.decode(token);

  if (!decoded) {
    return res.status(401).json({
      error: "Invalid token"
    });
  }

  return res.status(200).json({
    laboratory: true,
    vulnerable: true,
    authenticatedUser: decoded
  });
});

module.exports = router;
