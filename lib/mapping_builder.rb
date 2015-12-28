# Generate type mappings with ngram filters for strings.
require 'date'

module MappingBuilder

  def self.generate_mapping(field_types)
    mapping = { "properties" => {} }
    field_types.each do |field, type|
      mapping["properties"][field] = get_field_mapping(type)
    end
    return mapping
  end

  def self.get_field_mapping(type)
    es_type = get_es_type(type)
    field_mapping = {}
    field_mapping["type"] = es_type
    field_mapping["analyzer"] = "ngram_analyzer" if es_type == "string"
    return field_mapping
  end

  def self.get_es_type(type)
    es_type = 
      case type
      when "TrueClass","FalseClass"
        "boolean"
      when "Float"
        "float"
      when "String"
        "string"
      when "Fixnum","Integer","Bignum"
        "long"
      when "Date", "DateTime"
        "date"
      end
    return es_type
  end
end
