require_relative 'lib/es_client'
require_relative 'lib/query_builder'

def parse_result(term, response)
  document_hits = response["hits"]["total"]
  field_hits = Hash.new(0)
  response["hits"]["hits"].each do |hit|
    hit["matched_queries"].each do |field|
      field_hits[field] += 1
    end
  end
  puts "*********** Query term: #{term} **********"
  puts "Field hits: " unless field_hits.empty?
  field_hits.each do |field, count|
    puts "  #{field} => #{count}"
  end
  total_field_hits = field_hits.empty?? 0 : field_hits.values.reduce(&:+)
  puts "Document hits: #{document_hits}"
  puts "Total field hits: #{total_field_hits}"
  puts "Time taken: #{response['took']}"
end

#client = EsClient.new('config.yml')
#client.create_index
#client.create_mapping
#client.populate_data
config = YAML.load_file('config.yml')
data_files = config['query_types']
# Query config
query_term = 'clay county'
query_config = { index: config['index_url'], query: query_term }
# Field types
field_types = {}
data_files.each do |data_file|
  parser = DataParser.new(data_file)
  extn = File.extname data_file
  doc_type = File.basename(data_file, extn)
  field_types[doc_type] = parser.filter_field_types(query_term.class.to_s).keys
end
query_builder = QueryBuilder.new(field_types, query_config)
HttpClient.base_uri config['es_host']
res = HttpClient.post(query_builder.search_url, body: query_builder.constant_score_query.to_json)
parse_result(query_term, res)
