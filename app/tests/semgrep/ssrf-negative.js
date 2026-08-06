const axios = require("axios");

const ALLOWED_URL = "https://example.com/api/status";

async function secureFetch() {
  return axios.get(ALLOWED_URL, {
    timeout: 3000,
    maxRedirects: 0
  });
}

module.exports = {
  secureFetch
};
