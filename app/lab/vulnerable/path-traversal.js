const express = require("express");
const fs = require("node:fs");
const path = require("node:path");

const router = express.Router();

/**
 * LABORATORIO VULNERABLE CONTROLADO
 * CWE-22: Path Traversal
 * Escenario: lectura de archivos usando entrada del usuario sin validación.
 */

router.get("/download", (req, res) => {
  const { file } = req.query;

  if (!file) {
    return res.status(400).json({
      error: "Missing file parameter"
    });
  }

  const baseDirectory = path.join(__dirname, "files");
  const requestedPath = path.join(baseDirectory, file);

  fs.readFile(requestedPath, "utf8", (error, content) => {
    if (error) {
      return res.status(404).json({
        laboratory: true,
        vulnerable: true,
        error: "File not found"
      });
    }

    return res.status(200).json({
      laboratory: true,
      vulnerable: true,
      requestedFile: file,
      content
    });
  });
});

module.exports = router;
