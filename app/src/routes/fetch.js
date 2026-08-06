const express = require("express");
const axios = require("axios");
const dns = require("node:dns").promises;
const net = require("node:net");

const router = express.Router();

const ALLOWED_HOSTS = new Set([
  "example.com",
  "api.example.com"
]);

function isPrivateIpv4(ip) {
  const parts = ip.split(".").map(Number);

  if (parts.length !== 4 || parts.some(Number.isNaN)) {
    return false;
  }

  const [a, b] = parts;

  return (
    a === 10 ||
    a === 127 ||
    (a === 169 && b === 254) ||
    (a === 172 && b >= 16 && b <= 31) ||
    (a === 192 && b === 168)
  );
}

function isBlockedIp(ip) {
  if (net.isIPv4(ip)) {
    return isPrivateIpv4(ip);
  }

  if (net.isIPv6(ip)) {
    const normalized = ip.toLowerCase();

    return (
      normalized === "::1" ||
      normalized.startsWith("fc") ||
      normalized.startsWith("fd") ||
      normalized.startsWith("fe80:")
    );
  }

  return true;
}

async function validateTargetUrl(rawUrl) {
  let parsedUrl;

  try {
    parsedUrl = new URL(rawUrl);
  } catch {
    throw new Error("Invalid URL");
  }

  if (!["https:"].includes(parsedUrl.protocol)) {
    throw new Error("Only HTTPS URLs are allowed");
  }

  if (!ALLOWED_HOSTS.has(parsedUrl.hostname)) {
    throw new Error("Host is not allowlisted");
  }

  const addresses = await dns.lookup(parsedUrl.hostname, {
    all: true,
    verbatim: true
  });

  if (
    addresses.length === 0 ||
    addresses.some(({ address }) => isBlockedIp(address))
  ) {
    throw new Error("Resolved IP address is not allowed");
  }

  return parsedUrl;
}

router.get("/fetch", async (req, res) => {
  const { url } = req.query;

  if (!url) {
    return res.status(400).json({
      error: "Missing url parameter"
    });
  }

  try {
    const validatedUrl = await validateTargetUrl(url);

    const response = await axios.get(validatedUrl.toString(), {
      timeout: 3000,
      maxRedirects: 0,
      validateStatus: (status) => status >= 200 && status < 300
    });

    return res.status(200).json({
      requestedUrl: validatedUrl.toString(),
      status: response.status,
      data: response.data
    });
  } catch (error) {
    return res.status(400).json({
      error: "Blocked or invalid remote resource"
    });
  }
});

module.exports = {
  router,
  validateTargetUrl,
  isBlockedIp
};
