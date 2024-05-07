# frozen_string_literal: true

require "forwardable"

module Motor
  module Model
    class Problem
      extend Forwardable

      def_delegators :objective, :variables
      def_delegators :to_h, :to_json

      attr_reader :query
      attr_accessor :objective, :constraints, :meta

      def initialize
        @query = Query.new
      end

      def constraint(name, variable)
        return unless (constraint = constraints[name])

        constraint[variable]
      end

      def name = meta[:name] || "Untitled"

      def to_h = { name:, variables:, objective: objective.to_h, constraints: constraints.to_a }

      class << self
        def create(read)
          new.tap do |problem|
            problem.objective   = read.objective(problem)
            problem.constraints = read.constraints(problem)
            problem.meta        = read.meta(problem)
          end
        end

        private_class_method :new
      end
    end
  end
end
