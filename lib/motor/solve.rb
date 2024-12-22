# frozen_string_literal: true

require "tempfile"

module Motor
  extend self

  def solve(problem)
    result = invoke(to_json(problem))
    from_json(result.out)
  end

  DEFAULT_FILE_TYPE = :json

  def convert(infile, outfile, read: nil, write: nil)
    self.write(
      outfile,
      self.read(infile, type: filetype(infile, type: read, default: DEFAULT_FILE_TYPE)),
      type: filetype(outfile, type: write, default: DEFAULT_FILE_TYPE)
    )
  end

  def read_solve_write(infile, outfile, read: nil, write: nil)
    self.write(
      outfile,
      solve(self.read(infile, type: filetype(infile, type: read, default: DEFAULT_FILE_TYPE))),
      type: filetype(outfile, type: write, default: DEFAULT_FILE_TYPE)
    )
  end

  def read_solve_process(infile, read: nil, write: nil)
    Tempfile.create("motor") do |tempfile|
      read_solve_write(infile, tempfile.path, read:, write:)
      yield(tempfile) if block_given?
    end
  end

  def validate_file(file, type: nil)
    self.read(file, type: filetype(file, type:, default: DEFAULT_FILE_TYPE))
    true
  end

  private

  MOTOR = File.expand_path(File.join(__dir__, "..", "..", "bin", "motor"))

  def invoke(json_string) = run(MOTOR, "/dev/stdin") { json_string }
end
