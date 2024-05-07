# frozen_string_literal: true

require "forwardable"

module Motor
  module Model
    Constraint = Data.define(:name, :coefficients, :relation, :rhs, :model) do
      extend Forwardable
      include Queryable

      def_delegators :coefficients, :size
      def_delegators :model, :objective

      def initialize(...)
        super

        sanitize!
      end

      def index                  = Hash[*objective.variables.zip(coefficients).flatten]

      def query(index, variable) = index[variable]

      def to_h                   = { name:, coefficients:, relation:, rhs: }

      private

      def sanitize!
        raise(Error, "Constraint with incorrect size: #{name}") unless size == objective.size
      end
    end

    Constraints = Data.define(:constraints, :model) do
      extend Forwardable
      include Queryable
      include Enumerable

      def_delegators :constraints, :each

      def index                    = Hash[*constraints.map(&:name).zip(constraints).flatten]

      def query(index, constraint) = index[constraint]

      def to_a                     = constraints.map(&:to_h)
    end
  end
end
