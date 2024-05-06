# frozen_string_literal: true

require "forwardable"

module Motor
  module Model
    class Part
      extend Forwardable

      def_delegators :@lookup, :[]

      attr_reader :name, :coefficients
    end

    private_constant :Part

    class Problem
      extend Forwardable

      def_delegators :@objective, :variables

      attr_reader :objective, :constraints, :meta

      def initialize(objective:, constraints:, meta: {})
        @objective = objective
        @constraints = constraints
        @meta = meta
      end

      def [](constraint, variable)
        return unless (constraint = constraints[constraint])

        constraint[variable]
      end

      def name         = meta[:name] || "Untitled"

      def to_h         = { name:, variables:, objective: objective.to_h, constraints: constraints.to_a }

      def to_json(...) = to_h.to_json(...)
    end

    class Objective < Part
      def_delegators :@variables, :size, :index

      attr_reader :variables, :coefficients

      def initialize(variables:, coefficients:)
        @name = "Objective Function"
        @variables = variables
        @coefficients = coefficients

        build
      end

      def to_h = { name:, coefficients: }

      private

      def build
        variables.map!(&:strip)
        coefficients.map!(&:to_f)

        raise(Error, "Variable names must be uniq") unless variables.map(&:downcase).uniq.size == variables.size
        raise(Error, "Variables and Coefficients size must be equal") unless variables.size == coefficients.size

        @lookup = Hash[*variables.zip(coefficients).flatten]
      end
    end

    class Constraint < Part
      def_delegators :@coefficients, :size

      attr_reader :relation, :rhs

      def initialize(name:, objective:, coefficients:, relation:, rhs:)
        @name = name
        @objective = objective
        @coefficients = coefficients
        @relation = relation
        @rhs = rhs.to_f

        build
      end

      def to_h = { name:, coefficients:, relation:, rhs: }

      private

      attr_reader :objective, :coefficients

      def build
        raise(Error, "Constraint with incorrect size: #{name}") unless size == objective.size

        @lookup = Hash[*objective.variables.zip(coefficients).flatten]
      end
    end

    class Constraints < Part
      include Enumerable

      def_delegators :@constraints, :each

      def initialize(constraints)
        @constraints = constraints

        build
      end

      def to_a = constraints.map(&:to_h)

      private

      attr_reader :constraints

      def build = @lookup = Hash[*constraints.map(&:name).zip(constraints).flatten]
    end
  end
end
