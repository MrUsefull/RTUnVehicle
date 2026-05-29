require 'minitest/autorun'
require 'json'
require_relative '../DefaultMechs'

class DefaultMechsTest < Minitest::Test
  VALID_DIFFICULTIES = (1..10).to_a

  VALID_DIFFICULTIES.each do |d|
    define_method("test_difficulty_#{d}_returns_valid_json_string") do
      result = DefaultMechs.getDefaultMech(d)
      assert_instance_of String, result
      parsed = JSON.parse(result)
      assert_equal "Mech", parsed["unitType"]
    end
  end

  def test_unknown_difficulty_returns_valid_json
    result = DefaultMechs.getDefaultMech(99)
    assert JSON.parse(result)
  end

  def test_float_difficulty_returns_valid_json_string
    result = DefaultMechs.getDefaultMech(3.7)
    assert_instance_of String, result
    assert JSON.parse(result)
  end

  def test_nil_difficulty_returns_valid_json_string
    result = DefaultMechs.getDefaultMech(nil)
    assert_instance_of String, result
    assert JSON.parse(result)
  end
end
