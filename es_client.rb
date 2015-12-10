require 'httparty'
require 'yaml'
require 'json'
require 'pry'

class EsClient
  include HTTParty
  base_uri "http://localhost:9200"
  headers "Accept" => "application/json"
end

INDEX_URL = "/sales"

def create_index
  res = EsClient.head(INDEX_URL)
  if res.code == 200
    EsClient.delete(INDEX_URL)
  end
  res = EsClient.post(INDEX_URL, body: File.read("settings.json"))
  raise "Could not create index" if res.code != 200
  puts "Index emails successfully created"
end

def populate_data
  emails = YAML.load_file("purchases.yml")
  emails.each_with_index do |email, ind|
    res = EsClient.put("#{INDEX_URL}/purchase/#{ind}", body: email.to_json)
    raise "Data index failure" unless (res.code == 201 || res.code == 200)
  end
end

create_index
populate_data
