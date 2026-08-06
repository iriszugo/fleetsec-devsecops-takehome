const request = require("supertest");
const express = require("express");

describe("FleetSec IDOR security controls", () => {
  function buildApp(authenticatedUser) {
    jest.resetModules();

    const app = express();
    app.use(express.json());

    app.use((req, res, next) => {
      req.user = authenticatedUser;
      next();
    });

    const { router } = require("../../src/routes/users");
    app.use("/api/v1", router);

    return app;
  }

  test("rejects access to another user's profile", async () => {
    const app = buildApp({
      id: 1,
      role: "user"
    });

    const response = await request(app)
      .get("/api/v1/users/2/profile");

    expect(response.status).toBe(403);
    expect(response.body.error).toBe("Access denied");
  });

  test("allows the owner to access their own profile", async () => {
    const app = buildApp({
      id: 1,
      role: "user"
    });

    const response = await request(app)
      .get("/api/v1/users/1/profile");

    expect(response.status).toBe(200);
    expect(response.body.profile.id).toBe(1);
  });

  test("allows an administrator to access another profile", async () => {
    const app = buildApp({
      id: 99,
      role: "admin"
    });

    const response = await request(app)
      .get("/api/v1/users/2/profile");

    expect(response.status).toBe(200);
    expect(response.body.profile.id).toBe(2);
  });
});
