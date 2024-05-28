# frozen_string_literal: true

require "json"

require "set"

module Motor
  module Reader
    class JSON
      attr_reader :file, :json

      def initialize(file)
        @json = ::JSON.load_file(@file = file)

        sanitize
      end

      def objective(problem)   = Objective.(json, problem)

      def constraints(problem) = Constraints.(json, problem)

      # TODO: Should be an object
      def meta(problem)        = { name: ::File.basename(file, ".*").split("-").map(&:capitalize).join("-") }.freeze

      private

      def sanitize
      end

      class Base
        attr_reader :json

        def initialize(json)
          @json = json

          sanitize if respond_to?(:sanitize)
        end

        private

        def strings(data) = data.is_a?(::Array) ? data.map(&:strip) : data.strip

        def floats(data)  = data.is_a?(::Array) ? data.map(&:to_f)  : data.to_f

        class << self
          def call(json, ...) = new(json).call(...)
        end
      end

      class Objective < Base
        def call(problem)
          Model::Objective.new(
            variables:    variables(json),
            coefficients: coefficients(json),
            model:        problem
          )
        end

        private

        def variables(json)    = strings(json["variables"])

        def coefficients(json) = floats(json["objective"]["coefficients"])
      end

      class Constraints < Base
        attr_reader :constraints

        def call(problem) # rubocop:disable Metrics/MethodLength
          Model::Constraints.new(
            constraints: json["constraints"].map do |row|
              Model::Constraint.new(
                name:         name(row),
                coefficients: coefficients(row),
                relation:     relation(row),
                rhs:          rhs(row),
                model:        problem
              )
            end,

            model:       problem
          )
        end

        private

        def name(row)         = strings(row["name"])

        def relation(row)     = strings(row["relation"])

        def rhs(row)          = floats(row["rhs"])

        def coefficients(row) = floats(row["coefficients"])
      end
    end
  end
end
