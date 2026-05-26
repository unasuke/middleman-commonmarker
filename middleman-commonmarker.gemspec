# frozen_string_literal: true

require_relative "lib/middleman-commonmarker/version"

Gem::Specification.new do |spec|
  spec.name = "middleman-commonmarker"
  spec.version = Middleman::Commonmarker::VERSION
  spec.authors = ["Yusuke Nakamura"]
  spec.email = ["yusuke1994525@gmail.com"]

  spec.summary = "Commonmarker (CommonMark) markdown engine extension for Middleman"
  spec.description = "A Middleman extension that renders Markdown with commonmarker, walking the AST to integrate Middleman's image_tag and url_for helpers."
  spec.homepage = "https://github.com/unasuke/middleman-commonmarker"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/unasuke/middleman-commonmarker"
  spec.metadata["changelog_uri"] = "https://github.com/unasuke/middleman-commonmarker/blob/main/CHANGELOG.md"

  # Require MFA for gem pushes to protect against supply chain attacks.
  # See: https://guides.rubygems.org/mfa-requirement-opt-in/
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .github/ .standard.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "middleman-core"
  spec.add_dependency "commonmarker"

  # For more information and examples about making a new gem, check out our
  # guide at: https://guides.rubygems.org/make-your-own-gem/
end
