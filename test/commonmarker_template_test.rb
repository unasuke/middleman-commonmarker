# frozen_string_literal: true

require "test_helper"
require "pathname"

class CommonmarkerTemplateTest < Minitest::Test
  CODE_BLOCK = "```ruby\nputs 1\n```\n"
  THEMES_DIR = File.expand_path("fixtures", __dir__)

  # Build a template instance whose source is `body`; prepare runs on init
  # and computes @commonmarker_plugins and @commonmarker_options from the
  # given options.
  def build(opts = {}, body = "")
    Middleman::Renderers::CommonmarkerTemplate.new(nil, 1, opts) { body }
  end

  def options_for(opts)
    build(opts).instance_variable_get(:@commonmarker_options)
  end

  # Render CODE_BLOCK with the given options. Tilt passes Object.new as the
  # scope, so this goes through the scope branch of evaluate.
  def html_for(opts)
    build(opts, CODE_BLOCK).render
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

  def test_plugins_unset_matches_commonmarker_default
    template = build({}, CODE_BLOCK)
    opts = template.send(:render_options_with_unsafe)
    expected = Commonmarker.parse(CODE_BLOCK, options: opts).to_html(options: opts)
    assert_equal expected, template.render
  end

  def test_plugins_with_builtin_theme
    html = html_for(plugins: {syntax_highlighter: {theme: "InspiredGitHub"}})
    assert_includes html, "background-color:#ffffff"
  end

  def test_plugins_with_theme_from_path
    html = html_for(plugins: {syntax_highlighter: {theme: "test-theme", path: THEMES_DIR}})
    assert_includes html, "background-color:#123456"
  end

  def test_plugins_with_path_only_keeps_default_theme
    assert_equal html_for({}), html_for(plugins: {syntax_highlighter: {path: THEMES_DIR}})
  end

  def test_plugins_with_empty_theme_outputs_classes
    html = html_for(plugins: {syntax_highlighter: {theme: ""}})
    assert_includes html, %(<pre class="syntax-highlighting">)
    refute_includes html, "style="
  end

  def test_plugins_disabling_highlighter
    [{syntax_highlighter: nil}, {}, nil].each do |plugins|
      refute_includes html_for(plugins:), "style=", "plugins: #{plugins.inspect}"
    end
  end

  def test_plugins_with_misspelled_key_disables_highlighter
    refute_includes html_for(plugins: {syntax_highlight: {theme: "InspiredGitHub"}}), "style="
  end

  def test_plugins_with_string_keys
    assert_equal html_for(plugins: {syntax_highlighter: {theme: "InspiredGitHub"}}),
      html_for(plugins: {"syntax_highlighter" => {"theme" => "InspiredGitHub"}})
  end

  def test_later_plugins_key_takes_precedence
    inspired = {syntax_highlighter: {theme: "InspiredGitHub"}}
    assert_equal html_for(plugins: inspired), html_for({:plugins => nil, "plugins" => inspired})
    assert_equal html_for(plugins: nil), html_for({"plugins" => inspired, :plugins => nil})
  end

  def test_plugins_with_unknown_theme_raises
    assert_raises(ArgumentError) { html_for(plugins: {syntax_highlighter: {theme: "no-such-theme"}}) }
  end

  def test_plugins_with_empty_highlighter_raises
    assert_raises(TypeError) { html_for(plugins: {syntax_highlighter: {}}) }
  end

  def test_plugins_with_nil_theme_raises
    assert_raises(TypeError) { html_for(plugins: {syntax_highlighter: {theme: nil}}) }
  end

  def test_plugins_with_non_hash_value_raises
    {"x" => NoMethodError, [1] => TypeError}.each do |plugins, error|
      assert_raises(error, "plugins: #{plugins.inspect}") { html_for(plugins:) }
    end
  end

  def test_plugins_with_pathname_path_raises
    assert_raises(TypeError) do
      html_for(plugins: {syntax_highlighter: {theme: "test-theme", path: Pathname(THEMES_DIR)}})
    end
  end

  def test_plugins_are_not_mixed_into_commonmarker_options
    opts = options_for(plugins: {syntax_highlighter: {theme: "InspiredGitHub"}})
    refute opts[:parse].key?(:plugins)
    refute opts[:render].key?(:plugins)
    refute opts[:extension].key?(:plugins)
  end

  def test_plugins_apply_without_scope
    template = build({plugins: {syntax_highlighter: {theme: "InspiredGitHub"}}}, CODE_BLOCK)
    assert_includes template.send(:evaluate, nil, {}), "background-color:#ffffff"
  end
end
