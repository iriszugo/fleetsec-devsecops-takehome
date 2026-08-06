const { randomUUID } = require("crypto");
const request = require("supertest");
const express = require("express");

describe("FleetSec Rate Limiting security controls", () => {
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
          username: "admin",
          password: invalidPassword
        });
    }

    const response = await request(app)
      .post("/api/v1/login")
      .send({
        username: "admin",
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
        username: "admin",
        password: "FleetSec123!"
      });

    expect(response.status).toBe(200);
    expect(response.body.authenticated).toBe(true);
  });
});
