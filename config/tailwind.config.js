module.exports = {
    content: [
        './app/views/**/*.html.erb',
        './app/helpers/**/*.rb',
        './app/assets/stylesheets/**/*.css',
        './app/javascript/**/*.js'
    ],
    darkMode: 'class', // Enable manual dark mode toggle
    theme: {
        extend: {
            colors: {
                // Omarchy Everforest (Dark Mode Base)
                everforest: {
                    bg: '#2b3339',
                    'bg-hard': '#272e33',
                    'bg-soft': '#323c41',
                    fg: '#d3c6aa',
                    red: '#e67e80',
                    orange: '#e69875',
                    yellow: '#dbbc7f',
                    green: '#a7c080',
                    aqua: '#83c092',
                    blue: '#7fbbb3',
                    purple: '#d699b6',
                },
                // Magenta Light Mode
                magenta: {
                    50: '#fdf2f8',
                    100: '#fce7f3',
                    200: '#fbcfe8',
                    300: '#f9a8d4',
                    400: '#f472b6',
                    500: '#ec4899', // Primary Brand
                    600: '#db2777',
                    700: '#be185d',
                    800: '#9d174d',
                    900: '#831843',
                }
            },
            fontFamily: {
                sans: ['Inter', 'sans-serif'],
            },
        },
    },
    plugins: [],
}
