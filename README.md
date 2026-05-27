# Middleman::Commonmarker

A [Middleman](https://middlemanapp.com/) extension that renders Markdown with [commonmarker](https://github.com/gjtorikian/commonmarker) (the Rust/comrak based CommonMark renderer).

It walks the parsed AST and rewrites image and link nodes through Middleman's `image_tag` and `url_for` helpers, so you get sitemap-aware links and `automatic_image_sizes` support — on par with the Redcarpet engine.

## Installation

Add the gem to your Middleman project's `Gemfile`:

```ruby
gem "middleman-commonmarker"
```

Then run `bundle install`.

## Usage

Activate the extension in `config.rb`:

```ruby
activate :commonmarker
```

That's it — Markdown files (`.markdown`, `.md`, `.mkd`, …) are now rendered with commonmarker.

> **Important:** Enable the engine with `activate :commonmarker`, **not** with
> `set :markdown_engine, :commonmarker`. On a released middleman-core the latter
> makes the generic markdown branch look for `Tilt::CommonmarkerTemplate` and
> raise a `NameError`. Always use `activate :commonmarker`.

### Options

Pass commonmarker options either through `set :markdown` (the usual Markdown engine convention) or through the extension's `options:` hash:

```ruby
# via set :markdown
activate :commonmarker
set :markdown, table: true, strikethrough: true, smartypants: true

# via activate
activate :commonmarker, options: { table: true, strikethrough: true }
```

Note that flat keys on `activate` (e.g. `activate :commonmarker, table: true`) are **not** supported — Middleman validates extension options against declared names, so commonmarker options must be nested under `options:`. Options given to `activate` take precedence over `set :markdown` on conflicting keys.

These flat options are mapped onto commonmarker's `parse` / `render` / `extension` option groups (and `smartypants` maps to `parse.smart`).

### Raw HTML is enabled during rendering

To emit the `<img>` HTML produced by `image_tag`, the renderer forces commonmarker's `unsafe: true` during transformation.
As a result, raw HTML in your Markdown is passed through (consistent with Redcarpet's default, where `filter_html` is opt-in).

## Scope

This extension covers helper integration (`image_tag` / `url_for`), `automatic_image_sizes`, and commonmarker's native parse/render/extension options (`table`, `strikethrough`, `autolink`, `smartypants`, `tasklist`, …).
Redcarpet-specific options such as `no_images`, `no_links`, `link_attributes`, and `filter_html` are out of scope.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then run
`bundle exec rake` to run StandardRB, the minitest unit tests, and the cucumber
features. You can also run `bin/console` for an interactive prompt.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/unasuke/middleman-commonmarker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/unasuke/middleman-commonmarker/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Middleman::Commonmarker project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/unasuke/middleman-commonmarker/blob/main/CODE_OF_CONDUCT.md).
