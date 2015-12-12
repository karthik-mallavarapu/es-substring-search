require 'httparty'
require 'yaml'
require 'json'
require 'pry'
require 'csv'
require_relative 'data_parser'

class EsClient

  class HttpClient
    include HTTParty
    base_uri "http://localhost:9200"
    headers "Accept" => "application/json"
  end

  attr_reader :index_url, :mapping, :settings, :type

  def initialize(config_file)
    config = YAML.load_file(config_file)
    @index_url = config['index_url']
    @type = config['type']
    @parser = DataParser.new(config['data'])
    @mapping = File.read(config['mapping'])
    @settings = {"settings" => {"number_of_shards" => 1, "number_of_replicas" => 0}}
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
end
