# The baseline build: the finished site rendered badly on purpose, so the two
# can be put side by side under Lighthouse.
#
# It is a post-render transform rather than a second set of templates, and that
# is the whole point — the baseline is *derived* from the good site every time
# it is built, so it can never drift into being a different site that merely
# looks worse. Each method below undoes exactly one thing the real site does
# right, and names the Lighthouse audit it is aiming at.
#
# Nothing here touches Bridgetown: it takes a parsed document and mutates it.
# Builders::BaselineBuild is the half that knows about the site, and keeping the
# two apart is what lets these be unit tested without booting one.
module Baseline
  # ~1.5:1 against the #fff8f5 surface. Still legible on a good monitor in a
  # dark room, which is how text like this survives review in the real world.
  WASHED_TEXT = "#c9cec9"
  # ~1.9:1 against the near-black #061b0e primary button.
  WASHED_BUTTON_TEXT = "#2f4a38"
  BODY_FONT_SIZE = "10px"

  module_function

  # @param doc [Nokolexbor::Document] a rendered page
  # @param photos_dir [String] source directory to check for .png originals
  def degrade(doc, photos_dir:)
    serve_oversized_images(doc, photos_dir)
    load_every_image_eagerly(doc)
    block_rendering_on_the_bundle(doc)
    strip_image_alt_text(doc)
    wash_out_muted_text(doc)
    wash_out_primary_buttons(doc)
    shrink_body_copy(doc)
    break_heading_order(doc)
    unlabel_icon_buttons(doc)
    drop_lang_attribute(doc)
    strip_meta_description(doc)
    strip_discovery_tags(doc)
    ask_not_to_be_indexed(doc)
    doc
  end

  # "Serve images in next-gen formats" / "Efficiently encode images".
  # Only swaps where a .png original really sits beside the shipped image.
  def serve_oversized_images(doc, photos_dir)
    doc.css("img[src]").each do |img|
      png = img["src"].sub(/\.(?:webp|jpe?g)\z/, ".png")
      next if png == img["src"]
      next unless File.exist?(File.join(photos_dir, File.basename(png)))

      img["src"] = png
    end
  end

  # "Defer offscreen images".
  def load_every_image_eagerly(doc)
    doc.css("img[loading]").each { _1.remove_attribute("loading") }
  end

  # "Eliminate render-blocking resources".
  def block_rendering_on_the_bundle(doc)
    doc.css("script[src][defer]").each { _1.remove_attribute("defer") }
  end

  # "Image elements do not have [alt] attributes".
  def strip_image_alt_text(doc)
    doc.css("img[alt]").each { _1.remove_attribute("alt") }
  end

  # "Background and foreground colors do not have a sufficient contrast ratio".
  # Written inline rather than by swapping in a paler utility class: Tailwind
  # only compiles classes it can see, so an unknown class yields no style at all
  # and would degrade nothing. test/test_stylesheet.rb guards the same trap on
  # the real site.
  def wash_out_muted_text(doc)
    doc.css(".text-on-surface-variant").each { add_style(_1, "color:#{WASHED_TEXT}") }
  end

  def wash_out_primary_buttons(doc)
    doc.css(".bg-primary").each { add_style(_1, "color:#{WASHED_BUTTON_TEXT}") }
  end

  # "Document doesn't use legible font sizes".
  def shrink_body_copy(doc)
    doc.css("p").each { add_style(_1, "font-size:#{BODY_FONT_SIZE}") }
  end

  # "Heading elements are not in a sequentially-descending order".
  # Demoting every h2 to h4 makes each page jump straight from h1 to h4.
  def break_heading_order(doc)
    doc.css("h2").each { retag(_1, "h4") }
  end

  # "Buttons do not have an accessible name". These buttons contain only a
  # Material Symbols ligature, so with no label there is nothing to announce.
  def unlabel_icon_buttons(doc)
    doc.css("button[aria-label]").each { _1.remove_attribute("aria-label") }
  end

  # "<html> element does not have a [lang] attribute".
  def drop_lang_attribute(doc)
    doc.at_css("html")&.remove_attribute("lang")
  end

  # "Document does not have a meta description".
  def strip_meta_description(doc)
    doc.at_css('meta[name="description"]')&.remove
  end

  # "Document does not have a valid rel=canonical", and no share preview left
  # anywhere either.
  def strip_discovery_tags(doc)
    doc.at_css('link[rel="canonical"]')&.remove
    doc.css('meta[property^="og:"]').each(&:remove)
  end

  # Not degradation for its own sake: the baseline is served from the live site
  # and must never be indexed in place of the real one. Lighthouse scores it as
  # "Page is blocked from indexing", which is fair enough here.
  def ask_not_to_be_indexed(doc)
    head = doc.at_css("head") or return

    meta = doc.create_element("meta")
    meta["name"] = "robots"
    meta["content"] = "noindex"
    head.add_child(meta)
  end

  def add_style(node, declaration)
    existing = node["style"]
    node["style"] = existing.nil? || existing.empty? ? declaration : "#{existing};#{declaration}"
  end

  # Nokolexbor has no `name=`, so the node is rebuilt under the new tag.
  def retag(node, tag_name)
    replacement = node.document.create_element(tag_name)
    node.attributes.each { |name, attr| replacement[name] = attr.value }
    replacement.inner_html = node.inner_html
    node.replace(replacement)
  end
end
