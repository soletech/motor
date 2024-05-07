# frozen_string_literal: true

require "set"

require "roo"

module Motor
  module Reader
    class XLSX
      attr_reader :file, :xlsx, :index

      def initialize(file)
        @xlsx   = Roo::Spreadsheet.open(@file = file)

        @index  = Hash[
          *@xlsx.sheets.each_with_index.map do |title, i|
            [ title.strip.downcase, i ]
          end.flatten
        ]

        sanitize
      end

      def objective(problem)   = Objective.(xlsx.sheet(index["objective"]), problem)

      def constraints(problem) = Constraints.(xlsx.sheet(index["constraints"]), problem)

      # TODO: Should be an object
      def meta(problem)        = { name: ::File.basename(file, ".*").split("-").map(&:capitalize).join("-") }.freeze

      private

      def sanitize
        missings = %w[objective constraints].reject { index.key?(_1) }

        raise(Error, "Missing sheets: #{missings.join(", ")}") unless missings.empty?
      end

      class Matrix
        attr_reader :rows, :headers

        def initialize(sheet)
          @rows = sheet.to_a

          @rows.shift if self.class::HEADERS.subset?(Set.new(@rows.first.map(&:downcase)))

          sanitize if respond_to?(:sanitize)
        end

        private

        def strings(data) = data.is_a?(::Array) ? data.map(&:strip) : data.strip

        def floats(data)  = data.is_a?(::Array) ? data.map(&:to_f)  : data.to_f

        class << self
          def call(sheet, ...) = new(sheet).call(...)
        end
      end

      class Objective < Matrix
        HEADERS = Set["variable", "coefficient"].freeze

        attr_reader :variable

        def call(problem)
          Model::Objective.new(
            variables:    variables(rows),
            coefficients: coefficients(rows),

            problem:
          )
        end

        private

        def variables(rows)    = strings(rows.map(&:first))

        def coefficients(rows) = floats(rows.map(&:last))
      end

      class Constraints < Matrix
        HEADERS = Set["constraint", "relation", "rhs"].freeze

        attr_reader :constraints

        def call(problem) # rubocop:disable Metrics/MethodLength
          Model::Constraints.new(
            constraints: rows.map do |row|
              Model::Constraint.new(
                name:         name(row),
                coefficients: coefficients(row),
                relation:     relation(row),
                rhs:          rhs(row),
                problem:
              )
            end,

            problem:
          )
        end

        private

        def name(row)         = strings(row[0])

        def relation(row)     = strings(row[1])

        def rhs(row)          = floats(row[2])

        def coefficients(row) = floats(row[3..])
      end
    end
  end
end
