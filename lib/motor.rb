# frozen_string_literal: true

require "json"
require "tmpdir"

module Motor
  extend self

  MOTOR = File.expand_path(File.join(__dir__, "..", "bin", "motor"))

  def solve(request)
    Dir.mktmpdir do |dir|
      request_file, response_file = File.join(dir, "request.json"), File.join(dir, "response.json")
      File.write(request_file, request)

      system(MOTOR, request_file, response_file)
      File.read(response_file)
    end
  end

  InvalidData = Class.new(StandardError)

  def validate(request)
    Dir.mktmpdir do |dir|
      request_file, response_file = File.join(dir, "request.json"), File.join(dir, "response.json")
      File.write(request_file, request)

      unless system(MOTOR, "-validate", request_file, response_file)
        response = JSON.load_file(response_file)
        raise InvalidData, response["status"]["desc"]
      end

      true
    end
  end
end
