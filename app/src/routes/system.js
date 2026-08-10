const express = require("express");
const { execFile } = require("child_process");
const { promisify } = require("util");

const router = express.Router();
const execFileAsync = promisify(execFile);

const ALLOWED_OPERATIONS = Object.freeze({
  ping: {
    binary: "/bin/ping",
    buildArgs: (target) => ["-c", "1", target]
  }
});

const HOST_PATTERN =
  /^(?=.{1,253}$)(localhost|(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)*[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?|\d{1,3}(?:\.\d{1,3}){3})$/;

function isValidIPv4(value) {
  const parts = value.split(".");

  if (parts.length !== 4) {
    return false;
  }

  return parts.every((part) => {
    if (!/^\d{1,3}$/.test(part)) {
      return false;
    }

    const numericPart = Number(part);

    return numericPart >= 0 && numericPart <= 255;
  });
}

function isValidHost(value) {
  if (typeof value !== "string") {
    return false;
  }

  const normalizedValue = value.trim();

  if (!HOST_PATTERN.test(normalizedValue)) {
    return false;
  }

  if (/^\d{1,3}(?:\.\d{1,3}){3}$/.test(normalizedValue)) {
    return isValidIPv4(normalizedValue);
  }

  return true;
}

router.get("/ping", async (req, res) => {
  const operation = "ping";
  const target = req.query.host;

  if (!isValidHost(target)) {
    return res.status(400).json({
      error: "Invalid host value"
    });
  }

  const selectedOperation = ALLOWED_OPERATIONS[operation];
  const args = selectedOperation.buildArgs(target.trim());

  try {
    const { stdout } = await execFileAsync(
      selectedOperation.binary,
      args,
      {
        shell: false,
        timeout: 3000,
        maxBuffer: 64 * 1024,
        windowsHide: true
      }
    );

    return res.status(200).json({
      secure: true,
      operation,
      target: target.trim(),
      output: stdout
    });
  } catch (error) {
    if (error.killed || error.signal === "SIGTERM") {
      return res.status(504).json({
        error: "Operation timed out"
      });
    }

    return res.status(502).json({
      error: "System operation failed"
    });
  }
});

module.exports = {
  router,
  isValidHost
};
