const express = require("express");

const router = express.Router();

/**
 * LABORATORIO VULNERABLE CONTROLADO
 * CWE-639
 * Insecure Direct Object Reference (IDOR)
 */

const users = {
  "1": {
    id: 1,
    owner: 1,
    name: "Alice",
    role: "user"
  },
  "2": {
    id: 2,
    owner: 2,
    name: "Bob",
    role: "admin"
  }
};

router.get("/users/:id/profile", (req, res) => {
  const user = users[req.params.id];

  if (!user) {
    return res.status(404).json({
      error: "User not found"
    });
  }

  return res.status(200).json({
    laboratory: true,
    vulnerable: true,
    profile: user
  });
});

module.exports = router;
