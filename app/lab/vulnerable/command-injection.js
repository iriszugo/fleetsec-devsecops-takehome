const express = require("express");
const { exec } = require("child_process");

const router = express.Router();

/*
 * INTENTIONAL VULNERABILITY — LAB USE ONLY
 *
 * CWE-78: OS Command Injection
 *
 * Este endpoint existe únicamente para demostración,
 * validación VAPT y pruebas SAST.
 *
 * Nunca debe utilizarse en producción.
 */

router.get("/ping", (req, res) => {

    const host = req.query.host || "127.0.0.1";

    const command = `ping -c 1 ${host}`;

    exec(command, (error, stdout, stderr) => {

        if (error) {

            return res.status(500).json({
                laboratory: true,
                cwe: "CWE-78",
                error: stderr || error.message
            });

        }

        return res.json({
            laboratory: true,
            cwe: "CWE-78",
            output: stdout
        });

    });

});

module.exports = router;
