/** @type {import('tailwindcss').Config} */
module.exports = {
  // Disable purging completely
  purge: false,
  content: [
    './app/views/**/*.html.erb',
    './app/views/**/*.rb',
    './app/helpers/**/*.rb',
    './app/components/**/*.rb',
    './app/components/**/*.html.erb',
    './app/frontend/**/*.js',
    './app/frontend/**/*.css',
  ],
  // Safelist all spacing-related classes
  safelist: [
    // Wildcard patterns to match all spacing classes
    { pattern: /^p-/, variants: ['sm', 'md', 'lg', 'xl', '2xl'] },
    { pattern: /^px-/, variants: ['sm', 'md', 'lg', 'xl', '2xl'] },
    { pattern: /^py-/, variants: ['sm', 'md', 'lg', 'xl', '2xl'] },
    { pattern: /^pt-/, variants: ['sm', 'md', 'lg', 'xl', '2xl'] },
    { pattern: /^pr-/, variants: ['sm', 'md', 'lg', 'xl', '2xl'] },
    { pattern: /^pb-/, variants: ['sm', 'md', 'lg', 'xl', '2xl'] },
    { pattern: /^pl-/, variants: ['sm', 'md', 'lg', 'xl', '2xl'] },
    
    { pattern: /^m-/, variants: ['sm', 'md', 'lg', 'xl', '2xl'] },
    { pattern: /^mx-/, variants: ['sm', 'md', 'lg', 'xl', '2xl'] },
    { pattern: /^my-/, variants: ['sm', 'md', 'lg', 'xl', '2xl'] },
    { pattern: /^mt-/, variants: ['sm', 'md', 'lg', 'xl', '2xl'] },
    { pattern: /^mr-/, variants: ['sm', 'md', 'lg', 'xl', '2xl'] },
    { pattern: /^mb-/, variants: ['sm', 'md', 'lg', 'xl', '2xl'] },
    { pattern: /^ml-/, variants: ['sm', 'md', 'lg', 'xl', '2xl'] },
    
    { pattern: /^gap-/, variants: ['sm', 'md', 'lg', 'xl', '2xl'] },
    { pattern: /^gap-x-/, variants: ['sm', 'md', 'lg', 'xl', '2xl'] },
    { pattern: /^gap-y-/, variants: ['sm', 'md', 'lg', 'xl', '2xl'] },
    
    { pattern: /^space-x-/, variants: ['sm', 'md', 'lg', 'xl', '2xl'] },
    { pattern: /^space-y-/, variants: ['sm', 'md', 'lg', 'xl', '2xl'] },
    
    // Explicitly include common layout classes
    'flex', 'flex-row', 'flex-col', 'flex-wrap', 'flex-nowrap', 'flex-1', 'flex-auto', 'flex-initial', 'flex-none',
    'items-start', 'items-end', 'items-center', 'items-baseline', 'items-stretch',
    'justify-start', 'justify-end', 'justify-center', 'justify-between', 'justify-around', 'justify-evenly',
    'grid', 'grid-cols-1', 'grid-cols-2', 'grid-cols-3', 'grid-cols-4', 'grid-cols-5', 'grid-cols-6', 'grid-cols-12',
    'col-span-1', 'col-span-2', 'col-span-3', 'col-span-4', 'col-span-5', 'col-span-6', 'col-span-12',
    'mx-auto', 'my-auto'
  ],
  theme: {
    extend: {},
  },
  plugins: [],
  // Ensure Tailwind doesn't purge any classes
  future: {
    purgeLayersByDefault: false,
  },
  experimental: {
    optimizeUniversalDefaults: true
  }
}
