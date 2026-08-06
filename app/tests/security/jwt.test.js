const request = require("supertest");
const jwt = require("jsonwebtoken");

const app = require("../../src/app");
const secureAuthRouter = require("../../src/routes/auth");

const JWT_SECRET = "day2-test-secret-minimum-32-characters";

describe("FleetSec JWT security controls", () => {
  beforeAll(() => {
    process.env.JWT_SECRET = JWT_SECRET;
    app.use("/api/v1/auth", secureAuthRouter);
  });

  test("rejects a forged JWT using alg:none", async () => {
    const forgedToken = jwt.sign(
      {
        sub: "1001",
        role: "admin"
      },
      "",
      {
        algorithm: "none"
      }
    );

    const response = await request(app)
      .get("/api/v1/auth/profile")
      .set("Authorization", `Bearer ${forgedToken}`);

    expect(response.status).toBe(401);
    expect(response.body).toEqual({
      error: "Invalid or expired token"
    });
  });

  test("accepts a valid HS256 JWT", async () => {
    const validToken = jwt.sign(
      {
        sub: "1001",
        role: "user"
      },
      JWT_SECRET,
      {
        algorithm: "HS256",
        expiresIn: "15m",
        issuer: "fleetsec",
        audience: "fleetsec-api"
      }
    );

    const response = await request(app)
      .get("/api/v1/auth/profile")
      .set("Authorization", `Bearer ${validToken}`);

    expect(response.status).toBe(200);
    expect(response.body.authenticatedUser.sub).toBe("1001");
    expect(response.body.authenticatedUser.role).toBe("user");
  });
});
