# frozen_string_literal: true

module Motor
  Error = Class.new(StandardError) do
    def summary(...) = message
  end

  InvalidData = Class.new(Error) do
    attr_reader :errors

    def initialize(errors, message = "Data errors found")
      @errors = errors
      super(message)
    end

    def summary(title = nil) = [ "#{title || message}:", "", *errors ].join("\n")

    def self.call(result)    = raise(self, result.errors(full: true).to_h.values)
  end

  Unsuccessful = Class.new(Error)
  Unsolveable  = Class.new(Error)

  module Serialize
    Error = Class.new(Error)
  end
end
