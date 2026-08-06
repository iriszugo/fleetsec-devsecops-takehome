const fs = require("node:fs");
const path = require("node:path");

function vulnerableDownload(req) {
  const file = req.query.file;

  const fullPath = path.join("/tmp/files", file);

  return fs.readFileSync(fullPath, "utf8");
}

module.exports = {
  vulnerableDownload
};
