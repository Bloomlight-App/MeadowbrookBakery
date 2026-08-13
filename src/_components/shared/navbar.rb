class Shared::Navbar < Bridgetown::Component
  # The design marks the current page by *dropping* the label type scale, so the
  # active link picks up the body font and sits slightly larger than its siblings.
  INACTIVE_CLASSES = "font-label-lg text-label-lg text-on-surface-variant hover:text-primary transition-colors py-2".freeze
  ACTIVE_CLASSES = "transition-colors py-2 text-primary font-medium border-b-2 border-primary".freeze

  LINKS = [
    { key: "home", label: "Home", href: "/" },
    { key: "shop", label: "Shop", href: "/shop" },
    { key: "events", label: "Events", href: "/events" },
    { key: "our-story", label: "Our Story", href: "/#our-story" },
  ].freeze

  def initialize(metadata:, resource:)
    @metadata, @resource = metadata, resource
  end

  def current_key = @resource&.data&.nav_key

  def active?(link) = link[:key] == current_key
end
