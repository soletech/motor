# frozen_string_literal: true

module Motor
  Error = Class.new(StandardError)

  InvalidData  = Class.new(Error)
  Unsuccessful = Class.new(Error)

  module Serialize
    Error = Class.new(Error)
  end
end
