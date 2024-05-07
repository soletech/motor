# frozen_string_literal: true

desc "Test integration"
task "test:integration": %i[test:integration:motor test:integration:rotor]

desc "Test Motor integration"
task :"test:integration:motor" do
  warn "Motor integration"

  FileList["test/integration/motor/*-in.json"].each do |infile|
    outfile = infile.gsub("-in", "-out")

    actual = %x(bin/motor #{infile}).strip
    expected = File.read(outfile).strip

    warn "  >   #{infile}"
    unless actual == expected
      warn "  ❌   #{outfile}"
    end
  end
end

desc "Test Rotor integration"
task :"test:integration:rotor" do
  warn "Rotor integration"

  FileList["test/integration/rotor/*-in.xlsx"].each do |infile|
    outfile = infile.gsub("-in.xlsx", "-out.json")

    actual = %x(bin/rotor #{infile}).encode("UTF-8").strip
    expected = File.read(outfile).encode("UTF-8").strip

    warn "  >   #{infile}"
    unless actual == expected
      warn "  ❌   #{outfile}"
    end
  end
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
