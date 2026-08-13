require "minitest_helper"

class TestDisclaimer < Bridgetown::Test
  PATHS = ["/", "/shop/", "/events/"].freeze

  PATHS.each do |path|
    describe path do
      it "carries the disclaimer, hidden until JS reads the querystring" do
        html get path

        modal = document.query_selector("#site-disclaimer")
        expect(modal).wont_be_nil
        # Without `hidden` in the markup the notice would flash on every load,
        # including for people who asked to skip it.
        expect(modal.attributes.key?("hidden")).must_equal true
      end

      it "says plainly that the business is not real" do
        html get path

        text = document.query_selector("#site-disclaimer").text
        expect(text).must_include "not a real business"
        expect(text).must_include "Bloomlight"
      end

      it "invites a real bakery of this name to get in touch" do
        html get path

        modal = document.query_selector("#site-disclaimer")
        expect(modal.text).must_include "Meadowbrook Bakery, or a business with a name close to it"
        expect(modal.query_selector("a[href^='mailto:']")["href"]).must_include "hello@bloomlight.app"
      end

      it "is a labelled dialog with a way out" do
        html get path

        modal = document.query_selector("#site-disclaimer")
        expect(modal["role"]).must_equal "dialog"
        expect(modal["aria-modal"]).must_equal "true"
        expect(document.query_selector("##{modal["aria-labelledby"]}")).wont_be_nil
        expect(modal.query_selector_all("[data-disclaimer-dismiss]").length).must_be :>=, 1
        expect(modal.query_selector("[data-disclaimer-primary]")).wont_be_nil
      end

      it "links a favicon" do
        html get path

        icons = document.query_selector_all("link[rel='icon']").map { _1["href"] }
        expect(icons).must_include "/images/favicon.svg"
        expect(icons).must_include "/favicon.ico"
        expect(document.query_selector("link[rel='apple-touch-icon']")).wont_be_nil
      end
    end
  end
end
