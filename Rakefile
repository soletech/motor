# frozen_string_literal: true

require "tempfile"

desc "Test integration"
task :"test:integration" do
  warn "Integration test"

  FileList["test/integration/*-in.json"].each do |infile|
    outfile = infile.gsub("-in", "-out")

    actual = %x(bin/rotor #{infile}).strip
    expected = File.read(outfile).strip

    warn "  >   #{infile}"
    unless actual == expected
      warn "  ❌   #{outfile}"
    end
  end
end

def ignore_name(content)
  content.split("\n").reject { _1.start_with?('  "name":') }.join("\n").strip
end

require "rake/testtask"
Rake::TestTask.new(:"test:unit") do |t|
  t.test_files = FileList["test/**/*_test.rb"].exclude(/(^[._]|integration)/)
end

desc "Run all tests"
task test: %i[test:unit test:integration]

require "rubocop/rake_task"
RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = [ "--display-cop-names" ]
end

desc "Pylint"
task :pylint do
  sh "pylint bin/motor"
end

desc "Lint code"
task lint: %i[pylint rubocop]

task default: [ :test ]

desc "Run all"
task all: %i[lint test]
