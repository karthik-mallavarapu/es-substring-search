require 'httparty'
require 'yaml'
require 'json'
require 'pry'

class EsClient
  include HTTParty
  base_uri "http://localhost:9200"
  headers "Accept" => "application/json"
end

INDEX_URL = "/library"

def create_index
  res = EsClient.head(INDEX_URL)
  if res.code == 200
    EsClient.delete(INDEX_URL)
  end
  res = EsClient.post(INDEX_URL, body: File.read("settings.json"))
  raise "Could not create index" if res.code != 200
  puts "Index blog successfully created"
end

def populate_data
  create_index
  books = YAML.load_file("data.yml")["books"]
  books.each_with_index do |book, ind|
    res = EsClient.put("#{INDEX_URL}/books/#{ind}", body: book.to_json)
    raise "Data index failure" unless (res.code == 201 || res.code == 200)
  end
end

def query_body(term)
  return {
    "query" => {
      "multi_match" => {
        "query" => term,
        "fields" => ["title", "description", "author"]
      }
    },
    "highlight" => {
      "fields" => {"*" => {}}
    }
  }.to_json
end

def msearch(terms, request_body)
  responses = EsClient.post("/_msearch", body: request_body)
  raise "Something went wrong with the query" unless responses.code == 200
  responses["responses"].each_with_index do |response, ind|
    parse_response(terms[ind], response)
  end
end

def parse_response(term, response)
  document_hits = 0
  field_hits = Hash.new(0)
  document_hits = response["hits"]["hits"].count
  response["hits"]["hits"].each do |hit|
    hit["highlight"].each do |field, values|
      field_hits[field] += values.count
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
end

def multi_search(terms)
  queries = []
  index_query = { "index" => "library" }
  terms.each do |term|
    queries << index_query.to_json
    queries << query_body(term)
  end
  formatted_queries = queries.join("\n")
  formatted_queries += "\n"
  msearch(terms, formatted_queries) 
end

populate_data
sleep 5
terms = YAML.load_file("data.yml")["terms"]
multi_search(terms)
