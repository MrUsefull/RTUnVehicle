# frozen_string_literal: true

require "minitest/autorun"
require "json"
require_relative "../default_mechs"

class DefaultMechsTest < Minitest::Test
  VALID_DIFFICULTIES = (1..10).to_a

  VALID_DIFFICULTIES.each do |d|
    define_method("test_difficulty_#{d}_returns_valid_json_string") do
      result = DefaultMechs.get_default_mech(d)
      assert_instance_of String, result
      parsed = JSON.parse(result)
      assert_equal "Mech", parsed["unitType"]
    end
  end

  def test_unknown_difficulty_returns_valid_json
    result = DefaultMechs.get_default_mech(99)
    assert JSON.parse(result)
  end

  def test_float_difficulty_returns_valid_json_string
    result = DefaultMechs.get_default_mech(3.7)
    assert_instance_of String, result
    assert JSON.parse(result)
  end

  def test_nil_difficulty_returns_valid_json_string
    result = DefaultMechs.get_default_mech(nil)
    assert_instance_of String, result
    assert JSON.parse(result)
  end
end
