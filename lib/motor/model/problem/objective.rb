# frozen_string_literal: true

module Motor
  module Model
    Objective = Data.define(:name, :variables, :coefficients, :problem) do
      include Queryable

      def_delegators :variables, :size, :index

      def initialize(name: "Objective Function", variables:, coefficients:, problem:)
        super(name:, variables:, coefficients:, problem:)

        sanitize!
      end

      def index = Hash[*variables.zip(coefficients).flatten]

      def to_h = { name:, coefficients: }

      private

      def sanitize!
        raise(Error, "Variable names must be uniq") unless variables.map(&:downcase).uniq.size == variables.size
        raise(Error, "Variables and Coefficients size must be equal") unless variables.size == coefficients.size
      end
    end
  end
end
