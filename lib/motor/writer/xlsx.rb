# frozen_string_literal: true

require "forwardable"

require "fast_excel"

module Motor
  module Writer
    class XLSX
      extend Forwardable
      def_delegators :problem, :objective, :constraints

      attr_reader :problem, :workbook

      def initialize(problem)
        @problem = problem
        @workbook = FastExcel.open(constant_memory: true)
      end

      def call
        write_objective
        write_constraints

        workbook.read_string
      end

      private

      def write_objective
        worksheet = worksheet("objective")

        worksheet.append_row(%w[ Variable Coefficient ])

        objective.variables.zip(objective.coefficients).each { worksheet.append_row(_1) }
      end

      def write_constraints
        worksheet = worksheet("constraints")

        worksheet.append_row(%w[ Constraint Relation RHS ] + objective.variables)
        constraints.each do |constraint|
          worksheet.append_row([ constraint.name, constraint.relation, constraint.rhs, *constraint.coefficients ])
        end
      end

      def worksheet(name)
        workbook.add_worksheet(name).tap do |worksheet|
          worksheet.auto_width = true
        end
      end

      class << self
        def call(...) = new(...).call
      end
    end
  end
end
