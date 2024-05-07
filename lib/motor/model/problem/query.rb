# frozen_string_literal: true

require "forwardable"

module Motor
  module Model
    class Query
      def [](subject, key)
        @index[subject] ||= subject.index
        subject.query(@index[subject], key)
      end
    end

    module Queryable
      class << self
        def included(klass)
          klass.extend(Forwardable)
        end
      end

      def [](key) = problem.query[self, key]
    end
  end
end
