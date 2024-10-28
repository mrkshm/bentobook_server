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
    manifest: true,
    rollupOptions: {
      input: 'app/frontend/entrypoints/application.js'
    }
  }
})
