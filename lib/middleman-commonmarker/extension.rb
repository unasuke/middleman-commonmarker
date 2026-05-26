# frozen_string_literal: true

require "middleman-core"

module Middleman
  class CommonmarkerExtension < ::Middleman::Extension
    # Options forwarded to commonmarker. Accepts the same flat keys as
    # `set :markdown` (e.g. table: true) nested in a Hash, and merges them into
    # the `set :markdown` config (app.config[:markdown]) in after_configuration.
    option :options, {}, "Options forwarded to commonmarker (merged into `set :markdown`)"

    def initialize(app, options_hash = {}, &block)
      super
      require "commonmarker"
      require "middleman-commonmarker/commonmarker_template"
    end

    # Runs after core's :markdown_renderer (before_configuration), so this
    # Tilt.prefer overrides the default Kramdown engine.
    # app.config is still writable here (it is not finalized, since core itself
    # writes cli_options after after_configuration).
    def after_configuration
      unless options.options.empty?
        app.config[:markdown] = (app.config[:markdown] || {}).merge(options.options)
      end

      exts = %w[markdown mdown md mkd mkdn]
      ::Tilt.prefer(::Middleman::Renderers::CommonmarkerTemplate, *exts)
    end
  end
end
