# frozen_string_literal: true

require "dry/schema"

module Motor
  module Schema
    Objective = Dry::Schema.Params do
      optional(:name).maybe(:string)
      optional(:method).filled(:str?, included_in?: %w[ maximize minimize ])
      required(:variables).array(:string)
      required(:coefficients).array(:float)
    end

    Constraint = Dry::Schema.Params do
      required(:constraint).filled(:string)
      required(:rhs).filled(:float)
      required(:relation).filled(:str?, included_in?: %w[ > >= = < <= ])
      required(:coefficients).array(:float)

      before(:value_coercer) do |result|
        result.to_h.map { |h| h[:relation] = "=" if h[:relation] == "==" }
      end
    end

    module Solution
      Result = Dry::Schema.Params do
        optional(:code).filled(:string)
        optional(:description).filled(:string)
        required(:value).filled(:float)
      end

      module Sensitivity
        Coefficient = Dry::Schema.Params do
          required(:variable).filled(:string)
          required(:value).filled(:float)
          required(:reduced_cost).filled(:float)
          required(:original_value).filled(:float)
          required(:lower_bound).filled(:float)
          required(:upper_bound).filled(:float)
          required(:is_basic_variable).filled(:bool)
        end

        Boundary = Dry::Schema.Params do
          required(:constraint).filled(:string)
          required(:shadow_price).filled(:float)
          required(:slack_or_surplus).filled(:float)
          required(:original_value).filled(:float)
          required(:lower_bound).filled(:float)
          required(:upper_bound).filled(:float)
          required(:neither_bounds_are_binding).filled(:bool)
        end
      end
    end

    Root = Dry::Schema.Params do
      required(:objective).hash(Objective)
      required(:constraints).array(Constraint)
      optional(:solution).hash do
        required(:result).hash(Solution::Result)
        optional(:sensitivity).hash do
          required(:coefficients).array(Solution::Sensitivity::Coefficient)
          required(:boundaries).array(Solution::Sensitivity::Boundary)
        end
      end
    end

    def self.call(raw_hash)
      Root.call(raw_hash)
    end

    def self.json_schema
      Dry::Schema.load_extensions(:json_schema)
      Root.json_schema
    end
  end

  def self.problem!(raw_hash)
    (result = Schema.(raw_hash)).success? ? result.to_h : InvalidData.(result)
  end
end
