# frozen_string_literal: true

desc "Test"
task :"test:integration" do
  FileList["test/*-in.json"].each do |infile|
    outfile = infile.gsub("in", "out")

    actual = %x(bin/motor #{infile}).strip
    expected = File.read(outfile).strip

    warn ">   #{infile}"
    unless actual == expected
      warn "❌   #{outfile}"
    end
  end
end

require "rake/testtask"
Rake::TestTask.new(:"test:unit") do |t|
  t.test_files = FileList["test/**/*_test.rb"].exclude(/(^[._]|integration)/)
end

desc "Run all tests"
task test: [:"test:unit", :"test:integration"]

require "rubocop/rake_task"
RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ["--display-cop-names"]
end

desc "Lint code"
task lint: :rubocop

task default: [:test]
