require "minitest_helper"

class TestConsent < Bridgetown::Test
  ["/", "/shop/", "/events/"].each do |path|
    describe path do
      it "carries the consent bar, hidden until JS reads the stored choice" do
        html get path

        bar = document.query_selector("#consent-bar")
        expect(bar).wont_be_nil
        expect(bar.attributes.key?("hidden")).must_equal true
        expect(bar["aria-label"]).wont_be_nil
        expect(bar.query_selector("[data-consent='granted']")).wont_be_nil
        expect(bar.query_selector("[data-consent='denied']")).wont_be_nil
      end
    end
  end

  ["/404.html", "/500.html"].each do |path|
    describe path do
      it "asks nothing, since nothing is tracked" do
        html get path

        expect(document.query_selector("#consent-bar")).must_be_nil
      end
    end
  end
end
