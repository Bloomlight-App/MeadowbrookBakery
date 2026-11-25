require "minitest_helper"
require "json"

class TestSeo < Bridgetown::Test
  SITE_URL = "https://meadowbrookbakery.com".freeze
  PAGES = {
    "/" => "#{SITE_URL}/",
    "/shop/" => "#{SITE_URL}/shop/",
    "/events/" => "#{SITE_URL}/events/",
    "/bloomlight/" => "#{SITE_URL}/bloomlight/",
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

  describe "/bloomlight/ metadata" do
    it "describes Bloomlight and serves its branded social preview image" do
      html get "/bloomlight/"

      description = document.query_selector("meta[name='description']")["content"]
      expect(description).must_include "Bloomlight monitors website performance"
      expect(meta("og:description")).must_equal description
      expect(document.query_selector("meta[name='twitter:card']")["content"]).must_equal "summary_large_image"
      expect(meta("og:image")).must_equal "#{SITE_URL}/images/bloomlight-social.jpg"
      expect(meta("og:image:alt")).must_include "Meadowbrook Bakery storefront"
      expect(get("/images/bloomlight-social.jpg").status).must_equal 200
    end

    it "identifies the canonical page and its subject in valid JSON-LD" do
      html get "/bloomlight/"

      schema = JSON.parse(document.query_selector("script[type='application/ld+json']").text)
      expect(schema["@context"]).must_equal "https://schema.org"
      expect(schema["@type"]).must_equal "AboutPage"
      expect(schema["url"]).must_equal PAGES.fetch("/bloomlight/")
      expect(schema["mainEntity"]).must_equal({
        "@type" => "WebApplication",
        "name" => "Bloomlight",
        "url" => "https://bloomlight.app/",
      })
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
