# frozen_string_literal: true

require_relative "serialize/json"
require_relative "serialize/xlsx"

module Motor
  module Serialize
    def self.[](file, type = nil)
      type = (type || file ? ::File.extname(file)[1..] : "json").downcase.to_sym

      [
        { json: JSON, xlsx: XLSX }[type].tap { |handler| raise(Error, "Unsupported data type: #{type}") unless handler },
        type
      ]
    end

    def self.read(file, type: nil)
      handler, = self[file, type]
      handler::Read.(file)
    end

    def self.write(file, instance, type: nil)
      handler, type = self[file, type]
      raise(Error, "Output file required for XLSX") if type == :xlsx && !file

      blob = handler::Write.(instance)
      file ? ::File.write(file, blob) : puts(blob)
    end
  end

  def self.read(...)  = Serialize.read(...)
  def self.write(...) = Serialize.write(...)
end
