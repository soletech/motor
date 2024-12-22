# frozen_string_literal: true

require "json"

module Motor
  module Serialize
    module JSON
      module Read
        def self.call(file)      = problem(::File.read(file))

        def self.problem(string) = Problem.(::JSON.parse(string))
      end
      module Write
        def self.call(problem) = ::JSON.pretty_generate(problem)
      end
    end
  end
end
