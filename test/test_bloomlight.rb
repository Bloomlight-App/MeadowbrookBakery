require "minitest_helper"

class TestBloomlight < Bridgetown::Test
  it "points the bakery pages at the Bloomlight reveal" do
    ["/", "/shop/", "/events/"].each do |path|
      html get path

      expect(document.query_selector("body")["data-bloomlight-page"]).must_equal "/bloomlight/"
    end
  end

  it "enables the thirty-second idle reveal only on bakery pages" do
    ["/", "/shop/", "/events/"].each do |path|
      html get path

      expect(document.query_selector("body")["data-bloomlight-idle-ms"]).must_equal "30000"
    end

    html get "/bloomlight/"
    expect(document.query_selector("body")["data-bloomlight-idle-ms"]).must_be_nil
  end

  it "shows the butterfly toy and both Bloomlight links on the reveal page" do
    html get "/bloomlight/"

    expect(document.query_selector("h1").text).must_equal "Meet Bloomlight"
    expect(document.query_selector(".lockup")).wont_be_nil
    expect(document.query_selector("#flutter")).wont_be_nil
    links = document.query_selector_all("nav a").map { _1["href"] }
    expect(links).must_include "https://bloomlight.app/"
    expect(links).must_include "https://bloomlight.app/sample-report"
    expect(links).must_include "/"
    expect(document.query_selector("body")["data-bloomlight-page"]).must_be_nil
  end
end
