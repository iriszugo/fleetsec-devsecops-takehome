const { sanitizePII } = require('./piiSanitizer');

const writeLog = (level, message, meta = {}) => {
  const entry = {
    level,
    timestamp: new Date().toISOString(),
    message: sanitizePII(message),
    meta: sanitizePII(meta)
  };

  const serialized = JSON.stringify(entry);

  switch (level) {
    case 'DEBUG':
      console.debug(serialized);
      break;
    case 'WARN':
      console.warn(serialized);
      break;
    case 'ERROR':
      console.error(serialized);
      break;
    default:
      console.info(serialized);
  }
};

module.exports = {
  debug: (message, meta) => writeLog('DEBUG', message, meta),
  info: (message, meta) => writeLog('INFO', message, meta),
  warn: (message, meta) => writeLog('WARN', message, meta),
  error: (message, meta) => writeLog('ERROR', message, meta)
};
