require 'minitest/autorun'
require 'pry'
require 'json'
require_relative '../mapping_builder'

class TestMappingBuilder < Minitest::Test

  def test_field_mapping_for_string
    # String test
    actual_type = MappingBuilder.get_field_mapping("String")
    expected_type = { "type" => "string", "analyzer" => "ngram_analyzer" }
    assert actual_type == expected_type
  end

  def test_field_mapping_for_int
    # Fixnum test
    actual_type = MappingBuilder.get_field_mapping("Fixnum")
    expected_type = { "type" => "long" }
    assert actual_type == expected_type
  end

  def test_field_mapping_for_date
    # Date test
    actual_type = MappingBuilder.get_field_mapping("Date")
    expected_type = { "type" => "date" }
    assert actual_type == expected_type
  end

  def test_field_mapping_for_bool
    # Boolean test
    actual_type = MappingBuilder.get_field_mapping("TrueClass")
    expected_type = { "type" => "boolean" }
    assert actual_type == expected_type
  end

  def test_mapping_for_fields
    fields = {
      "product_id" => "Fixnum",
      "product_name" => "String",
      "price" => "Float",
      "purchase_date" => "Date"
    }
    expected_output = JSON.parse(File.read('test/sample_mapping.json'))
    actual_output = MappingBuilder.generate_mapping(fields)
    assert expected_output == actual_output
  end
end

