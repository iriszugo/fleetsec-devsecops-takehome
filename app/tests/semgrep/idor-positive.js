const users = {
  1: { id: 1, name: "Alice" },
  2: { id: 2, name: "Bob" }
};

function getProfile(req) {
  const profile = users[req.params.id];

  return profile;
}

module.exports = {
  getProfile
};
