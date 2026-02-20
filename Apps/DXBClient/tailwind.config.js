/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        lime: {
          DEFAULT: '#BAFF39',
          50: '#F4FFDC',
          100: '#E8FFBA',
          200: '#DCFF98',
          300: '#CFFF66',
          400: '#BAFF39',
          500: '#9FE000',
          600: '#85C000',
          700: '#6BA000',
          800: '#518000',
          900: '#375000',
        },
        zinc: {
          50: '#FFFFFF',
          100: '#F8F8F8',
          200: '#F0F0F0',
          300: '#E5E5E5',
          400: '#D0D0D0',
          500: '#6E6E6E',
          600: '#6E6E6E',
          700: '#4A4A4A',
          800: '#2A2A2A',
          900: '#1A1A1A',
          950: '#0A0A0A',
        },
        gray: {
          DEFAULT: '#6E6E6E',
          dark: '#6E6E6E',
          light: '#E5E5E5',
        },
        accent: {
          DEFAULT: '#BAFF39',
        },
        white: '#FFFFFF',
        black: '#1A1A1A',
      },
      borderRadius: {
        'pill': '100px',
        '4xl': '2rem',
        '5xl': '2.5rem',
      },
      transitionTimingFunction: {
        'hearst': 'cubic-bezier(.165, .84, .44, 1)',
      },
      spacing: {
        '18': '4.5rem',
        '22': '5.5rem',
      },
      animation: {
        'float': 'float 6s ease-in-out infinite',
        'pulse-glow': 'pulse-glow 2s ease-in-out infinite',
        'shimmer': 'shimmer 2s infinite',
        'gradient-shift': 'gradient-shift 8s ease infinite',
        'fade-in-up': 'fade-in-up 0.5s ease-out forwards',
        'fade-in-scale': 'fade-in-scale 0.3s ease-out forwards',
        'slide-in-right': 'slide-in-right 0.4s ease-out forwards',
        'blob': 'blob 7s ease-in-out infinite',
      },
      keyframes: {
        float: {
          '0%, 100%': { transform: 'translateY(0px) rotate(0deg)' },
          '50%': { transform: 'translateY(-20px) rotate(2deg)' },
        },
        'pulse-glow': {
          '0%, 100%': { boxShadow: '0 0 20px rgba(186, 255, 57, 0.3)' },
          '50%': { boxShadow: '0 0 40px rgba(186, 255, 57, 0.6)' },
        },
        shimmer: {
          '0%': { backgroundPosition: '-200% 0' },
          '100%': { backgroundPosition: '200% 0' },
        },
        'gradient-shift': {
          '0%, 100%': { backgroundPosition: '0% 50%' },
          '50%': { backgroundPosition: '100% 50%' },
        },
        'fade-in-up': {
          from: { opacity: '0', transform: 'translateY(20px)' },
          to: { opacity: '1', transform: 'translateY(0)' },
        },
        'fade-in-scale': {
          from: { opacity: '0', transform: 'scale(0.95)' },
          to: { opacity: '1', transform: 'scale(1)' },
        },
        'slide-in-right': {
          from: { opacity: '0', transform: 'translateX(100%)' },
          to: { opacity: '1', transform: 'translateX(0)' },
        },
        blob: {
          '0%, 100%': { borderRadius: '60% 40% 30% 70% / 60% 30% 70% 40%' },
          '50%': { borderRadius: '30% 60% 70% 40% / 50% 60% 30% 60%' },
        },
      },
      backdropBlur: {
        xs: '2px',
      },
    },
  },
  plugins: [],
}
