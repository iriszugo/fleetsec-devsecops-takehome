const express = require("express");
const jwt = require("jsonwebtoken");

const router = express.Router();

function getJwtSecret() {
  const secret = process.env.JWT_SECRET;

  if (!secret) {
    throw new Error("JWT_SECRET environment variable is required");
  }

  return secret;
}

router.post("/token", (req, res) => {
  try {
    const { userId = "1001", role = "user" } = req.body;

    const token = jwt.sign(
      {
        sub: userId,
        role
      },
      getJwtSecret(),
      {
        algorithm: "HS256",
        expiresIn: "15m",
        issuer: "fleetsec",
        audience: "fleetsec-api"
      }
    );

    return res.status(200).json({
      tokenType: "Bearer",
      expiresIn: 900,
      token
    });
  } catch (error) {
    return res.status(500).json({
      error: "JWT configuration unavailable"
    });
  }
});

router.get("/profile", (req, res) => {
  const authorization = req.headers.authorization || "";
  const token = authorization.replace(/^Bearer\s+/i, "");

  if (!token) {
    return res.status(401).json({
      error: "Missing bearer token"
    });
  }

  try {
    const decoded = jwt.verify(token, getJwtSecret(), {
      algorithms: ["HS256"],
      issuer: "fleetsec",
      audience: "fleetsec-api"
    });

    return res.status(200).json({
      authenticatedUser: decoded
    });
  } catch (error) {
    return res.status(401).json({
      error: "Invalid or expired token"
    });
  }
});

module.exports = router;
