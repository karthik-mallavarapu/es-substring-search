require_relative 'lib/es_client'
require_relative 'lib/query_builder'
#client = EsClient.new('config.yml')
#client.create_index
#client.create_mapping
#client.populate_data
config = YAML.load_file('config.yml')
data_files = config['query_types']
field_types = {}
data_files.each do |data_file|
  parser = DataParser.new(data_file)
  extn = File.extname data_file
  doc_type = File.basename(data_file, extn)
  field_types[doc_type] = parser.get_field_types.keys
end
query_config = { index: config['index_url'], query: 206893 }
query_builder = QueryBuilder.new(field_types, query_config)
HttpClient.base_uri config['es_host']
res = HttpClient.post(query_builder.search_url, body: query_builder.constant_score_query.to_json)
binding.pry
