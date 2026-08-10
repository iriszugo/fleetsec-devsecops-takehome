const redactText = (text) => {
  if (typeof text !== 'string') return text;

  return text
    .replace(/(?:\+57|57)?3\d{9}\b/g, '[REDACTED_PHONE]')
    .replace(/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g, '[REDACTED_EMAIL]')
    .replace(/\b\d{7,10}\b/g, '[REDACTED_ID]');
};

const sanitizePII = (data) => {
  if (data === null || data === undefined) return data;

  if (typeof data === 'string') {
    return redactText(data);
  }

  if (Array.isArray(data)) {
    return data.map(sanitizePII);
  }

  if (typeof data === 'object') {
    const sanitized = {};

    for (const [key, value] of Object.entries(data)) {
      sanitized[key] = sanitizePII(value);
    }

    return sanitized;
  }

  return data;
};

module.exports = { sanitizePII };
