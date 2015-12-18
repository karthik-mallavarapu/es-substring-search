# Generate type mappings with ngram filters for strings.
require 'date'
module MappingBuilder

  def self.generate_mapping(doc_type, field_types)
    mapping = Hash.new
    # Doc type
    properties = { "properties" => {} }
    field_types.each do |field, type|
      properties["properties"][field] = get_field_mapping(type)
    end
    mapping["mappings"] = {doc_type => properties}
    return mapping
  end

  def self.get_field_mapping(type)
    es_type = case type
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
    field_mapping = {}
    field_mapping["type"] = es_type
    field_mapping["analyzer"] = "ngram_analyzer" if es_type == "string"
    return field_mapping
  end
end
