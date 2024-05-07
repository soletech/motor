# frozen_string_literal: true

module Motor
  module Model
    Constraint = Data.define(:name, :coefficients, :relation, :rhs, :problem) do
      include Queryable

      def_delegators :coefficients, :size
      def_delegators :problem, :objective

      def initialize(...)
        super

        sanitize!
      end

      def to_h = { name:, coefficients:, relation:, rhs: }

      private

      def index = Hash[*objective.variables.zip(coefficients).flatten]

      def sanitize!
        raise(Error, "Constraint with incorrect size: #{name}") unless size == objective.size
      end
    end

    Constraints = Data.define(:constraints, :problem) do
      include Queryable
      include Enumerable

      def_delegators :constraints, :each

      def index = Hash[*constraints.map(&:name).zip(constraints).flatten]

      def to_a  = constraints.map(&:to_h)
    end
  end
end
