# frozen_string_literal: true

require "json"

module Motor
  module Serialize
    module JSON
      module Read
        def self.call(file) = Problem.(::JSON.load_file(file))
      end
      module Write
        def self.call(instance) = ::JSON.pretty_generate(instance)
      end
    end
  end
end
