# frozen_string_literal: true

require "bundler/gem_tasks"
require "standard/rake"
require "rake/testtask"
require "cucumber/rake/task"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

Cucumber::Rake::Task.new(:cucumber) do |t|
  t.cucumber_opts = "--require features --color --strict --format #{ENV["CUCUMBER_FORMAT"] || "pretty"}"
end

task default: %i[standard test cucumber]
