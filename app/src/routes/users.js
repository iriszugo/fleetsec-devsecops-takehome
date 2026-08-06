const express = require("express");

const router = express.Router();

/**
 * RUTA SEGURA
 * CWE-639
 * Owner-Based Access Control
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
  const requestedId = req.params.id;

  const authenticatedUser = req.user;

  const profile = users[requestedId];

  if (!profile) {
    return res.status(404).json({
      error: "User not found"
    });
  }

  const isOwner = Number(profile.owner) === authenticatedUser.id;
  const isAdmin = authenticatedUser.role === "admin";

  if (!isOwner && !isAdmin) {
    return res.status(403).json({
      error: "Access denied"
    });
  }

  return res.status(200).json({
    profile
  });
});

module.exports = {
  router
};
