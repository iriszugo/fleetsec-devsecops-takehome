const fs = require("node:fs");
const path = require("node:path");

const BASE_DIRECTORY = "/tmp/files";

function secureDownload(file) {
  const requestedPath = path.resolve(BASE_DIRECTORY, file);

  if (
    requestedPath !== BASE_DIRECTORY &&
    !requestedPath.startsWith(`${BASE_DIRECTORY}${path.sep}`)
  ) {
    throw new Error("Invalid file path");
  }

  return fs.readFileSync(requestedPath, "utf8");
}

module.exports = {
  secureDownload
};
