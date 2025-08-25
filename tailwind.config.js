// Tailwind config with OKLCH alpha support

const oklch = (triplet) => ({ opacityValue }) => `oklch(${triplet} / ${opacityValue == null ? 1 : opacityValue})`

module.exports = {
  content: [
    './app/views/**/*.erb',
    './app/helpers/**/*.rb',
    './app/frontend/**/*.js',
    './app/components/**/*.{rb,erb}',
  ],
  theme: {
    extend: {
      colors: {
        surface: {
          50: oklch('0.98 0.003 270'),
          100: oklch('0.95 0.004 270'),
          200: oklch('0.9 0.005 270'),
          300: oklch('0.85 0.006 270'),
          400: oklch('0.75 0.007 270'),
          500: oklch('0.65 0.008 270'),
          600: oklch('0.55 0.007 270'),
          700: oklch('0.45 0.006 270'),
          800: oklch('0.35 0.005 270'),
          900: oklch('0.25 0.004 270'),
          950: oklch('0.2 0.003 270'),
        },
      },
    },
  },
  plugins: [],
}
