const { loadSecurityConfig } = require('../../src/config/securityConfig');

describe('V-10 Hardcoded Credentials security controls', () => {

  const originalEnv = { ...process.env };

  afterEach(() => {
    process.env = { ...originalEnv };
  });

  test('rejects startup configuration when JWT_SECRET is absent', () => {
    delete process.env.JWT_SECRET;

    process.env.ADMIN_USERNAME = 'admin_secure';
    process.env.ADMIN_PASSWORD = 'StrongPassword123!';

    expect(() => loadSecurityConfig()).toThrow(
      /JWT_SECRET is required/
    );
  });

  test('rejects weak JWT_SECRET', () => {
    process.env.JWT_SECRET = 'short';
    process.env.ADMIN_USERNAME = 'admin_secure';
    process.env.ADMIN_PASSWORD = 'StrongPassword123!';

    expect(() => loadSecurityConfig()).toThrow(
      /JWT_SECRET is required and must contain at least 32 characters/
    );
  });

  test('rejects missing ADMIN_PASSWORD', () => {
    process.env.JWT_SECRET =
      '0123456789abcdef0123456789abcdef';

    process.env.ADMIN_USERNAME = 'admin_secure';
    delete process.env.ADMIN_PASSWORD;

    expect(() => loadSecurityConfig()).toThrow(
      /ADMIN_PASSWORD is required/
    );
  });

  test('accepts secure configuration from environment variables', () => {
    process.env.JWT_SECRET =
      '0123456789abcdef0123456789abcdef';

    process.env.ADMIN_USERNAME = 'admin_secure';
    process.env.ADMIN_PASSWORD = 'StrongPassword123!';

    const config = loadSecurityConfig();

    expect(config.jwtSecret)
      .toBe('0123456789abcdef0123456789abcdef');

    expect(config.adminUsername)
      .toBe('admin_secure');

    expect(config.adminPassword)
      .toBe('StrongPassword123!');
  });

});
