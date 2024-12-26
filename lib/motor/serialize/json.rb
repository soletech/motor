# frozen_string_literal: true

require "json"

module Motor
  module Serialize
    module JSON
      module Read
        def self.call(file)             = from_json(::File.read(file))

        def self.from_json(json_string) = Motor.problem!(::JSON.parse(json_string))
      end
      module Write
        def self.call(problem)          = ::JSON.pretty_generate(problem)
      end
    end
  end
end
