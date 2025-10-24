const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    '/first-class/public/*.html',
    '/first-class/app/helpers/*.rb',
    '/first-class/app/javascript/**/*.js',
    '/first-class/app/views/**/*.{html.erb,haml,html,slim}',
    '/first-class/node_modules/preline/dist/*.js'
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
