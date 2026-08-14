require "minitest_helper"
# Required directly: the plugins autoloader is a build-time thing and is not
# active in the test process.
require_relative "../plugins/baseline"

# Unit tests for the degradations themselves. Each one is fed a scrap of HTML
# rather than a built page, so a failure names the transform that broke.
# test_seo.rb and test_pages.rb cover the good site these are derived from.
class TestBaseline < Bridgetown::Test
  PHOTOS = File.expand_path("../src/images/photos", __dir__).freeze

  def doc(html) = Nokolexbor::HTML("<html lang=\"en\"><head></head><body>#{html}</body></html>")

  describe "images" do
    it "swaps in the png original when one exists beside the shipped image" do
      d = doc(%(<img src="/images/photos/olive-focaccia.webp">))

      Baseline.serve_oversized_images(d, PHOTOS)

      expect(d.at_css("img")["src"]).must_equal "/images/photos/olive-focaccia.png"
    end

    it "leaves images alone when there is no png to swap to" do
      d = doc(%(<img src="/images/photos/hero-meadow.jpg">))

      Baseline.serve_oversized_images(d, PHOTOS)

      expect(d.at_css("img")["src"]).must_equal "/images/photos/hero-meadow.jpg"
    end

    it "stops them being lazy loaded" do
      d = doc(%(<img src="a.png" loading="lazy">))

      Baseline.load_every_image_eagerly(d)

      expect(d.at_css("img")["loading"]).must_be_nil
    end

    it "strips alt text" do
      d = doc(%(<img src="a.png" alt="A rustic loaf">))

      Baseline.strip_image_alt_text(d)

      expect(d.at_css("img")["alt"]).must_be_nil
    end
  end

  describe "contrast" do
    it "washes out muted body text" do
      d = doc(%(<p class="text-on-surface-variant">Baked daily</p>))

      Baseline.wash_out_muted_text(d)

      expect(d.at_css("p")["style"]).must_include Baseline::WASHED_TEXT
    end

    it "washes out text on primary buttons" do
      d = doc(%(<button class="bg-primary text-on-primary">Add</button>))

      Baseline.wash_out_primary_buttons(d)

      expect(d.at_css("button")["style"]).must_include Baseline::WASHED_BUTTON_TEXT
    end

    it "keeps any style already on the element" do
      d = doc(%(<p class="text-on-surface-variant" style="margin:0">Hi</p>))

      Baseline.wash_out_muted_text(d)

      expect(d.at_css("p")["style"]).must_include "margin:0"
    end
  end

  describe "headings" do
    it "demotes h2 to h4 so the sequence skips a level" do
      d = doc(%(<h1>Shop</h1><h2 class="font-headline-lg" id="bakes">Our Bakes</h2>))

      Baseline.break_heading_order(d)

      expect(d.at_css("h2")).must_be_nil
      expect(d.at_css("h4").text).must_equal "Our Bakes"
    end

    it "carries the attributes and markup of the heading it replaces" do
      d = doc(%(<h2 class="font-headline-lg" id="bakes">Our <em>Bakes</em></h2>))

      Baseline.break_heading_order(d)

      h4 = d.at_css("h4")
      expect(h4["class"]).must_equal "font-headline-lg"
      expect(h4["id"]).must_equal "bakes"
      expect(h4.inner_html).must_include "<em>Bakes</em>"
    end
  end

  describe "the rest of the page" do
    it "leaves icon buttons with no accessible name" do
      d = doc(%(<button aria-label="Add to cart"><span>add_shopping_cart</span></button>))

      Baseline.unlabel_icon_buttons(d)

      expect(d.at_css("button")["aria-label"]).must_be_nil
    end

    it "drops the document language" do
      d = doc("")

      Baseline.drop_lang_attribute(d)

      expect(d.at_css("html")["lang"]).must_be_nil
    end

    it "makes the bundle render-blocking" do
      d = doc(%(<script src="/x.js" defer></script>))

      Baseline.block_rendering_on_the_bundle(d)

      expect(d.at_css("script")["defer"]).must_be_nil
    end

    it "shrinks body copy below the legible threshold" do
      d = doc("<p>Baked daily</p>")

      Baseline.shrink_body_copy(d)

      expect(d.at_css("p")["style"]).must_include Baseline::BODY_FONT_SIZE
    end
  end

  describe "discoverability" do
    it "removes the meta description" do
      d = Nokolexbor::HTML(%(<html><head><meta name="description" content="d"></head></html>))

      Baseline.strip_meta_description(d)

      expect(d.at_css('meta[name="description"]')).must_be_nil
    end

    it "removes the canonical link and every og tag" do
      d = Nokolexbor::HTML(<<~HTML)
        <html><head>
          <link rel="canonical" href="https://meadowbrookbakery.com/shop/">
          <meta property="og:url" content="https://meadowbrookbakery.com/shop/">
          <meta property="og:image" content="https://meadowbrookbakery.com/i.jpg">
        </head></html>
      HTML

      Baseline.strip_discovery_tags(d)

      expect(d.at_css('link[rel="canonical"]')).must_be_nil
      expect(d.css('meta[property^="og:"]').length).must_equal 0
    end

    # The baseline is served from the live site, so it has to stay out of the
    # index even though being unindexable is itself one of the bad marks.
    it "asks not to be indexed" do
      d = doc("")

      Baseline.ask_not_to_be_indexed(d)

      expect(d.at_css('meta[name="robots"]')["content"]).must_equal "noindex"
    end
  end
end
