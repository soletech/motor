# frozen_string_literal: true

require "json"

module Motor
  module Writer
    module JSON
      extend self

      def call(...) = ::JSON.pretty_generate(...)
    end
  end
end
