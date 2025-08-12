/** @type {import('tailwindcss').Config} */
const moonBasePreset = require("../deps/moon_live/assets/js/moon-base-preset");



module.exports = {
  content: [
    "../deps/moon_live/lib/**/*.*ex",
    "../deps/moon_live/assets/js/**/*.js",
  ],
  presets: [moonBasePreset],
  theme: {
    extend: {},
  },
  plugins: [],
}

