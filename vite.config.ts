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
    outDir: 'public/vite',
    emptyOutDir: true,
    rollupOptions: {
      input: {
        application: 'app/frontend/entrypoints/application.js',
        styles: 'app/frontend/stylesheets/application.css'
      }
    },
  },
})
