const request = require("supertest");
const app = require("../src/app");

describe("FleetSec Health Endpoint", () => {

    test("GET /health should return HTTP 200", async () => {

        const response = await request(app)
            .get("/health");

        expect(response.statusCode).toBe(200);

        expect(response.body.status).toBe("UP");

    });

    test("GET / should return application information", async () => {

        const response = await request(app)
            .get("/");

        expect(response.statusCode).toBe(200);

        expect(response.body.application)
            .toBe("FleetSec Vulnerable Lab");

    });

});
