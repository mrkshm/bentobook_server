/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    // Rails view templates
    "./app/views/**/*.{html,erb,haml,slim}",
    // Stimulus controllers and other front-end code
    "./app/frontend/**/*.{js,ts,jsx,tsx,vue}",
    // ViewComponents or other Ruby-based component templates
    "./app/components/**/*.{html,erb,rb}",
    // Helpers (if you embed Tailwind classes in Ruby strings)
    "./app/helpers/**/*.rb",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
};
