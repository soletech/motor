# frozen_string_literal: true

require "fast_excel"
require "roo"

module Motor
  module Serialize
    module XLSX
      SheetData = Data.define(:name, :path)

      SHEET = {
        objective:    SheetData["objective",                %i[ objective                         ]],
        constraints:  SheetData["constraints",              %i[ constraints                       ]],
        result:       SheetData["result",                   %i[ solution result                   ]],
        coefficients: SheetData["sensitivity.coefficients", %i[ solution sensitivity coefficients ]],
        boundaries:   SheetData["sensitivity.boundaries",   %i[ solution sensitivity boundaries   ]]
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

          def [](sheet)   = has?(sheet) ? xlsx.sheet(index[SHEET[sheet].name]) : nil

          def has?(sheet) = index.key?(SHEET[sheet].name)

          def sanitize
            missings = %i[objective constraints].reject { has?(_1) }
            raise(Error, "Missing sheets: #{missings.join(", ")}") unless missings.empty?
          end
        end

        def self.call(file)
          F.autohash("name" => (spreadsheet = Spreadsheet.new(file)).name).tap do |data|
            SHEET.keys.each do |name|
              next unless (sheet = spreadsheet[name])

              Sheet.new(sheet).public_send(name, data)
            end
          end
        end

        module Sheets
          def objective(data)
            data["objective"] = {
              "variables"    => strings(rows.map { |row| row[0] }),
              "coefficients" => floats(rows.map { |row| row[1] }),
              "name"         => strings(rows.map { |row| row[2] }.compact).first,
              "method"       => strings(rows.map { |row| row[3] }.compact).first
            }
          end

          def constraints(data)
            data["constraints"] = rows.map do |row|
              {
                "constraint"   => strings(row[0]),
                "coefficients" => floats(row[3..]),
                "relation"     => strings(row[1]),
                "rhs"          => floats(row[2])
              }
            end
          end

          def result(data)
            data["solution"]["result"] = {
              "value"       => floats(rows.first[0]),
              "code"        => strings(rows.first[1]),
              "description" => strings(rows.first[2])
            }
          end

          def coefficients(data)
            data["solution"]["sensitivity"]["coefficients"] = rows.map { |row| Hash[*header.zip(row).flatten] }
          end

          def boundaries(data)
            data["solution"]["sensitivity"]["boundaries"] = rows.map { |row| Hash[*header.zip(row).flatten] }
          end
        end

        class Sheet
          include Sheets

          attr_reader :sheet, :rows, :header

          def initialize(sheet)
            @sheet  = sheet
            @rows   = sheet.to_a
            @header = @rows.shift

            sanitize if respond_to?(:sanitize)
          end

          private

          def strings(data) = data.is_a?(::Array) ? data.map(&:strip) : (data.nil? ? "" : data.strip)

          def floats(data)  = data.is_a?(::Array) ? data.map(&:to_f)  : data.to_f
        end
      end

      module Write
        def self.call(data) # rubocop:disable Metrics/MethodLength
          workbook = FastExcel.open(constant_memory: false)

          SHEET.each do |key, value|
            next unless data.dig(*value.path)

            Sheet.new(workbook, SHEET[key].name).public_send(key, data)
          end

          workbook.read_string
        end

        module Sheets
          def objective(data)
            sheet.append_row(%w[ variable coefficient name method])
            data[:objective][:variables].zip(data[:objective][:coefficients]).each { sheet.append_row(_1) }
            sheet.write_value(1, 2, data[:objective][:name]) if data[:objective][:name] && !data[:objective][:name].empty?
            sheet.write_value(1, 3, data[:objective][:method]) if data[:objective][:method] && !data[:objective][:method].empty?
          end

          def constraints(data)
            sheet.append_row(%w[ constraint relation rhs ] + data[:objective][:variables])
            data[:constraints].each do |hash|
              sheet.append_row([ hash[:name], hash[:relation], hash[:rhs], *hash[:coefficients] ])
            end
          end

          def result(data)
            sheet.append_row(data[:solution][:result].keys)
            sheet.append_row(data[:solution][:result].values)
          end

          def coefficients(data)
            sample = data[:solution][:sensitivity][:coefficients].first
            sheet.append_row(sample.keys)
            data[:solution][:sensitivity][:coefficients].each do |hash|
              sheet.append_row(hash.values)
            end
          end

          def boundaries(data)
            sample = data[:solution][:sensitivity][:boundaries].first
            sheet.append_row(sample.keys)
            data[:solution][:sensitivity][:boundaries].each do |hash|
              sheet.append_row(hash.values)
            end
          end
        end

        class Sheet
          include Sheets

          attr_reader :sheet

          def initialize(workbook, name)
            @sheet = workbook.add_worksheet(name).tap do |sheet|
              sheet.auto_width = true
            end
          end
        end
      end
    end
  end
end
