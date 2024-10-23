import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import tailwindcss from 'tailwindcss'
import autoprefixer from 'autoprefixer'

export default defineConfig({
  plugins: [
    RubyPlugin(),
  ],
  resolve: {
    alias: {
      '@hotwired/stimulus': '@hotwired/stimulus/dist/stimulus.js',
      '@hotwired/turbo': '@hotwired/turbo/dist/turbo.es2017-esm.js',
    },
  },
  css: {
    postcss: {
      plugins: [
        tailwindcss,
        autoprefixer,
      ],
    },
  },
  build: {
    // This ensures that CSS is extracted into a separate file
    cssCodeSplit: false,
  },
  // Add this section
  // server: {
  //   hmr: true,
  //   watch: {
  //     usePolling: true,
  //   },
  // },
  // Add this for debugging
  logLevel: 'info',
})
