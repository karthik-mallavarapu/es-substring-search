require_relative 'es_client'
client = EsClient.new('config.yml')
#client.create_index
client.create_mapping
client.populate_data
