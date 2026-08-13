require "minitest_helper"

class TestPages < Bridgetown::Test
  PAGES = {
    "/" => { heading: "Artisanal precision in every loaf", nav_key: "home" },
    "/shop/" => { heading: "Our Bakes", nav_key: "shop" },
    "/events/" => { heading: "Community Events", nav_key: "events" },
  }.freeze

  PAGES.each do |path, expected|
    describe path do
      it "renders its heading" do
        html get path

        expect(document.query_selector("h1").text).must_include expected[:heading]
      end

      it "marks only its own nav link as current" do
        html get path

        current = document.query_selector_all("nav a[aria-current='page']")
        expect(current.length).must_equal 1
        expect(current.first["data-path"]).must_equal expected[:nav_key]
      end
    end
  end

  describe "shop" do
    it "lists every product from the data file" do
      html get "/shop/"

      names = document.query_selector_all("article h3").map(&:text)
      expect(names).must_equal ["Country Sourdough", "Butter Croissant", "Olive Focaccia", "Danish Rye"]
    end

    it "renders a badge only for products that define one" do
      html get "/shop/"

      badges = document.query_selector_all("article .absolute.top-3 span").map { _1.text.strip }
      expect(badges).must_equal %w[Bestseller Vegan]
    end
  end

  describe "events" do
    it "lists every event from the data file" do
      html get "/events/"

      titles = document.query_selector_all("article h2").map(&:text)
      expect(titles).must_equal ["Sourdough Fundamentals", "Autumn Pastry Premiere", "Harvest Community Dinner"]
    end

    it "gives each event its own call to action" do
      html get "/events/"

      # The trailing icon is a Material Symbols ligature, so it shows up in the
      # link's text too — take the label line only.
      ctas = document.query_selector_all("article a[aria-label]").map do
        _1.text.split("\n").map(&:strip).reject(&:empty?).first
      end
      expect(ctas).must_equal ["Register", "Learn More", "Reserve Seat"]
    end
  end
end
