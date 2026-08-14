module Builders
  # Runs the Baseline degradations over every rendered page, but only when the
  # build asked for them. Without the env var this builder does nothing at all,
  # so the ordinary build is untouched.
  class BaselineBuild < SiteBuilder
    def build
      return unless ENV["BLOOMLIGHT_BASELINE"]

      photos_dir = site.in_source_dir("images", "photos")
      inspect_html { |doc| ::Baseline.degrade(doc, photos_dir: photos_dir) }
    end
  end
end
