import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  plugins: [tailwindcss(), RubyPlugin()],
  resolve: {
    alias: {
      '@hotwired/stimulus': '@hotwired/stimulus/dist/stimulus.js',
      '@hotwired/turbo': '@hotwired/turbo/dist/turbo.es2017-esm.js',
    },
  },
  // Disable CSS code splitting and minification to preserve all classes
  build: {
    cssCodeSplit: false,
    cssMinify: false,
  }
});
