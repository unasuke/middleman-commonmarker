# frozen_string_literal: true

require "commonmarker"
require "active_support/core_ext/module/attribute_accessors"

module Middleman
  module Renderers
    # Tilt template that renders Markdown with commonmarker, walking the AST to
    # transform image and link nodes through Middleman's helpers.
    class CommonmarkerTemplate < ::Tilt::Template
      self.default_mime_type = "text/html"
      cattr_accessor :scope

      DEFAULT_PARSE_OPTIONS = {smart: false, default_info_string: nil}.freeze
      DEFAULT_RENDER_OPTIONS = {hardbreaks: false, github_pre_lang: false, width: 80,
                                unsafe: false, escape: false, sourcepos: false}.freeze
      DEFAULT_EXTENSION_OPTIONS = {strikethrough: false, tagfilter: false, table: false,
                                   autolink: false, tasklist: false, superscript: false,
                                   header_ids: nil, footnotes: false, description_lists: false,
                                   front_matter_delimiter: nil, shortcodes: false}.freeze

      def prepare
        @context = options.delete(:context)
        @commonmarker_options = build_commonmarker_options
      end

      def evaluate(scope, _locals, &_block)
        self.class.scope = @context || scope
        doc = ::Commonmarker.parse(data, options: @commonmarker_options)

        if self.class.scope
          doc.walk do |node|
            case node.type
            when :image then transform_image_node(node)
            when :link then transform_link_node(node)
            end
          end
          # Force unsafe so the injected raw <img> HTML is emitted.
          return doc.to_html(options: render_options_with_unsafe)
        end

        doc.to_html(options: @commonmarker_options)
      end

      private

      # Replace the image node with the HTML produced by image_tag (an
      # html_inline/html_block node). When html_node_from returns nil (no such
      # node), skip the replacement and keep the original image node, falling
      # back to commonmarker's default <img> output.
      def transform_image_node(node)
        alt = extract_text(node)
        html = scope.image_tag(node.url, alt: alt, title: node.title)
        replacement = html_node_from(html)
        node.replace(replacement) if replacement
      end

      # Only rewrite the URL of a link (the inner inline elements are kept;
      # commonmarker preserves the title).
      def transform_link_node(node)
        return if node.url.start_with?("mailto:")

        node.url = scope.url_for(node.url)
      end

      # Concatenate the descendant text nodes to build the alt text.
      def extract_text(node)
        text = +""
        node.walk { |n| text << n.string_content if n.type == :text }
        text
      end

      # Turn the HTML string returned by image_tag into a Commonmarker node.
      def html_node_from(html)
        parsed = ::Commonmarker.parse(html)
        parsed.walk { |n| return n if %i[html_inline html_block].include?(n.type) }
        nil
      end

      def render_options_with_unsafe
        @commonmarker_options.merge(
          render: @commonmarker_options[:render].merge(unsafe: true)
        )
      end

      # Distribute the flat `set :markdown, ...` options into the
      # parse/render/extension nested structure, mapping `smartypants` to
      # parse.smart.
      def build_commonmarker_options
        opts = {
          parse: DEFAULT_PARSE_OPTIONS.dup,
          render: DEFAULT_RENDER_OPTIONS.dup,
          extension: DEFAULT_EXTENSION_OPTIONS.dup
        }

        # smartypants maps to commonmarker's parse.smart.
        opts[:parse][:smart] = true if options.delete(:smartypants)

        # Distribute flat options into the nested structure.
        options.each do |key, value|
          key_sym = key.to_sym
          if DEFAULT_PARSE_OPTIONS.key?(key_sym)
            opts[:parse][key_sym] = value
          elsif DEFAULT_RENDER_OPTIONS.key?(key_sym)
            opts[:render][key_sym] = value
          elsif DEFAULT_EXTENSION_OPTIONS.key?(key_sym)
            opts[:extension][key_sym] = value
          end
        end

        opts
      end
    end

    ::Tilt.register CommonmarkerTemplate, "markdown", "mkd", "md"
  end
end
