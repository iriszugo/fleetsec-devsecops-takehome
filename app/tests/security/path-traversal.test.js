const request = require("supertest");
const fs = require("node:fs");
const path = require("node:path");

const app = require("../../src/app");
const { router, BASE_DIRECTORY } = require("../../src/routes/files");

describe("FleetSec Path Traversal security controls", () => {
  beforeAll(() => {
    fs.mkdirSync(BASE_DIRECTORY, { recursive: true });

    fs.writeFileSync(
      path.join(BASE_DIRECTORY, "sample.txt"),
      "FleetSec Test File"
    );

    app.use("/api/v1", router);
  });

  test("rejects directory traversal attempt", async () => {
    const response = await request(app)
      .get("/api/v1/download")
      .query({
        file: "../../../etc/passwd"
      });

    expect(response.status).toBe(400);
    expect(response.body.error).toBe("Invalid file path");
  });

  test("allows reading a valid file", async () => {
    const response = await request(app)
      .get("/api/v1/download")
      .query({
        file: "sample.txt"
      });

    expect(response.status).toBe(200);
    expect(response.body.content).toBe("FleetSec Test File");
  });
});
