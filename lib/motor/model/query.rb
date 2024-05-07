# frozen_string_literal: true

module Motor
  module Model
    class Query
      def initialize       = @index = {}

      def [](subject, key) = subject.query(@index[subject] ||= subject.index, key)
    end

    private_constant :Query

    module Queryable
      def [](key) = problem.query[self, key]
    end
  end
end
