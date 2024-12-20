# frozen_string_literal: true

require_relative "motor/errors"

require_relative "motor/problem"
require_relative "motor/serialize"

require_relative "motor/version"

require "json"
require "tmpdir"

module Motor
  extend self

  MOTOR = File.expand_path(File.join(__dir__, "..", "bin", "motor"))
  ROTOR = File.expand_path(File.join(__dir__, "..", "bin", "rotor"))

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
      raise(Unsuccessful, response["solution"]["result"]["desc"]) unless response["solution"]["success"]
    end
  end

  def run(excel_file)
    Dir.mktmpdir do |dir|
      response_file = File.join(dir, "response.json")

      system(ROTOR, excel_file, response_file)

      File.read(response_file).tap do |json|
        response = JSON.parse(json)
        raise(Unsuccessful, response["solution"]["result"]["desc"]) unless response["solution"]["success"]
      end
    end
  end

  def validate(request)
    Dir.mktmpdir do |dir|
      request_file, response_file = File.join(dir, "request.json"), File.join(dir, "response.json")
      File.write(request_file, request)

      unless system(MOTOR, "-validate", request_file, response_file)
        response = JSON.load_file(response_file)
        raise(InvalidData, response["solution"]["result"]["desc"])
      end

      true
    end
  end
end
