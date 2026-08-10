const requireSecret = (name, minimumLength = 12) => {
  const value = process.env[name];

  if (!value || value.length < minimumLength) {
    throw new Error(
      `${name} is required and must contain at least ${minimumLength} characters.`
    );
  }

  return value;
};

const loadSecurityConfig = () =>
  Object.freeze({
    jwtSecret: requireSecret('JWT_SECRET', 32),
    adminUsername: requireSecret('ADMIN_USERNAME', 5),
    adminPassword: requireSecret('ADMIN_PASSWORD', 12)
  });

module.exports = {
  loadSecurityConfig
};
