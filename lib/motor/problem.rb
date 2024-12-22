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

      def to_json(...) = to_h.tap do |h|
        %i[ analysis solution ].each do |key|
          h.delete(key) if h.key?(key) && (h[key].nil? || h[key].empty?)
        end
      end.to_json(...)

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
    ALLOWED_METHODS = %w[ maximize minimize ].freeze

    Analysis = Data.define(*%i[method description]) do
      def initialize(method: "maximize", description: "Untitled") = super

      def sanitize
        raise(Error, "Unrecognized method: #{method}") unless ALLOWED_METHODS.include?(method)
      end
    end
    Objective = Data.define(*%i[name coefficients]) do
      def initialize(name: nil, coefficients:) = super
    end
    Constraint = Data.define(*%i[name id coefficients relation rhs]) do
      def initialize(name:, id: "", coefficients:, relation:, rhs:) = super
    end
    Instance = Data.define(*%i[name analysis variables objective constraints solution]) do
      def initialize(name: "Untitled", analysis: nil, variables:, objective:, constraints:, solution: nil) = super

      def has_analysis?    = analysis
      def has_solution?    = solution
      def has_sensitivity? = solution && solution.coefficients && !solution.coefficients.empty?

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
      Result      = Data.define(*%i[value code description])
      Coefficient = Data.define(*%i[variable value reduced_cost original_value lower_bound upper_bound is_basic_variable])
      Boundary    = Data.define(*%i[constraint shadow_price slack_or_surplus original_value lower_bound upper_bound neither_bounds_are_binding])

      Instance    = Data.define(*%i[result coefficients boundaries]) do
        def initialize(result:, coefficients: [], boundaries: []) = super
      end
    end
    # rubocop:enable Metrics/LineLength

    def self.call(data) # rubocop:disable Metrics/MethodLength
      bucket = data["solution"]

      solution = Solution::Instance.new(
        result:       Solution::Result.create(bucket["result"]),
        coefficients: Solution::Coefficient.series(bucket["coefficients"]),
        boundaries:   Solution::Boundary.series(bucket["boundaries"])
      ) if bucket && !bucket.empty?

      bucket = data["analysis"]
      analysis = Analysis.create(bucket) if bucket && !bucket.empty?

      Instance.new(
        name:        data["name"],
        analysis:,
        variables:   data["variables"],
        objective:   Objective.create(data["objective"]),
        constraints: Constraint.series(data["constraints"]),
        solution:
      )
    end
  end
end
