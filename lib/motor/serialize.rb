# frozen_string_literal: true

require_relative "serialize/json"
require_relative "serialize/xlsx"

module Motor
  module Serialize
    def self.[](type)
      { json: JSON, xlsx: XLSX }[type.to_sym].tap { |handler| raise(Error, "Unsupported data type: #{type}") unless handler }
    end

    def self.read(file, type:)
      handler = self[type]
      handler::Read.(file)
    end

    def self.write(file, instance, type:)
      handler = self[type]
      raise(Error, "Output file required for XLSX") if type == :xlsx && !file

      blob = handler::Write.(instance)
      file ? ::File.open(file, "wb") { |f| f.write(blob) } : puts(blob)
    end

    def self.dump(instance, type:)
      self[type]::Write.(instance)
    end
  end

  def self.to_json(problem)       = Serialize::JSON::Write.(problem)
  def self.from_json(json_string) = Serialize::JSON::Read.from_json(json_string)

  def self.read(...)              = Serialize.read(...)
  def self.write(...)             = Serialize.write(...)
  def self.dump(...)              = Serialize.dump(...)
end
