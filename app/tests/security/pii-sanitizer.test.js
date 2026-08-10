const { sanitizePII } = require('../../src/utils/piiSanitizer');

describe('PII sanitizer security controls', () => {
  test('redacts email, ID and Colombian phone', () => {
    const input = {
      email: 'iris@example.com',
      cedula: '1234567890',
      telefono: '+573001234567'
    };

    expect(sanitizePII(input)).toEqual({
      email: '[REDACTED_EMAIL]',
      cedula: '[REDACTED_ID]',
      telefono: '[REDACTED_PHONE]'
    });
  });

  test('redacts nested objects and arrays', () => {
    const input = {
      nested: {
        contacto: 'usuario@test.com'
      },
      lista: ['3009876543', 'texto-seguro']
    };

    expect(sanitizePII(input)).toEqual({
      nested: {
        contacto: '[REDACTED_EMAIL]'
      },
      lista: ['[REDACTED_PHONE]', 'texto-seguro']
    });
  });

  test('preserves legitimate non-PII values', () => {
    const input = {
      message: 'operacion completada',
      status: true,
      count: 25
    };

    expect(sanitizePII(input)).toEqual(input);
  });
});
