const express = require("express");
const axios = require("axios");

const router = express.Router();

/**
 * LABORATORIO VULNERABLE CONTROLADO
 * CWE-918: Server-Side Request Forgery
 * Escenario: el servidor realiza solicitudes a una URL suministrada
 * por el usuario sin validación de host, IP o redirecciones.
 */

router.get("/fetch", async (req, res) => {
  const { url } = req.query;

  if (!url) {
    return res.status(400).json({
      error: "Missing url parameter"
    });
  }

  try {
    const response = await axios.get(url, {
      timeout: 3000
    });

    return res.status(200).json({
      laboratory: true,
      vulnerable: true,
      requestedUrl: url,
      status: response.status,
      data: response.data
    });
  } catch (error) {
    return res.status(502).json({
      laboratory: true,
      vulnerable: true,
      requestedUrl: url,
      error: "Unable to fetch remote resource"
    });
  }
});

module.exports = router;
