require "minitest_helper"

# The bakery carries trackers only so that the Bloomlight demo has something to
# detect on it — src/_partials/_trackers.erb explains why every id is fictional.
#
# The contract is not "the snippets are present". It is that the URLs the page
# ends up requesting match the signatures Bloomlight matches them against, which
# live in `app/lib/tech_catalog.rb` in that repo and are copied into `pattern`
# below. `request` is the URL a scan will see, and `literals` are the pieces of
# it the page has to carry for that request to happen at all — three of the five
# snippets assemble their URL at runtime, so it is never in the markup whole.
#
# Google Ads is the trap this guards. Move its id into the `gtag('config', …)`
# call beside Analytics and the snippets still look right, but nothing on the
# wire carries `AW-` any more and the chip vanishes from the dashboard.
class TestTrackers < Bridgetown::Test
  PATHS = ["/", "/shop/", "/events/"].freeze

  TRACKERS = [
    {
      vendor: "Google Analytics 4",
      pattern: %r{gtag/js\?[^"'\s]*\bid=(G-[A-Z0-9]+)}i,
      request: "https://www.googletagmanager.com/gtag/js?id=G-MB1984LOAF",
      identifier: "G-MB1984LOAF",
      literals: ["https://www.googletagmanager.com/gtag/js?id=G-MB1984LOAF"],
    },
    {
      vendor: "Google Ads",
      pattern: %r{gtag/js\?[^"'\s]*\bid=(AW-\d+)}i,
      request: "https://www.googletagmanager.com/gtag/js?id=AW-1984124100",
      identifier: "AW-1984124100",
      literals: ["https://www.googletagmanager.com/gtag/js?id=AW-1984124100"],
    },
    {
      vendor: "Meta Pixel",
      pattern: %r{facebook\.com/tr/?\?[^"'\s]*\bid=(\d+)}i,
      request: "https://www.facebook.com/tr/?id=198412400010001&ev=PageView",
      identifier: "198412400010001",
      literals: ["https://connect.facebook.net/en_US/fbevents.js",
                 "fbq('init', '198412400010001')",
                 "fbq('track', 'PageView')"],
    },
    {
      vendor: "TikTok Pixel",
      pattern: %r{analytics\.tiktok\.com/[^"'\s]*\bsdkid=([A-Z0-9]+)}i,
      request: "https://analytics.tiktok.com/i18n/pixel/events.js?sdkid=CMB1984LOAF124MEADOW&lib=ttq",
      identifier: "CMB1984LOAF124MEADOW",
      literals: ["https://analytics.tiktok.com/i18n/pixel/events.js",
                 "ttq.load('CMB1984LOAF124MEADOW')"],
    },
    {
      vendor: "Microsoft Clarity",
      pattern: %r{clarity\.ms/tag/([a-z0-9]+)}i,
      request: "https://www.clarity.ms/tag/mb1984loaf",
      identifier: "mb1984loaf",
      literals: ['"https://www.clarity.ms/tag/"', '"mb1984loaf"'],
    },
  ].freeze

  TRACKERS.each do |tracker|
    describe tracker[:vendor] do
      it "requests a URL Bloomlight recognises, carrying the account id" do
        match = tracker[:pattern].match(tracker[:request])

        expect(match).wont_be_nil
        expect(match.captures.first).must_equal tracker[:identifier]
      end
    end
  end

  PATHS.each do |path|
    describe path do
      TRACKERS.each do |tracker|
        it "carries every piece the #{tracker[:vendor]} request is built from" do
          body = get(path).body

          tracker[:literals].each { expect(body).must_include _1 }
        end
      end
    end
  end

  ["/404.html", "/500.html"].each do |path|
    describe path do
      it "fires nothing at all" do
        body = get(path).body

        # These pages are reached by accident and ask not to be indexed
        # (test_seo.rb). Beaconing a pageview off one would be counting a visit
        # nobody meant to make.
        TRACKERS.each { expect(body).wont_include _1[:literals].first }
      end
    end
  end
end
