# frozen_string_literal: true

module Motor
  module Problem
    class Data < ::Data
      def initialize(...)
        super
        sanitize if respond_to?(:sanitize)
      end

      def to_h
        transformer = proc do |value|
          case value
          when ::Numeric, ::String, ::TrueClass, ::FalseClass then value
          when ::Array                                        then value.map { |e| transformer.call(e) }
          else                                                     value.to_h
          end
        end
        super.transform_values(&transformer)
      end

      def to_json(...) = to_h.tap { |h| h.delete(:solution) if h[:solution] && h[:solution].empty? }.to_json(...)

      class << self
        def create(hash)  = new(**assert!(hash).transform_keys(&:to_sym))

        def series(array) = array.map { |hash| create(assert!(hash)) }

        private

        def assert!(hash) = hash.tap do
          raise(InvalidData, "Hash expected where found #{hash.class}") unless hash.is_a?(::Hash)
          raise(InvalidData, "Empty data") if hash.empty?
        end
      end
    end

    # rubocop:disable Metrics/LineLength
    Objective  = Data.define(*%i[coefficients])
    Constraint = Data.define(*%i[name coefficients relation rhs])
    Instance   = Data.define(*%i[name variables objective constraints solution]) do
      def initialize(name:, variables:, objective:, constraints:, solution: nil) = super

      def has_solution? = solution
      def has_sensitivity? = solution && solution.sensitivity

      def size = variables.size

      def sanitize
        raise(Error, "Variable names must be uniq") unless variables.map(&:downcase).uniq.size == variables.size
        raise(Error, "Variables and Coefficients size must be equal") unless variables.size == objective.coefficients.size

        if (constraint = constraints.find { |constraint| constraint.coefficients.size != variables.size })
          raise(Error, "Constraint with incorrect size: '#{constraint.name}'; expected #{variables.size} coefficients where found #{constraint.coefficients.size}")
        end
      end
    end

    module Solution
      module Sensitivity
        Coefficient = Data.define(*%i[variable value reduced_cost original_value lower_bound upper_bound is_basic_variable])
        Boundary    = Data.define(*%i[constraint shadow_price slack_or_surplus original_value lower_bound upper_bound neither_bounds_are_binding])
        Instance    = Data.define(*%i[coefficients boundaries])
      end

      Result   = Data.define(*%i[value code description])
      Instance = Data.define(*%i[result sensitivity]) do
        def initialize(result:, sensitivity: nil) = super
      end
    end
    # rubocop:enable Metrics/LineLength

    def self.call(data) # rubocop:disable Metrics/MethodLength
      bucket = data["solution"]

      solution = Solution::Instance.new(
        result:      Solution::Result.create(bucket["result"]),
        sensitivity: Solution::Sensitivity::Instance.new(
          coefficients: Solution::Sensitivity::Coefficient.series(bucket["coefficients"]),
          boundaries:   Solution::Sensitivity::Boundary.series(bucket["boundaries"])
        )
      ) if bucket && !bucket.empty?

      Instance.new(
        name:        data["name"],
        variables:   data["variables"],
        objective:   Objective.create(data["objective"]),
        constraints: Constraint.series(data["constraints"]),
        solution:
      )
    end
  end
end
