# frozen_string_literal: true

desc "Test"
task :test do
  FileList["test/*-in.json"].each do |infile|
    outfile = infile.gsub("in", "out")

    actual = %x(bin/rotor #{infile}).strip
    expected = File.read(outfile).strip

    warn ">   #{infile}"
    unless actual == expected
      warn "❌   #{outfile}"
    end
  end
end

require "rubocop/rake_task"
RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ["--display-cop-names"]
end

desc "Lint code"
task lint: :rubocop

task default: [:test]
