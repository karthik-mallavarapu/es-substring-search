require 'httparty'
require 'yaml'
require 'json'
require 'pry'
require 'csv'
require_relative 'data_parser'
require_relative 'util_constants'

class EsClient

  class HttpClient
    include HTTParty
    headers "Accept" => "application/json"
  end

  attr_reader :index_url, :mapping, :settings, :type

  def initialize(config_file)
    config = YAML.load_file(config_file)
    @index_url = config['index_url']
    @type = config['type']
    @parser = DataParser.new(config['data'])
    @mapping = File.read(config['mapping'])
    @settings = {}
    HttpClient.base_uri config['es_host']
  end

  def create_index
    res = HttpClient.head(index_url)
    HttpClient.delete(index_url) if res.code == 200
    res = HttpClient.post(index_url, body: settings.to_json)
    raise "Could not create index" if res.code != 200
    puts "Index successfully created"
  end

  def populate_data
    @parser.each_row do |row|
      res = HttpClient.post("#{index_url}/#{type}", body: row.to_h.to_json)
      raise "Data index failure" unless (res.code == 201 || res.code == 200)
    end
    puts "Data successfully populated"
  end

  private

  def index_settings(shard_count)
    setting["settings"] = {
      "number_of_shards" => 1,
      "number_of_replicas" => 0,
      "analysis" => {
        "filter" => UtilConstants::NGRAM_FILTER,
        "analyzer" => UtilConstants::ANALYZER
      }
    }
  end
end
