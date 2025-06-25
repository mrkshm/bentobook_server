/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './app/views/**/*.html.erb',
    './app/views/**/*.rb',
    './app/helpers/**/*.rb',
    './app/components/**/*.rb',
    './app/components/**/*.html.erb',
    './app/frontend/**/*.js',
    './app/frontend/**/*.css',
  ],
  safelist: [
    // Padding
    { pattern: /p-(0|1|2|3|4|5|6|8|10|12|16|20|24|32|40|48)/ },
    { pattern: /px-(0|1|2|3|4|5|6|8|10|12|16|20|24|32|40|48)/ },
    { pattern: /py-(0|1|2|3|4|5|6|8|10|12|16|20|24|32|40|48)/ },
    { pattern: /pt-(0|1|2|3|4|5|6|8|10|12|16|20|24|32)/ },
    { pattern: /pr-(0|1|2|3|4|5|6|8|10|12|16|20|24|32)/ },
    { pattern: /pb-(0|1|2|3|4|5|6|8|10|12|16|20|24|32)/ },
    { pattern: /pl-(0|1|2|3|4|5|6|8|10|12|16|20|24|32)/ },
    
    // Margin
    { pattern: /m-(0|1|2|3|4|5|6|8|10|12|16|20|24|32|40|48)/ },
    { pattern: /mx-(0|1|2|3|4|5|6|8|10|12|16|20|24|32|40|48|auto)/ },
    { pattern: /my-(0|1|2|3|4|5|6|8|10|12|16|20|24|32|40|48|auto)/ },
    { pattern: /mt-(0|1|2|3|4|5|6|8|10|12|16|20|24|32)/ },
    { pattern: /mr-(0|1|2|3|4|5|6|8|10|12|16|20|24|32)/ },
    { pattern: /mb-(0|1|2|3|4|5|6|8|10|12|16|20|24|32)/ },
    { pattern: /ml-(0|1|2|3|4|5|6|8|10|12|16|20|24|32)/ },
    
    // Gap
    { pattern: /gap-(0|1|2|3|4|5|6|8|10|12|16|20|24)/ },
    { pattern: /gap-x-(0|1|2|3|4|5|6|8|10|12)/ },
    { pattern: /gap-y-(0|1|2|3|4|5|6|8|10|12)/ },
    
    // Flex
    'flex', 'flex-row', 'flex-col', 'flex-wrap', 'flex-nowrap', 'flex-1', 'flex-auto', 'flex-initial', 'flex-none',
    'items-start', 'items-end', 'items-center', 'items-baseline', 'items-stretch',
    'justify-start', 'justify-end', 'justify-center', 'justify-between', 'justify-around', 'justify-evenly',
    
    // Grid
    'grid', 'grid-cols-1', 'grid-cols-2', 'grid-cols-3', 'grid-cols-4', 'grid-cols-5', 'grid-cols-6', 'grid-cols-12',
    'col-span-1', 'col-span-2', 'col-span-3', 'col-span-4', 'col-span-5', 'col-span-6', 'col-span-12',
    
    // Space
    { pattern: /space-x-(0|1|2|3|4|5|6|8|10|12)/ },
    { pattern: /space-y-(0|1|2|3|4|5|6|8|10|12)/ },
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
