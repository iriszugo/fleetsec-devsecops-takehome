const users = {
  1: { id: 1, owner: 1, name: "Alice" },
  2: { id: 2, owner: 2, name: "Bob" }
};

function getProfile(req, authenticatedUser) {
  const profile = users[req.params.id];

  if (!profile) {
    return null;
  }

  const isOwner =
    profile.owner === authenticatedUser.id;

  const isAdmin =
    authenticatedUser.role === "admin";

  if (!isOwner && !isAdmin) {
    throw new Error("Access denied");
  }

  return profile;
}

module.exports = {
  getProfile
};
