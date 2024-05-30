# frozen_string_literal: true

require "tempfile"

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

def ignore_name(content)
  content.split("\n").reject { _1.start_with?('  "name":') }.join("\n").strip
end

desc "Test Rotor integration"
task :"test:integration:rotor" do
  warn "Rotor integration"

  FileList["test/integration/rotor/*.json"].each do |file|
    xlsx     = file.gsub(".json", ".xlsx")
    expected = ignore_name(::File.read(file).encode("UTF-8"))

    warn "  >   #{file}: JSON read JSON write"
    actual = %x(bin/rotor -r json -w json #{file}).encode("UTF-8").strip
    unless ignore_name(actual) == expected
      warn "  ❌   #{file}"
    end

    warn "  >   #{file}: JSON read XLSX write"
    actual = Tempfile.create("rotor") do |f|
      sh("bin/rotor -r json -w xlsx #{file} #{f.path}.xlsx", verbose: false)
      %x(bin/rotor -r xlsx -w json #{f.path}.xlsx).encode("UTF-8")
    end
    unless ignore_name(actual) == expected
      warn "  ❌   #{file}"
    end

    warn "  >   #{file}: XLSX read JSON write"
    actual = %x(bin/rotor -r xlsx -w json #{xlsx})
    unless ignore_name(actual) == expected
      warn "  ❌   #{file}"
    end

    warn "  >   #{file}: XLSX read XLSX write"
    actual = Tempfile.create("rotor") do |f|
      sh("bin/rotor -r xlsx -w xlsx #{xlsx} #{f.path}.xlsx", verbose: false)
      %x(bin/rotor -r xlsx -w json #{f.path}.xlsx).encode("UTF-8").strip
    end

    unless ignore_name(actual) == expected
      warn "  ❌   #{file}"
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
