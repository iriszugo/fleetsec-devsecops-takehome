const request = require("supertest");

const app = require("../../src/app");
const { router } = require("../../src/routes/fetch");

describe("FleetSec SSRF security controls", () => {
  beforeAll(() => {
    app.use("/api/v1", router);
  });

  test("rejects localhost SSRF attempt", async () => {
    const response = await request(app)
      .get("/api/v1/fetch")
      .query({
        url: "http://127.0.0.1/latest/meta-data/"
      });

    expect(response.status).toBe(400);
    expect(response.body.error).toBe(
      "Blocked or invalid remote resource"
    );
  });

  test("rejects link-local metadata service", async () => {
    const response = await request(app)
      .get("/api/v1/fetch")
      .query({
        url: "http://169.254.169.254/latest/meta-data/"
      });

    expect(response.status).toBe(400);
  });

  test("rejects non-allowlisted domains", async () => {
    const response = await request(app)
      .get("/api/v1/fetch")
      .query({
        url: "https://google.com"
      });

    expect(response.status).toBe(400);
  });
});
