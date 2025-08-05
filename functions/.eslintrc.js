module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    "ecmaVersion": 2020, // ✅ CHANGED: from 2018 to 2020 to support optional chaining
    "sourceType": "module",
  },
  extends: [
    "eslint:recommended",
  ],
  rules: {
    "no-restricted-globals": "error",
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double"],
    "no-unused-vars": "error",
    "no-undef": "error",
    "require-jsdoc": "off",
    "valid-jsdoc": "off",
    "max-len": ["error", {"code": 250}],
    "indent": ["error", 2],
    "object-curly-spacing": ["error", "never"],
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
