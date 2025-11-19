const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    '/mikado-system/public/*.html',
    '/mikado-system/app/helpers/*.rb',
    '/mikado-system/app/javascript/**/*.js',
    '/mikado-system/app/views/**/*.{html.erb,haml,html,slim}',
    '/mikado-system/node_modules/preline/dist/*.js'
  ],
  darkMode:"dark",
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
    require('preline/plugin'),
  ]
}
