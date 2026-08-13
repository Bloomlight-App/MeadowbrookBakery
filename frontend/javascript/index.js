import "$styles/index.css"
import "$styles/syntax-highlighting.css"

// Import all JavaScript & CSS files from src/_components
import components from "$components/**/*.{js,jsx,js.rb,css}"

// Disclaimer modal: shown once per session, unless the URL says otherwise.
const DISCLAIMER_PARAM = "disclaimer"
const DISCLAIMER_KEY = "disclaimer-dismissed"

// sessionStorage throws when access is denied (Safari private mode, sandboxed
// iframes). Failing open means the notice shows — never that it silently
// disappears.
function dismissed() {
  try {
    return window.sessionStorage.getItem(DISCLAIMER_KEY) === "1"
  } catch {
    return false
  }
}

function rememberDismissal() {
  try {
    window.sessionStorage.setItem(DISCLAIMER_KEY, "1")
  } catch {
    // Nothing to do: the notice simply shows again next page load.
  }
}

function setupDisclaimer() {
  const modal = document.getElementById("site-disclaimer")
  if (!modal) return

  const params = new URLSearchParams(window.location.search)
  if (params.get(DISCLAIMER_PARAM) === "off") return
  if (dismissed()) return

  const previouslyFocused = document.activeElement

  const close = () => {
    rememberDismissal()
    modal.setAttribute("hidden", "")
    document.body.classList.remove("overflow-hidden")
    document.removeEventListener("keydown", onKeydown)
    previouslyFocused?.focus?.()
  }

  const onKeydown = (event) => {
    if (event.key === "Escape") close()
  }

  modal.querySelectorAll("[data-disclaimer-dismiss]").forEach((el) => {
    el.addEventListener("click", close)
  })
  // Clicking the scrim, but not the panel inside it, dismisses.
  modal.addEventListener("click", (event) => {
    if (event.target === modal) close()
  })
  document.addEventListener("keydown", onKeydown)

  modal.removeAttribute("hidden")
  document.body.classList.add("overflow-hidden")
  modal.querySelector("[data-disclaimer-primary]")?.focus()
}

document.addEventListener("DOMContentLoaded", setupDisclaimer)
