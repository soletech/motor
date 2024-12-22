# frozen_string_literal: true

require "forwardable"

require "fast_excel"
require "roo"

module Motor
  module Serialize
    module XLSX
      SHEET = {
        objective:    "objective",
        constraints:  "constraints",
        result:       "result",
        coefficients: "sensitivity.coefficients",
        boundaries:   "sensitivity.boundaries"
      }.freeze

      module Read
        class Spreadsheet
          attr_reader :xlsx, :name, :index

          def initialize(file)
            @xlsx = Roo::Spreadsheet.open(file)
            @name = ::File.basename(file, ".*").split("-").map(&:capitalize).join("-").freeze
            @index = Hash[
              *@xlsx.sheets.each_with_index.map { |title, i| [ title.strip.downcase, i ] }.flatten
            ]

            sanitize
          end

          def [](sheet)   = has?(sheet) ? xlsx.sheet(index[SHEET[sheet]]) : nil

          def has?(sheet) = index.key?(SHEET[sheet])

          def sanitize
            missings = %i[objective constraints].reject { has?(_1) }
            raise(Error, "Missing sheets: #{missings.join(", ")}") unless missings.empty?
          end
        end

        def self.call(file) # rubocop:disable Metrics/MethodLength
          spreadsheet = Spreadsheet.new(file)

          Problem.(
            { "name" => spreadsheet.name, "solution" => {} }.tap do |data|
              Sheet::Objective.(spreadsheet, data)
              Sheet::Constraints.(spreadsheet, data)
              Sheet::Solution::Result.(spreadsheet, data)
              Sheet::Solution::Coefficients.(spreadsheet, data)
              Sheet::Solution::Boundaries.(spreadsheet, data)
            end
          )
        end

        class Sheet
          def self.call(spreadsheet, ...)
            sheet = spreadsheet[self.name.split("::").last.downcase.to_sym]
            new(sheet).call(...) if sheet
          end

          attr_reader :sheet, :rows, :headers

          def initialize(sheet)
            @sheet = sheet
            @rows  = sheet.to_a

            sanitize if respond_to?(:sanitize)
          end

          def header = strings(rows.shift)

          private

          def strings(data) = data.is_a?(::Array) ? data.map(&:strip) : data.strip

          def floats(data)  = data.is_a?(::Array) ? data.map(&:to_f)  : data.to_f

          class Objective < Sheet
            def call(data)
              header

              data["variables"] = strings(rows.map(&:first))
              data["objective"] = {
                "coefficients" => floats(rows.map(&:last))
              }
            end
          end

          class Constraints < Sheet
            def call(data)
              header

              data["constraints"] = rows.map do |row|
                {
                  "name"         => strings(row[0]),
                  "id"           => strings(row[1]),
                  "coefficients" => floats(row[4..]),
                  "relation"     => strings(row[2]),
                  "rhs"          => floats(row[3])
                }
              end
            end
          end

          module Solution
            class Result < Sheet
              def call(data)
                result = rows.to_h
                result.transform_keys!(&:downcase)
                result["value"] = result["value"].to_f
                data["solution"]["result"] = result
              end
            end

            class Coefficients < Sheet
              def call(data)
                fields = header
                data["solution"]["coefficients"] = rows.map { |row| Hash[*fields.zip(row).flatten] }
              end
            end

            class Boundaries < Sheet
              def call(data)
                fields = header
                data["solution"]["boundaries"] = rows.map { |row| Hash[*fields.zip(row).flatten] }
              end
            end
          end
        end
      end

      module Write
        def self.call(problem) # rubocop:disable Metrics/MethodLength
          workbook = FastExcel.open(constant_memory: true)

          Sheet::Objective.(problem, workbook)
          Sheet::Constraints.(problem, workbook)
          if problem.has_solution?
            Sheet::Solution::Result.(problem, workbook)
            if problem.has_sensitivity?
              Sheet::Solution::Coefficients.(problem, workbook)
              Sheet::Solution::Boundaries.(problem, workbook)
            end
          end

          workbook.read_string
        end

        class Sheet
          extend Forwardable

          def_delegators :problem, :objective, :constraints, :variables, :solution
          def_delegators :solution, :result, :coefficients, :boundaries

          attr_reader :problem, :workbook, :worksheet

          def initialize(problem, workbook)
            @problem   = problem
            @workbook  = workbook
            @worksheet = workbook.add_worksheet(SHEET[self.class.name.split("::").last.downcase.to_sym]).tap do |worksheet|
              worksheet.auto_width = true
            end
          end

          class Objective < Sheet
            def call
              worksheet.append_row(%w[ variable coefficient ])
              variables.zip(objective.coefficients).each { worksheet.append_row(_1) }
            end
          end

          class Constraints < Sheet
            def call
              worksheet.append_row(%w[ constraint relation rhs ] + variables)
              constraints.each do |constraint|
                worksheet.append_row([ constraint.name, constraint.relation, constraint.rhs, *constraint.coefficients ])
              end
            end
          end

          module Solution
            class Result < Sheet
              def call
                result.to_h.each { |key, value| worksheet.append_row([ key, value ]) }
              end
            end

            class Coefficients < Sheet
              def call
                worksheet.append_row(Problem::Solution::Coefficient.members.map(&:to_s))
                coefficients.each do |coefficient|
                  worksheet.append_row(coefficient.deconstruct)
                end
              end
            end

            class Boundaries < Sheet
              def call
                worksheet.append_row(Problem::Solution::Boundary.members.map(&:to_s))
                boundaries.each do |boundary|
                  worksheet.append_row(boundary.deconstruct)
                end
              end
            end
          end

          def self.call(...) = new(...).call
        end
      end
    end
  end
end
