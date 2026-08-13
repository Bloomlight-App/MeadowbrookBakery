/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./src/**/*.{erb,md,html,rb,serb}",
    "./frontend/**/*.js",
    // Product badges and event chips carry their own tint classes in the data
    // files, so those have to be scanned too or the utilities never get emitted.
    "./src/_data/**/*.{yml,yaml}"
  ],
  theme: {
    extend: {
      colors: {
        "primary": "#061b0e",
        "on-primary": "#ffffff",
        "primary-container": "#1b3022",
        "on-primary-container": "#819986",
        "inverse-primary": "#b4cdb8",
        "primary-fixed": "#d0e9d4",
        "primary-fixed-dim": "#b4cdb8",
        "on-primary-fixed": "#0b2013",
        "on-primary-fixed-variant": "#364c3c",
        "secondary": "#80552c",
        "on-secondary": "#ffffff",
        "secondary-container": "#fec391",
        "on-secondary-container": "#794e26",
        "secondary-fixed": "#ffdcc1",
        "secondary-fixed-dim": "#f5bb89",
        "on-secondary-fixed": "#2e1600",
        "on-secondary-fixed-variant": "#653e17",
        "tertiary": "#161811",
        "on-tertiary": "#ffffff",
        "tertiary-container": "#2b2c24",
        "on-tertiary-container": "#939389",
        "tertiary-fixed": "#e4e3d7",
        "tertiary-fixed-dim": "#c7c7bc",
        "on-tertiary-fixed": "#1b1c15",
        "on-tertiary-fixed-variant": "#46473f",
        "error": "#ba1a1a",
        "on-error": "#ffffff",
        "error-container": "#ffdad6",
        "on-error-container": "#93000a",
        "background": "#fff8f5",
        "on-background": "#1e1b18",
        "surface": "#fff8f5",
        "surface-dim": "#e1d8d4",
        "surface-bright": "#fff8f5",
        "surface-container-lowest": "#ffffff",
        "surface-container-low": "#fbf2ed",
        "surface-container": "#f5ece7",
        "surface-container-high": "#efe6e2",
        "surface-container-highest": "#e9e1dc",
        "surface-variant": "#e9e1dc",
        "surface-tint": "#4d6453",
        "on-surface": "#1e1b18",
        "on-surface-variant": "#434843",
        "inverse-surface": "#34302c",
        "inverse-on-surface": "#f8efea",
        "outline": "#737973",
        "outline-variant": "#c3c8c1"
      },
      borderRadius: {
        DEFAULT: "0.125rem",
        lg: "0.25rem",
        xl: "0.5rem",
        full: "0.75rem"
      },
      spacing: {
        "unit": "8px",
        "container-max": "1280px",
        "gutter": "24px",
        "margin-mobile": "16px",
        "margin-desktop": "48px",
        "stack-sm": "12px",
        "stack-md": "24px",
        "stack-lg": "48px"
      },
      fontFamily: {
        "display-lg": ["Newsreader"],
        "headline-lg": ["Newsreader"],
        "headline-lg-mobile": ["Newsreader"],
        "headline-md": ["Newsreader"],
        "body-lg": ["Work Sans"],
        "body-md": ["Work Sans"],
        "label-lg": ["Work Sans"],
        "label-sm": ["Work Sans"]
      },
      fontSize: {
        "display-lg": ["48px", { lineHeight: "56px", letterSpacing: "-0.02em", fontWeight: "600" }],
        "headline-lg": ["32px", { lineHeight: "40px", fontWeight: "500" }],
        "headline-lg-mobile": ["28px", { lineHeight: "36px", fontWeight: "500" }],
        "headline-md": ["24px", { lineHeight: "32px", fontWeight: "500" }],
        "body-lg": ["18px", { lineHeight: "28px", fontWeight: "400" }],
        "body-md": ["16px", { lineHeight: "24px", fontWeight: "400" }],
        "label-lg": ["14px", { lineHeight: "20px", letterSpacing: "0.05em", fontWeight: "600" }],
        "label-sm": ["12px", { lineHeight: "16px", fontWeight: "500" }]
      }
    }
  },
  plugins: []
}
