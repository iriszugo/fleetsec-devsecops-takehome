const jwt = require("jsonwebtoken");

const secret = process.env.JWT_SECRET;

if (!secret) {
  throw new Error("JWT_SECRET environment variable is required");
}

const payload = {
  sub: "1001",
  role: "user"
};

const token = jwt.sign(payload, secret, {
  algorithm: "HS256",
  expiresIn: "15m",
  issuer: "fleetsec",
  audience: "fleetsec-api"
});

const verified = jwt.verify(token, secret, {
  algorithms: ["HS256"],
  issuer: "fleetsec",
  audience: "fleetsec-api"
});

console.log(verified);
