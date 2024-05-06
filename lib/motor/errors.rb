# frozen_string_literal: true

module Motor
  Error = Class.new(StandardError)

  module Reader
    Error = Class.new(Error)
  end

  module Writer
    Error = Class.new(Error)
  end
end
