# frozen_string_literal: true

require "forwardable"

module Motor
  module Model
    Objective = Data.define(:name, :variables, :coefficients, :container) do
      extend Forwardable
      include Queryable

      def_delegators :variables, :size, :index

      def initialize(name: "Objective Function", variables:, coefficients:, container:)
        super(name:, variables:, coefficients:, container:)

        sanitize!
      end

      def index                  = Hash[*variables.zip(coefficients).flatten]

      def query(index, variable) = index[variable]

      def to_h = { name:, coefficients: }

      private

      def sanitize!
        raise(Error, "Variable names must be uniq") unless variables.map(&:downcase).uniq.size == variables.size
        raise(Error, "Variables and Coefficients size must be equal") unless variables.size == coefficients.size
      end
    end
  end
end
