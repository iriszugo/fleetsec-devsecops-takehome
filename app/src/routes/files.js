const express = require("express");
const fs = require("node:fs");
const path = require("node:path");

const router = express.Router();

const BASE_DIRECTORY = path.resolve(__dirname, "../../safe-files");

function resolveSafePath(requestedFile) {
  if (
    !requestedFile ||
    path.isAbsolute(requestedFile) ||
    requestedFile.includes("\0")
  ) {
    throw new Error("Invalid file path");
  }

  const requestedPath = path.resolve(BASE_DIRECTORY, requestedFile);

  const isInsideBaseDirectory =
    requestedPath === BASE_DIRECTORY ||
    requestedPath.startsWith(`${BASE_DIRECTORY}${path.sep}`);

  if (!isInsideBaseDirectory) {
    throw new Error("Invalid file path");
  }

  const stats = fs.lstatSync(requestedPath);

  if (stats.isSymbolicLink() || !stats.isFile()) {
    throw new Error("Invalid file type");
  }

  return requestedPath;
}

router.get("/download", (req, res) => {
  const { file } = req.query;

  try {
    const requestedPath = resolveSafePath(file);
    const content = fs.readFileSync(requestedPath, "utf8");

    return res.status(200).json({
      requestedFile: file,
      content
    });
  } catch (error) {
    return res.status(400).json({
      error: "Invalid file path"
    });
  }
});

module.exports = {
  router,
  resolveSafePath,
  BASE_DIRECTORY
};
