# frozen_string_literal: true

require "middleman-core"
require "middleman-commonmarker/version"

Middleman::Extensions.register :commonmarker do
  require "middleman-commonmarker/extension"
  Middleman::CommonmarkerExtension
end
