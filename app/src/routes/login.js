const express = require("express");
const rateLimit = require("express-rate-limit");

const router = express.Router();

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    error: "Too many authentication attempts. Please try again later."
  }
});

router.post("/login", loginLimiter, (req, res) => {
  const { username, password } = req.body;

  if (username === "admin" && password === "FleetSec123!") {
    return res.status(200).json({
      authenticated: true,
      message: "Authentication successful"
    });
  }

  return res.status(401).json({
    authenticated: false,
    error: "Invalid credentials"
  });
});

module.exports = {
  router,
  loginLimiter
};
