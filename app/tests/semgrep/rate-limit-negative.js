const express = require("express");
const rateLimit = require("express-rate-limit");

const app = express();

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5
});

app.post("/login", limiter, (req, res) => {
  return res.status(200).json({
    authenticated: true
  });
});

module.exports = app;
