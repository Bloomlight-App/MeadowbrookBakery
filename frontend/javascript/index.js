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

// Consent bar. The stored answer is read again, inline and before the Google
// tags load, by src/_partials/_trackers.erb — the key must match.
const CONSENT_KEY = "consent"
const CONSENT_TYPES = ["ad_storage", "ad_user_data", "ad_personalization", "analytics_storage"]

function storedConsent() {
  try {
    return window.localStorage.getItem(CONSENT_KEY)
  } catch {
    return null
  }
}

function setupConsent() {
  const bar = document.getElementById("consent-bar")
  if (!bar || storedConsent()) return

  bar.querySelectorAll("[data-consent]").forEach((button) => {
    button.addEventListener("click", () => {
      const choice = button.dataset.consent
      try {
        window.localStorage.setItem(CONSENT_KEY, choice)
      } catch {
        // Not remembered: the bar asks again next page load.
      }
      if (choice === "granted") {
        window.gtag?.("consent", "update", Object.fromEntries(CONSENT_TYPES.map((type) => [type, "granted"])))
      }
      bar.setAttribute("hidden", "")
    })
  })

  bar.removeAttribute("hidden")
}

document.addEventListener("DOMContentLoaded", setupConsent)

const { bloomlightPage, bloomlightIdleMs } = document.body.dataset

if (bloomlightPage) {
  const clickKey = "bloomlight-demo-clicks"
  const clickLimit = 8
  let demoClicks = 0
  let idleTimer
  let revealFade
  let revealing = false

  async function revealBloomlight() {
    if (revealing) return
    revealing = true
    clearTimeout(idleTimer)
    demoClicks = 0
    try {
      window.sessionStorage.removeItem(clickKey)
    } catch {
      // The in-memory count is already reset.
    }
    if (document.body.animate && !window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      revealFade = document.body.animate([{ opacity: 1 }, { opacity: 0 }], {
        duration: 220,
        easing: "ease-in",
        fill: "forwards",
      })
      try {
        await revealFade.finished
      } catch {
        return
      }
    }
    window.location.assign(bloomlightPage)
  }

  function resetIdleTimer() {
    clearTimeout(idleTimer)
    if (!revealing && !document.hidden) {
      idleTimer = setTimeout(revealBloomlight, Number(bloomlightIdleMs))
    }
  }

  for (const activity of ["pointermove", "pointerdown", "keydown", "scroll", "click"]) {
    document.addEventListener(activity, resetIdleTimer, { capture: true, passive: true })
  }
  document.addEventListener("visibilitychange", resetIdleTimer)
  window.addEventListener("pagehide", () => clearTimeout(idleTimer))
  window.addEventListener("pageshow", () => {
    revealFade?.cancel()
    revealFade = undefined
    revealing = false
    resetIdleTimer()
  })

  document.addEventListener("click", (event) => {
    if (revealing || event.defaultPrevented || event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return
    if (!event.target.closest("main, header")) return

    try {
      demoClicks = Number(window.sessionStorage.getItem(clickKey)) || 0
    } catch {
      // Keep counting on the current page when storage is unavailable.
    }
    demoClicks += 1

    if (demoClicks >= clickLimit) {
      event.preventDefault()
      revealBloomlight()
      return
    }

    try {
      window.sessionStorage.setItem(clickKey, String(demoClicks))
    } catch {
      // The in-memory count still works for this page.
    }
  })
}
