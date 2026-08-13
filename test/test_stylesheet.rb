require "minitest_helper"
require "yaml"

# The product badges and event chips carry Tailwind classes inside the data
# files, so those files have to be in `content` in tailwind.config.js. Nothing in
# the rendered HTML catches it when they aren't — the class attribute still
# renders, the utility just never gets compiled and the tint silently vanishes.
class TestStylesheet < Bridgetown::Test
  ROOT = File.expand_path("..", __dir__)

  def stylesheet
    path = Dir[File.join(ROOT, "output", "_bridgetown", "static", "*.css")]
      .reject { _1.end_with?(".map") }.first
    raise "No compiled stylesheet found — run `bin/bridgetown deploy` first" unless path

    File.read(path)
  end

  def tint_classes_in(data_file, key)
    YAML.load_file(File.join(ROOT, "src", "_data", data_file), permitted_classes: [Date])
      .filter_map { _1[key] }
      .flat_map(&:split)
      .select { _1.start_with?("bg-") }
  end

  describe "compiled stylesheet" do
    it "emits every product badge tint used in the data file" do
      css = stylesheet
      classes = tint_classes_in("products.yml", "badge_classes")

      expect(classes).wont_be_empty
      classes.each { expect(css).must_include ".#{_1.sub("/", "\\/")}{" }
    end

    it "emits every event chip tint used in the data file" do
      css = stylesheet
      classes = tint_classes_in("events.yml", "category_classes")

      expect(classes).wont_be_empty
      classes.each { expect(css).must_include ".#{_1.sub("/", "\\/")}{" }
    end

    # The disclaimer root is a `flex` element, which ties with preflight's
    # `[hidden] { display: none }` and wins on source order. Lose this rule and
    # the notice is permanently on screen and ?disclaimer=off does nothing.
    it "keeps the rule that lets the disclaimer stay hidden" do
      expect(stylesheet).must_include "#site-disclaimer[hidden]{display:none}"
    end
  end

  describe "favicon" do
    it "ships every icon the pages link to" do
      %w[favicon.ico images/favicon.svg images/apple-touch-icon.png].each do
        expect(File.exist?(File.join(ROOT, "output", _1))).must_equal true
      end
    end
  end
end
