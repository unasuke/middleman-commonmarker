# frozen_string_literal: true

require "test_helper"

class CommonmarkerTemplateTest < Minitest::Test
  # Build a template instance; prepare runs on init and computes
  # @commonmarker_options from the given options.
  def build(opts = {})
    Middleman::Renderers::CommonmarkerTemplate.new(nil, 1, opts) { "" }
  end

  def options_for(opts)
    build(opts).instance_variable_get(:@commonmarker_options)
  end

  def image_node(markdown)
    node = Commonmarker.parse(markdown)
    found = nil
    node.walk { |n| found = n if n.type == :image }
    found
  end

  def test_build_options_distributes_into_nested_structure
    opts = options_for(table: true, hardbreaks: true)
    assert_equal true, opts[:extension][:table]
    assert_equal true, opts[:render][:hardbreaks]
  end

  def test_smartypants_maps_to_parse_smart
    assert_equal true, options_for(smartypants: true)[:parse][:smart]
  end

  def test_unknown_keys_are_ignored
    opts = options_for(unknown_key: "x")
    refute opts[:parse].key?(:unknown_key)
    refute opts[:render].key?(:unknown_key)
    refute opts[:extension].key?(:unknown_key)
  end

  def test_extract_text_concatenates_descendant_text
    assert_equal "an alt text", build.send(:extract_text, image_node("![an *alt* text](x.gif)"))
  end

  def test_extract_text_returns_empty_string_for_empty_alt
    assert_equal "", build.send(:extract_text, image_node("![](x.gif)"))
  end

  def test_html_node_from_returns_an_html_node
    node = build.send(:html_node_from, %(<img src="/x.gif" />))
    assert_includes %i[html_inline html_block], node.type
  end

  def test_html_node_from_returns_nil_when_no_html_present
    assert_nil build.send(:html_node_from, "just plain text")
  end
end
