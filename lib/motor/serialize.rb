# frozen_string_literal: true

require_relative "serialize/json"
require_relative "serialize/xlsx"

module Motor
  module Serialize
    def self.[](file, type)
      { json: JSON, xlsx: XLSX }[type].tap { |handler| raise(Error, "Unsupported data type: #{type}") unless handler }
    end

    def self.read(file, type:)
      handler = self[file, type]
      handler::Read.(file)
    end

    def self.write(file, instance, type:)
      handler = self[file, type]
      raise(Error, "Output file required for XLSX") if type == :xlsx && !file

      blob = handler::Write.(instance)
      file ? ::File.open(file, "wb") { |f| f.write(blob) } : puts(blob)
    end
  end

  def self.to_json(problem)  = Serialize::JSON::Write.(problem)
  def self.from_json(string) = Serialize::JSON::Read.problem(string)

  def self.read(...)         = Serialize.read(...)
  def self.write(...)        = Serialize.write(...)
end
