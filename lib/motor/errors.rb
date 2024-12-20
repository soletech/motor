# frozen_string_literal: true

module Motor
  Error = Class.new(StandardError)

  module Serialize
    Error = Class.new(Error)
  end
end
