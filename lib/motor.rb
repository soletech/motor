# frozen_string_literal: true

require "json"
require "tmpdir"

module Motor
  extend self

  MOTOR = File.expand_path(File.join(__dir__, "..", "bin", "motor"))

  Error        = Class.new(StandardError)
  InvalidData  = Class.new(Error)
  Unsuccessful = Class.new(Error)

  def solve(request)
    Dir.mktmpdir do |dir|
      request_file, response_file = File.join(dir, "request.json"), File.join(dir, "response.json")
      File.write(request_file, request)

      system(MOTOR, request_file, response_file)
      File.read(response_file)
    end
  end

  def solve!(request)
    solve(request).tap do |json|
      response = JSON.parse(json)
      raise Unsuccessful, response["status"]["desc"] unless response["success"]
    end
  end

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
