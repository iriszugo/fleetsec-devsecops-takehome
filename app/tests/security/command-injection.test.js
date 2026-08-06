const request = require("supertest");
const express = require("express");

const { router } = require("../../src/routes/system");

describe("FleetSec Command Injection security controls", () => {

    let app;

    beforeEach(() => {
        app = express();
        app.use("/api/v1/system", router);
    });

    test("rejects shell metacharacters", async () => {

        const response = await request(app)
            .get("/api/v1/system/ping")
            .query({
                host: "127.0.0.1; whoami"
            });

        expect(response.status).toBe(400);
        expect(response.body.error).toBe("Invalid host value");

    });

    test("accepts a valid host", async () => {

        const response = await request(app)
            .get("/api/v1/system/ping")
            .query({
                host: "127.0.0.1"
            });

        expect([200, 502, 504]).toContain(response.status);

    });

});
