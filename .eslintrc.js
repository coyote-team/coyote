/* eslint-disable sort-keys-shorthand/sort-keys-shorthand */
module.exports = {
  env: {
    browser: true,
    es6: true,
  },
  extends: ["prettier"],
  ignorePatterns: ["node_modules/"],
  globals: {
    Atomics: "readonly",
    SharedArrayBuffer: "readonly",
  },
  plugins: ["import", "prettier", "sort-keys-shorthand"],
  rules: {
    /* Standard ESLint rules */
    "arrow-parens": ["error", "as-needed"],
    "comma-dangle": ["error", "always-multiline"],
    "max-classes-per-file": "off", // Component and ComponentItem support
    "no-console": [
      "error",
      {
        allow: ["error"],
      },
    ],
    "no-multiple-empty-lines": "error",
    "object-shorthand": ["error", "always"],
    "prefer-const": [
      "error",
      {
        destructuring: "all",
      },
    ],
    "quote-props": ["error", "as-needed"],
    quotes: [
      "error",
      "double",
      {
        avoidEscape: true,
      },
    ],
    semi: ["error", "never"],
    "sort-imports": [
      "error",
      {
        ignoreCase: true,
        ignoreDeclarationSort: true,
        ignoreMemberSort: false,
      },
    ],
    "sort-keys": "off", // We use a custom sorter that enforces shorthand-first keys

    /* import/export rules */
    // "import/default": "off",
    "import/first": "error", // Use custom import/order grouping rather than enforcing a single group
    "import/export": "error",
    // "import/named": "off",
    "import/namespace": "error",
    "import/no-default-export": "error",
    "import/no-duplicates": "error",
    "import/no-extraneous-dependencies": "off",
    "import/no-extraneous-dependencies": "error",
    "import/no-named-as-default": "error",
    "import/no-named-as-default-member": "error",
    "import/no-unresolved": "error",
    "import/order": [
      "error",
      {
        alphabetize: {
          caseInsensitive: true,
          order: "asc",
        },
        groups: [["builtin", "external"], "internal", "index", "sibling", "parent"],
        "newlines-between": "always",
        pathGroups: [
          {
            group: "internal",
            pattern: "src/*",
          },
        ],
      },
    ],

    /* Finally, miscellaneous */
    "sort-keys-shorthand/sort-keys-shorthand": [
      "error",
      "asc",
      {
        caseSensitive: true,
        natural: false,
        minKeys: 2,
        shorthand: "first",
      },
    ],
    "prettier/prettier": "error",
  },
  parserOptions: {
    allowImportExportEverywhere: true,
    sourceType: "module",
  },
}
