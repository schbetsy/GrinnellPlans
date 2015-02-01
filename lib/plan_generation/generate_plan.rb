module PlanGeneration
  module GeneratePlan

  ALLOWED_HTML = {
      elements: %w[ a b hr i p span pre tt code br ],
      attributes: {
        'a' => ['href'],
        'span' => ['class'],
      },
      protocols: {
        'a' => { 'href' => %w[http https mailto] }
      },
    }

    def remove_disallowed_tags text
      Sanitize.clean text, ALLOWED_HTML
    end

    def process_markdown edit_text
      renderer = Redcarpet::Render::HTML.new hard_wrap: true, no_images: true
      markdown = Redcarpet::Markdown.new(
        renderer,
        no_intra_emphasis: true,
        strikethrough: true,
        lax_html_blocks: true,
        space_after_headers: true
      )
      markdown.render edit_text
    end

    def convert_legacy_tags text
      { u: :underline, strike: :strike, s: :strike }.each do |in_class, out_class|
        pattern = Regexp.new "<#{in_class}>(.*?)<\/#{in_class}>"
        replacement = "<span class=\"#{out_class}\">\\1</span>"
        text.gsub! pattern, replacement
      end
      text
    end

  end
end
