# frozen_string_literal: true

require_relative "../test_helper"

class BasicsTest < Minitest::Test
  FIXTURES = File.expand_path(File.join(__dir__, "..", "integration"))

  def test_solve
    request  = File.read(File.join(FIXTURES, "01-bafra-in.json"))
    expected = File.read(File.join(FIXTURES, "01-bafra-out.json"))

    assert_equal(expected, Motor.solve(request))
  end

  def test_solve!
    request  = File.read(File.join(FIXTURES, "03-unbound-in.json"))
    expected = File.read(File.join(FIXTURES, "03-unbound-out.json"))

    assert_equal(expected, Motor.solve(request))
    assert_raises(Motor::Unsuccessful, "Problem has unbounded solution") { Motor.solve!(request) }
    assert_raises(Motor::Error, "Problem has unbounded solution") { Motor.solve!(request) }
  end

  def test_validate
    assert_raises(Motor::InvalidData, "Data empty") { Motor.validate("{}") }
  end
end
