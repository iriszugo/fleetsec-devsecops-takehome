const jwt = require("jsonwebtoken");

const payload = {
  sub: "1001",
  role: "admin"
};

const token = jwt.sign(payload, "", {
  algorithm: "none"
});

const decoded = jwt.decode(token);

console.log(decoded);
