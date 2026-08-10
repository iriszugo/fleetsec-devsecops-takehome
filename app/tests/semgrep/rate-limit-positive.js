const express = require("express");

const app = express();

app.post("/login", (req, res) => {
  return res.status(200).json({
    authenticated: true
  });
});

module.exports = app;
