module.exports = function (api) {
  var validEnv = ["development", "test", "production"]
  var currentEnv = api.env()
  var isDevelopmentEnv = api.env("development")
  var isProductionEnv = api.env("production")
  var isTestEnv = api.env("test")

  if (!validEnv.includes(currentEnv)) {
    throw new Error(
      "Please specify a valid `NODE_ENV` or " +
        '`BABEL_ENV` environment variables. Valid values are "development", ' +
        '"test", and "production". Instead, received: ' +
        JSON.stringify(currentEnv) +
        "."
    )
  }

  return {
    plugins: [
      "babel-plugin-macros",
      "@babel/plugin-syntax-dynamic-import",
      isTestEnv && "babel-plugin-dynamic-import-node",
      "@babel/plugin-transform-destructuring",
      [
        "@babel/plugin-proposal-class-properties",
        {
          loose: true,
        },
      ],
      [
        "@babel/plugin-proposal-object-rest-spread",
        {
          useBuiltIns: true,
        },
      ],
      [
        "@babel/plugin-transform-runtime",
        {
          helpers: false,
        },
      ],
      [
        "@babel/plugin-transform-regenerator",
        {
          async: false,
        },
      ],
      [
        "@babel/plugin-proposal-private-property-in-object",
        {
          loose: true,
        },
      ],
    ].filter(Boolean),

    presets: [
      isTestEnv && [
        "@babel/preset-env",
        {
          targets: {
            node: "current",
          },
        },
      ],
      (isProductionEnv || isDevelopmentEnv) && [
        "@babel/preset-env",
        {
          corejs: 3,
          exclude: ["transform-typeof-symbol"],
          forceAllTransforms: true,
          modules: false,
          useBuiltIns: "entry",
        },
      ],
    ].filter(Boolean),
  }
}
