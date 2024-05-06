# frozen_string_literal: true

require "set"

require "roo"

module Motor
  module Reader
    class XLSX
      attr_reader :xlsx, :file, :constraints, :objective, :meta

      def initialize(file)
        @file = file
        @xlsx = Roo::Spreadsheet.open(file)
      end

      def call
        Model::Problem.new(
          objective: (objective = Objective.(xlsx.sheet(0))),
          constraints: Constraints.(xlsx.sheet(1), objective),
        )
      end

      class Matrix
        attr_reader :rows, :headers

        def initialize(sheet)
          @headers = (@rows = sheet.to_a).shift

          sanitize!
        end

        private

        def sanitize!
          raise(Error, "Unexpected headers") unless self.class::HEADERS.subset?(Set.new(headers.map(&:downcase)))

          sanitize
        end

        class << self
          def call(sheet, ...) = new(sheet).call(...)
        end
      end

      class Objective < Matrix
        HEADERS = Set["variable", "coefficient"].freeze

        attr_reader :variable

        def call = Model::Objective.new(variables: rows.map(&:first), coefficients: rows.map(&:last))

        private

        def sanitize
        end
      end

      class Constraints < Matrix
        HEADERS = Set["constraint", "relation", "rhs"].freeze

        attr_reader :constraints

        def call(objective)
          Model::Constraints.new(
            rows.map do |name, relation, rhs, *coefficients|
              Model::Constraint.new(objective:, name:, relation:, rhs:, coefficients:)
            end,
          )
        end

        private

        def sanitize
        end
      end
    end
  end
end
