require "minitest_helper"

class TestSeo < Bridgetown::Test
  SITE_URL = "https://meadowbrookbakery.com".freeze
  PAGES = {
    "/" => "#{SITE_URL}/",
    "/shop/" => "#{SITE_URL}/shop/",
    "/events/" => "#{SITE_URL}/events/",
  }.freeze

  def meta(property)
    document.query_selector("meta[property='#{property}']")&.[]("content")
  end

  PAGES.each do |path, canonical|
    describe path do
      it "declares itself canonical at its absolute URL" do
        html get path

        expect(document.query_selector("link[rel='canonical']")["href"]).must_equal canonical
      end

      it "points og:url at the same place as the canonical link" do
        html get path

        expect(meta("og:url")).must_equal canonical
      end

      it "repeats the page title in og:title" do
        html get path

        expect(meta("og:title")).must_equal document.query_selector("title").text
      end

      it "gives og:image an absolute URL" do
        html get path

        # Scrapers do not resolve relative image paths, so a bare "/images/..."
        # here would silently yield no preview image at all.
        expect(meta("og:image")).must_match %r{\Ahttps://}
      end
    end
  end

  describe "/sitemap.xml" do
    it "lists every browsable page" do
      locs = get("/sitemap.xml").body.scan(%r{<loc>(.*?)</loc>}).flatten

      # An exact match, so this also pins the absence of /404.html and /500.html.
      expect(locs.sort).must_equal PAGES.values.sort
    end
  end

  describe "/robots.txt" do
    it "opens the site to crawlers and points them at the sitemap" do
      body = get("/robots.txt").body

      expect(body).must_include "User-agent: *"
      expect(body).must_include "Sitemap: #{SITE_URL}/sitemap.xml"
    end
  end

  ["/404.html", "/500.html"].each do |path|
    describe path do
      it "asks not to be indexed" do
        html get path

        expect(document.query_selector("meta[name='robots']")["content"]).must_equal "noindex"
      end

      it "carries no canonical or og:url, which could only be wrong here" do
        html get path

        expect(document.query_selector("link[rel='canonical']")).must_be_nil
        expect(meta("og:url")).must_be_nil
      end

      it "still names itself in the title" do
        html get path

        expect(document.query_selector("title").text).must_include "Meadowbrook Bakery"
      end
    end
  end
end
