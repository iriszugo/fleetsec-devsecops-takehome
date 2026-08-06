const axios = require("axios");

function vulnerableFetch(req) {
  const url = req.query.url;

  return axios.get(url, {
    timeout: 3000
  });
}

module.exports = {
  vulnerableFetch
};
