const { randomUUID } = require("crypto");
const request = require("supertest");
const express = require("express");

const TEST_ADMIN_USERNAME = "admin-test";
const TEST_ADMIN_PASSWORD = "StrongTestPass123!";


describe("FleetSec Rate Limiting security controls", () => {
  beforeEach(() => {
    process.env.JWT_SECRET = "day4-test-jwt-secret-minimum-32-characters";
    process.env.ADMIN_USERNAME = TEST_ADMIN_USERNAME;
    process.env.ADMIN_PASSWORD = TEST_ADMIN_PASSWORD;
  });

  afterEach(() => {
    delete process.env.JWT_SECRET;
    delete process.env.ADMIN_USERNAME;
    delete process.env.ADMIN_PASSWORD;
  });

  test("blocks authentication after too many failed attempts", async () => {
    jest.resetModules();

    const app = express();
    const invalidPassword = randomUUID();

    app.use(express.json());

    const { router } = require("../../src/routes/login");
    app.use("/api/v1", router);

    for (let i = 0; i < 5; i += 1) {
      await request(app)
        .post("/api/v1/login")
        .send({
          username: TEST_ADMIN_USERNAME,
          password: invalidPassword
        });
    }

    const response = await request(app)
      .post("/api/v1/login")
      .send({
        username: TEST_ADMIN_USERNAME,
        password: invalidPassword
      });

    expect(response.status).toBe(429);
    expect(response.body.error).toBe(
      "Too many authentication attempts. Please try again later."
    );
  });

  test("allows valid authentication before reaching the limit", async () => {
    jest.resetModules();

    const app = express();

    app.use(express.json());

    const { router } = require("../../src/routes/login");
    app.use("/api/v1", router);

    const response = await request(app)
      .post("/api/v1/login")
      .send({
        username: TEST_ADMIN_USERNAME,
        password: TEST_ADMIN_PASSWORD
      });

    expect(response.status).toBe(200);
    expect(response.body.authenticated).toBe(true);
  });
});
